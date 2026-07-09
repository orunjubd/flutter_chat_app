import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/typing_status.dart';

class TypingRepository {
  TypingRepository();

  final FirebaseFirestore _firestoreTyping = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _typingCollection =>
      _firestoreTyping.collection('typing');

  /// ------------------------------------------------------------
  /// Update current user's typing state
  /// ------------------------------------------------------------
  Future<void> updateTypingStatus({required TypingStatus status}) async {
    await _typingCollection.doc(status.userId).set({
      ...status.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ------------------------------------------------------------
  /// Listen to all typing users
  /// ------------------------------------------------------------
  Stream<List<TypingStatus>> typingStream() {
    return _typingCollection
        .orderBy('updatedAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(TypingStatus.fromFirestore).toList(),
        );
  }

  /// ------------------------------------------------------------
  /// Stop typing
  /// ------------------------------------------------------------
  Future<void> stopTyping(String userId) async {
    await _typingCollection.doc(userId).update({
      'isTyping': false,
      'updatedAt': Timestamp.now(),
    });
  }
}
