// functions/src/calls.ts
// Server side. Four jobs the client cannot be trusted with:
//   1. issue LiveKit tokens (secret never leaves here)
//   2. dispatch the incoming-call push
//   3. reap calls nobody answered / whose caller crashed
//   4. compute duration from server timestamps

import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";
import { AccessToken, TrackSource } from "livekit-server-sdk";
import { defineSecret, defineString } from "firebase-functions/params";

admin.initializeApp();
const db = admin.firestore();

// const LIVEKIT_URL = functions.config().livekit.url;
// const LIVEKIT_KEY = functions.config().livekit.key;
// const LIVEKIT_SECRET = functions.config().livekit.secret;
const LIVEKIT_URL = defineString("LIVEKIT_URL");
const LIVEKIT_KEY = defineSecret("LIVEKIT_KEY");
const LIVEKIT_SECRET = defineSecret("LIVEKIT_SECRET");

const RING_TIMEOUT_MS = 45_000;
const HEARTBEAT_STALE_MS = 60_000;

// ---------------------------------------------------------------------------
// 1. Token
// ---------------------------------------------------------------------------

export const issueCallToken = functions.https.onCall(async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) throw new functions.https.HttpsError("unauthenticated", "Sign in");

    const { callId, canPublishVideo } = data as {
        callId: string;
        canPublishVideo: boolean;
    };

    const snap = await db.collection("calls").doc(callId).get();
    if (!snap.exists) {
        throw new functions.https.HttpsError("not-found", "No such call");
    }
    const call = snap.data()!;

    // Authorization: you must be on the call, and the call must still be live.
    if (!(call.participantIds as string[]).includes(uid)) {
        throw new functions.https.HttpsError("permission-denied", "Not a participant");
    }
    if (call.status === "ended") {
        throw new functions.https.HttpsError("failed-precondition", "Call ended");
    }

    const ttlSeconds = 60 * 60 * 4;
    const at = new AccessToken(LIVEKIT_KEY.value(), LIVEKIT_SECRET.value(), {
        identity: `${uid}:${(data.identity as string).split(":")[1] ?? "d"}`,
        ttl: ttlSeconds,
    });

    at.addGrant({
        room: call.roomName,        // server decides the room, not the client
        roomJoin: true,
        canPublish: true,
        canSubscribe: true,
        canPublishData: true,
        // Voice-only calls cannot publish a camera track even if a patched client
        // tries to. Policy is enforced here, not in the UI.
        // canPublishSources: canPublishVideo
        //     ? ["microphone", "camera"]
        //     : ["microphone"],
        canPublishSources: canPublishVideo
            ? [TrackSource.MICROPHONE, TrackSource.CAMERA]
            : [TrackSource.MICROPHONE],
    });

    return {
        token: await at.toJwt(),
        url: LIVEKIT_URL.value(),
        expiresAt: new Date(Date.now() + ttlSeconds * 1000).toISOString(),
    };
});

// ---------------------------------------------------------------------------
// 2. Push dispatch on call creation
// ---------------------------------------------------------------------------

export const onCallCreated = functions.firestore
    .document("calls/{callId}")
    .onCreate(async (snap) => {
        const call = snap.data();
        const callees = (call.participantIds as string[]).filter(
            (p) => p !== call.callerId
        );

        const caller = await db.collection("users").doc(call.callerId).get();
        const callerName = caller.data()?.displayName ?? "Unknown";

        for (const callee of callees) {
            // Busy check: already in another live call?
            const busy = await db
                .collection("calls")
                .where("participantIds", "array-contains", callee)
                .where("status", "in", ["connecting", "connected", "reconnecting"])
                .limit(1)
                .get();

            if (!busy.empty) {
                await snap.ref.update({
                    status: "ended",
                    endReason: "busy",
                    endedBy: callee,
                    endedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
                return;
            }

            const devices = await db
                .collection("users")
                .doc(callee)
                .collection("devices")
                .get();

            // Fan out to EVERY device the user owns; the accept transaction decides
            // which one wins.
            const tokens = devices.docs.map((d) => d.data().fcmToken).filter(Boolean);
            if (!tokens.length) continue;

            await admin.messaging().sendEachForMulticast({
                tokens,
                data: {
                    kind: "incoming_call",
                    callId: snap.id,
                    type: call.type,
                    callerId: call.callerId,
                    callerName,
                },
                android: { priority: "high", ttl: RING_TIMEOUT_MS },
                apns: {
                    headers: {
                        "apns-push-type": "voip",
                        "apns-priority": "10",
                        "apns-expiration": String(
                            Math.floor((Date.now() + RING_TIMEOUT_MS) / 1000)
                        ),
                    },
                },
            });
        }
    });

// ---------------------------------------------------------------------------
// 3. Reaper — calls whose caller process died, or that nobody answered
// ---------------------------------------------------------------------------

export const reapStaleCalls = functions.pubsub
    .schedule("every 1 minutes")
    .onRun(async () => {
        const now = admin.firestore.Timestamp.now();

        const unanswered = await db
            .collection("calls")
            .where("status", "in", ["dialing", "ringing"])
            .where("expiresAt", "<", now)
            .get();

        const batch = db.batch();
        unanswered.docs.forEach((d) =>
            batch.update(d.ref, {
                status: "ended",
                endReason: "missed",
                endedAt: admin.firestore.FieldValue.serverTimestamp(),
            })
        );

        // Connected calls whose heartbeats went silent (process killed mid-call).
        const live = await db
            .collection("calls")
            .where("status", "in", ["connected", "reconnecting"])
            .get();

        live.docs.forEach((d) => {
            const beats = (d.data().heartbeats ?? {}) as Record<
                string,
                admin.firestore.Timestamp
            >;
            const newest = Object.values(beats)
                .map((t) => t.toMillis())
                .reduce((a, b) => Math.max(a, b), 0);
            if (Date.now() - newest > HEARTBEAT_STALE_MS) {
                batch.update(d.ref, {
                    status: "ended",
                    endReason: "networkLost",
                    endedAt: admin.firestore.FieldValue.serverTimestamp(),
                });
            }
        });

        await batch.commit();
    });

// ---------------------------------------------------------------------------
// 4. Duration + history fan-out on end
// ---------------------------------------------------------------------------

export const onCallEnded = functions.firestore
    .document("calls/{callId}")
    .onUpdate(async (change) => {
        const before = change.before.data();
        const after = change.after.data();
        if (before.status === "ended" || after.status !== "ended") return;

        const connectedAt = after.connectedAt as admin.firestore.Timestamp | null;
        const endedAt = after.endedAt as admin.firestore.Timestamp | null;
        const durationSec =
            connectedAt && endedAt
                ? Math.max(0, Math.round(endedAt.toMillis() - connectedAt.toMillis()) / 1000)
                : 0;

        await change.after.ref.update({ durationSec });

        // Cancel the native ringing UI on every callee device.
        for (const uid of after.participantIds as string[]) {
            const devices = await db
                .collection("users").doc(uid).collection("devices").get();
            const tokens = devices.docs.map((d) => d.data().fcmToken).filter(Boolean);
            if (tokens.length) {
                await admin.messaging().sendEachForMulticast({
                    tokens,
                    data: { kind: "call_cancelled", callId: change.after.id },
                    android: { priority: "high" },
                });
            }
        }

        // Write one history entry per participant.
        const batch = db.batch();
        for (const uid of after.participantIds as string[]) {
            const ref = db
                .collection("users").doc(uid)
                .collection("callHistory").doc(change.after.id);
            batch.set(ref, {
                callId: change.after.id,
                type: after.type,
                direction: after.callerId === uid ? "outgoing" : "incoming",
                peerIds: (after.participantIds as string[]).filter((p) => p !== uid),
                conversationId: after.conversationId,
                endReason: after.endReason,
                durationSec,
                createdAt: after.createdAt,
                endedAt: after.endedAt,
            });
        }
        await batch.commit();
    });