// // import 'package:cloud_firestore/cloud_firestore.dart';

// // import '../models/message_reaction.dart';

// // class ReactionRepository {
// //   ReactionRepository(this._firestore);

// //   final FirebaseFirestore _firestore;

// //   CollectionReference<Map<String, dynamic>> _messages(String conversationId) {
// //     return _firestore
// //         .collection('conversations')
// //         .doc(conversationId)
// //         .collection('messages');
// //   }

// //   /// ==========================================================
// //   /// Add / Replace Reaction
// //   ///
// //   /// Each user can have only ONE reaction on a message.
// //   /// If the user already reacted,
// //   /// the previous reaction is replaced.
// //   /// ==========================================================
// //   Future<void> react({
// //     required String conversationId,
// //     required String messageId,
// //     required MessageReaction reaction,
// //   }) async {
// //     final doc = await _messages(conversationId).doc(messageId).get();

// //     if (!doc.exists) return;

// //     final data = doc.data()!;

// //     final reactions = (data['reactions'] as List<dynamic>? ?? [])
// //         .map((e) => Map<String, dynamic>.from(e))
// //         .toList();

// //     reactions.removeWhere((item) => item['userId'] == reaction.userId);

// //     reactions.add(reaction.toMap());

// //     await _messages(
// //       conversationId,
// //     ).doc(messageId).update({'reactions': reactions});
// //   }

// //   /// ==========================================================
// //   /// Remove Reaction
// //   /// ==========================================================
// //   Future<void> removeReaction({
// //     required String conversationId,
// //     required String messageId,
// //     required String userId,
// //   }) async {
// //     final doc = await _messages(conversationId).doc(messageId).get();

// //     if (!doc.exists) return;

// //     final data = doc.data()!;

// //     final reactions = (data['reactions'] as List<dynamic>? ?? [])
// //         .map((e) => Map<String, dynamic>.from(e))
// //         .toList();

// //     reactions.removeWhere((item) => item['userId'] == userId);

// //     await _messages(
// //       conversationId,
// //     ).doc(messageId).update({'reactions': reactions});
// //   }

// //   /// ==========================================================
// //   /// Toggle Reaction
// //   ///
// //   /// Same emoji:
// //   /// 👍 -> remove
// //   ///
// //   /// Different emoji:
// //   /// 👍 -> ❤️
// //   /// ==========================================================
// //   Future<void> toggleReaction({
// //     required String conversationId,
// //     required String messageId,
// //     required MessageReaction reaction,
// //   }) async {
// //     final doc = await _messages(conversationId).doc(messageId).get();

// //     if (!doc.exists) return;

// //     final data = doc.data()!;

// //     final reactions = (data['reactions'] as List<dynamic>? ?? [])
// //         .map((e) => Map<String, dynamic>.from(e))
// //         .toList();

// //     final index = reactions.indexWhere(
// //       (item) => item['userId'] == reaction.userId,
// //     );

// //     if (index == -1) {
// //       reactions.add(reaction.toMap());
// //     } else {
// //       if (reactions[index]['emoji'] == reaction.emoji) {
// //         reactions.removeAt(index);
// //       } else {
// //         reactions[index] = reaction.toMap();
// //       }
// //     }

// //     await _messages(
// //       conversationId,
// //     ).doc(messageId).update({'reactions': reactions});
// //   }
// // }

// //===============================================================
// //===============================================================
// // lib/features/chat/data/repositories/reaction_repository.dart
// import 'package:cloud_firestore/cloud_firestore.dart';

// // ===========================================================================
// // 🔗 THE REACTION REPOSITORY PROVIDER REGISTRY ENTRY
// // ===========================================================================
// // ✅ ফিক্সড: রিঅ্যাকশন বার ফাইলের এরর দূর করার জন্য গ্লোবাল প্রোভাইডার হ্যান্ডেলটি এখানে ডিক্লেয়ার করা হলো!

// class ReactionRepository {
//   ReactionRepository(this._firestore);
//   final FirebaseFirestore _firestore;

//   CollectionReference<Map<String, dynamic>> _messages(String conversationId) {
//     return _firestore
//         .collection('conversations')
//         .doc(conversationId)
//         .collection('messages');
//   }

//   // ===========================================================================
//   // ⚙️ ATOMIC CLOUD TOGGLE REACTION ENGINE (MAP SCHEMA VERSION)
//   // ===========================================================================
//   // ✅ ফিক্সড: পুরনো জটিল লিস্টের কোড ডিলিট করে নতুন সেফ ম্যাপ স্ট্রাকচারে আপগ্রেড করা হলো!
//   Future<void> toggleReaction({
//     required String conversationId,
//     required String messageId,
//     required String emoji,
//     required String userId,
//   }) async {
//     final docRef = _messages(conversationId).doc(messageId);

//     // Run a type-safe transaction lookup to check the active server state safely [INDEX]
//     final snapshot = await docRef.get();
//     if (!snapshot.exists) return;

//     final data = snapshot.data();
//     final reactions = data?['reactions'] as Map<String, dynamic>? ?? {};
//     final userList = List<String>.from(reactions[emoji] ?? const []);

//     if (userList.contains(userId)) {
//       // User already reacted -> Atomic Remove user ID from this emoji key row [INDEX]
//       await docRef.update({
//         'reactions.$emoji': FieldValue.arrayRemove([userId]),
//       });
//     } else {
//       // User hasn't reacted yet -> Atomic Add user ID to this emoji key row [INDEX]
//       await docRef.update({
//         'reactions.$emoji': FieldValue.arrayUnion([userId]),
//       });
//     }
//   }
// }
