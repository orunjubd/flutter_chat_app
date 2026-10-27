const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
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

async function push(uid, data, ttl = 45_000) {
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
    console.log(`✅ ${data.type} → ${uid} (${data.callId ?? data.conversationId})`);
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
// ---------------------------------------------------------------- messages
const startedAt = Timestamp.now();
const lastSeenTime = new Map();   // conversationId -> lastMessageTime millis
const pushedMessages = new Set(); // messageIds already sent

async function isMuted(uid, conversationId) {
    const s = await db.collection("users").doc(uid)
        .collection("conversationSettings").doc(conversationId).get();
    const until = s.data()?.mutedUntil?.toMillis?.() ?? 0;
    return until > Date.now();
}

async function globalMuted(uid) {
    const s = await db.collection("users").doc(uid)
        .collection("private").doc("settings").get();
    return (s.data()?.mutedUntil?.toMillis?.() ?? 0) > Date.now();
}

db.collection("conversations").where("updatedAt", ">", startedAt).onSnapshot(
    async (snap) => {
        for (const change of snap.docChanges()) {
            if (change.type === "removed") continue;
            const conv = change.doc.data();
            const convId = change.doc.id;

            // only when a new message arrived (not on read receipts or unread resets)
            const t = conv.lastMessageTime?.toMillis?.() ?? 0;
            if (lastSeenTime.get(convId) === t) continue;
            lastSeenTime.set(convId, t);

            await safe(async () => {
                const latest = await change.doc.ref.collection("messages")
                    .orderBy("createdAt", "desc").limit(1).get();
                const msgDoc = latest.docs[0];
                if (!msgDoc || pushedMessages.has(msgDoc.id)) return;
                pushedMessages.add(msgDoc.id);

                const m = msgDoc.data();
                if (["group_system", "call_system"].includes(m.type)) return;
                if (m.deletedForEveryone) return;

                const isGroup = conv.type === "group";
                const title = isGroup ? (conv.name ?? "Group") : (m.senderName ?? "New message");
                const preview = conv.lastMessage ?? "";
                const body = isGroup ? `${m.senderName ?? ""}: ${preview}` : preview;



                const mentionIds = Object.keys(m.mentions ?? {});

                for (const uid of conv.participantIds ?? []) {
                    if (uid === m.senderId) continue;
                    if (await globalMuted(uid)) {
                        console.log(`🔇 global mute ${uid}`);
                        continue;
                    }

                    const mentioned = isGroup && mentionIds.includes(uid);

                    // চ্যাট ম্যুট চেক: মেনশন না করা থাকলে এবং চ্যাট ম্যুট থাকলে নোটিফিকেশন স্কিপ হবে
                    if (!mentioned && await isMuted(uid, convId)) {
                        console.log(`🔇 muted ${uid} ${convId}`);
                        continue;
                    }
                    await safe(() => push(uid, {
                        type: "new_message",
                        conversationId: convId,
                        isGroup: String(isGroup),
                        mention: String(mentioned),
                        title,
                        body: mentioned ? `${m.senderName ?? ""} mentioned you: ${preview}` : body,
                    }, 86_400_000));
                }
            });
        }
    },
    (err) => console.error("❌ conversations listener:", err));