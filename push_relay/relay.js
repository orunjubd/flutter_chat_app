const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const serviceAccount = require("./serviceAccountKey.json");

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();
const messaging = getMessaging();

const sent = new Set();          // avoid pushing twice for one call
const MAX_AGE_MS = 60_000;       // ignore stale ringing docs

console.log("📡 Push relay running. Watching calls with state=ringing...");

db.collection("calls")
    .where("state", "==", "ringing")
    .onSnapshot(
        async (snap) => {
            for (const change of snap.docChanges()) {
                if (change.type === "removed") continue;

                const callId = change.doc.id;
                if (sent.has(callId)) continue;

                const call = change.doc.data();
                const createdMs = call.createdAt?.toMillis?.() ?? 0;
                if (Date.now() - createdMs > MAX_AGE_MS) {
                    console.log(`🕰️ skip stale call ${callId}`);
                    continue;
                }
                sent.add(callId);

                try {
                    const calleeDoc = await db.collection("users").doc(call.calleeId).get();
                    const fcmToken = calleeDoc.data()?.fcmToken;
                    if (!fcmToken) {
                        console.log(`⚠️ no fcmToken for callee ${call.calleeId}`);
                        continue;
                    }

                    const callerName =
                        call.callerName ??
                        (await db.collection("users").doc(call.callerId).get()).data()?.username ??
                        "Unknown";

                    await messaging.send({
                        token: fcmToken,
                        data: {
                            type: "incoming_call",
                            callId,
                            roomName: call.roomName ?? callId,
                            callerName,
                            callType: call.type ?? "voice",
                        },
                        android: { priority: "high", ttl: 45000 },
                    });
                    console.log(`✅ push sent: call ${callId} → ${call.calleeId}`);
                } catch (e) {
                    console.error(`❌ push failed for ${callId}:`, e.message);
                }
            }
        },
        (err) => console.error("❌ listener error:", err)
    );