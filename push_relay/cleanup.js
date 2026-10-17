const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
initializeApp({ credential: cert(require("./serviceAccountKey.json")) });
const db = getFirestore();

const APPLY = process.argv.includes("--apply");
const DAY = 86_400_000;
const ago = (days) => Timestamp.fromMillis(Date.now() - days * DAY);

async function purge(label, query) {
    const snap = await query.get();
    console.log(`${label}: ${snap.size}`);
    if (!APPLY) return;
    for (const doc of snap.docs) await db.recursiveDelete(doc.ref);
}

(async () => {
    console.log(APPLY ? "APPLY MODE" : "dry run (use --apply to delete)");
    await purge("deleted groups (>7 days)",
        db.collection("conversations").where("deletedAt", "<", ago(7)));
    await purge("ended group calls (>30 days)",
        db.collection("groupCalls").where("state", "==", "ended").where("endedAt", "<", ago(30)));
    await purge("stale typing (>1 day)",
        db.collection("typing").where("updatedAt", "<", ago(1)));
})();