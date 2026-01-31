const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

exports.checkIssueDeadlines = onSchedule("every 5 minutes", async () => {
  const db = admin.firestore();
  const now = admin.firestore.Timestamp.now();

  const snapshot = await db
    .collection("issues")
    .where("deadlineAt", "<=", now)
    .get();

  if (snapshot.empty) return;

  const batch = db.batch();

  snapshot.forEach(doc => {
    const data = doc.data();

    if (data.status === "Resolved") return;
    if (data.isOverdue === true) return;

    batch.update(doc.ref, {
      isOverdue: true,
      escalationLevel: (data.escalationLevel ?? 0) + 1,
      lastEscalatedAt: now,
    });
  });

  await batch.commit();
});
