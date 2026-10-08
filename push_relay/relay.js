const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const serviceAccount = require("./serviceAccountKey.json");

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();
const messaging = getMessaging();

const MAX_AGE_MS = 60_000;
console.log("📡 Push relay running (1:1 + group)...");

async function tokenOf(uid) {
    const doc = await db.collection("users").doc(uid).get();
    return doc.data()?.fcmToken;
}

async function push(uid, data) {
    const token = await tokenOf(uid);
    if (!token) {
        console.log(`⚠️ no fcmToken for ${uid}`);
        return;
    }
    await messaging.send({
        token,
        data,
        android: { priority: "high", ttl: 45_000 },
    });
    console.log(`✅ ${data.type} → ${uid} (${data.callId})`);
}

async function safe(fn) {
    try { await fn(); } catch (e) { console.error("❌ push failed:", e.message); }
}

// ---------------------------------------------------------------- 1:1 (unchanged)
const sent = new Set();
db.collection("calls").where("state", "==", "ringing").onSnapshot(
    async (snap) => {
        for (const change of snap.docChanges()) {
            if (change.type === "removed") continue;
            const callId = change.doc.id;
            if (sent.has(callId)) continue;
            const call = change.doc.data();
            const createdMs = call.createdAt?.toMillis?.() ?? 0;
            if (Date.now() - createdMs > MAX_AGE_MS) continue;
            sent.add(callId);
            const callerName =
                call.callerName ??
                (await db.collection("users").doc(call.callerId).get()).data()?.username ??
                "Unknown";
            await safe(() =>
                push(call.calleeId, {
                    type: "incoming_call",
                    callId,
                    roomName: call.roomName ?? callId,
                    callerName,
                    callType: call.type ?? "voice",
                })
            );
        }
    },
    (err) => console.error("❌ calls listener:", err)
);

// ---------------------------------------------------------------- group
const groupPushed = new Map(); // callId -> Set(uid) already pushed
let firstGroupSnapshot = true;

db.collection("groupCalls").where("state", "==", "active").onSnapshot(
    async (snap) => {
        const initial = firstGroupSnapshot;
        firstGroupSnapshot = false;

        for (const change of snap.docChanges()) {
            const callId = change.doc.id;
            const d = change.doc.data();

            if (change.type === "removed") {
                // Call ended: stop the ringing on phones that never answered.
                for (const uid of groupPushed.get(callId) ?? []) {
                    if (d.statuses?.[uid] === "invited") {
                        await safe(() => push(uid, { type: "group_call_cancelled", callId }));
                    }
                }
                groupPushed.delete(callId);
                continue;
            }

            if (initial && Date.now() - (d.createdAt?.toMillis?.() ?? 0) > MAX_AGE_MS) continue;

            const pushed = groupPushed.get(callId) ?? new Set();
            groupPushed.set(callId, pushed);
            const invited = d.invitedIds ?? [];

            // New invitees (also covers a future mid-call invite).
            for (const uid of invited) {
                if (uid === d.callerId || pushed.has(uid)) continue;
                pushed.add(uid);
                await safe(() =>
                    push(uid, {
                        type: "incoming_group_call",
                        callId,
                        roomName: d.roomName ?? callId,
                        callerName: d.callerName ?? "Unknown",
                        callType: d.type ?? "video",
                    })
                );
            }

            // Invitees who stopped ringing without joining (missed / declined elsewhere).
            for (const uid of [...pushed]) {
                if (invited.includes(uid)) continue;
                const status = d.statuses?.[uid];
                if (status === "joined" || status === "left") continue;
                pushed.delete(uid);
                await safe(() => push(uid, { type: "group_call_cancelled", callId }));
            }
        }
    },
    (err) => console.error("❌ groupCalls listener:", err)
);