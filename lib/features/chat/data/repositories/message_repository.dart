import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/features/chat/data/models/message.dart';

class MessageRepository {
  MessageRepository();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ------------------------------------------------------------
  /// Messages collection inside a conversation
  /// conversations/{conversationId}/messages
  /// ------------------------------------------------------------
  CollectionReference<Map<String, dynamic>> messagesCollection(
    String conversationId,
  ) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages');
  }

  /// ------------------------------------------------------------
  /// Create empty document (used before sending)
  /// ------------------------------------------------------------
  DocumentReference<Map<String, dynamic>> createMessageDocument(
    String conversationId,
  ) {
    return messagesCollection(conversationId).doc();
  }

  /// ------------------------------------------------------------
  /// Send message
  /// ------------------------------------------------------------
  Future<void> sendMessage({
    required String conversationId,
    required Message message,
  }) async {
    await messagesCollection(
      conversationId,
    ).doc(message.id).set(message.toMap());
  }

  /// ------------------------------------------------------------
  /// Real-time messages
  /// ------------------------------------------------------------
  Stream<List<Message>> messageStream(String conversationId) {
    return messagesCollection(conversationId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Message.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// ------------------------------------------------------------
  /// Alias
  /// ------------------------------------------------------------
  Stream<List<Message>> getMessages(String conversationId) {
    return messageStream(conversationId);
  }

  /// ------------------------------------------------------------
  /// Get one message
  /// ------------------------------------------------------------
  Future<Message?> getMessage({
    required String conversationId,
    required String messageId,
  }) async {
    final document = await messagesCollection(
      conversationId,
    ).doc(messageId).get();

    if (!document.exists) {
      return null;
    }

    return Message.fromMap(document.id, document.data()!);
  }

  /// ------------------------------------------------------------
  /// Latest message
  /// ------------------------------------------------------------
  Future<Message?> getLatestMessage(String conversationId) async {
    final snapshot = await messagesCollection(
      conversationId,
    ).orderBy('createdAt', descending: true).limit(1).get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return Message.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  /// ------------------------------------------------------------
  /// Delete message
  /// ------------------------------------------------------------
  // Future<void> deleteMessage({
  //   required String conversationId,
  //   required String messageId,
  // }) async {
  //   await messagesCollection(conversationId).doc(messageId).delete();
  // }
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  /// ------------------------------------------------------------
  /// Delete message
  /// ------------------------------------------------------------
  Future<void> deleteMessageForMe({
    required String conversationId,
    required String messageId,
    required String userId,
  }) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update({
          'deletedBy': FieldValue.arrayUnion([userId]),
        });
  }

  /// ------------------------------------------------------------
  /// Delete message
  /// ------------------------------------------------------------
  Future<void> deleteMessageForEveryone({
    required String conversationId,
    required String messageId,
  }) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update({'deletedForEveryone': true, 'deletedAt': Timestamp.now()});
  }

  /// ------------------------------------------------------------
  /// Read receipt
  /// ------------------------------------------------------------
  Future<void> markMessageAsRead({
    required String conversationId,
    required String messageId,
    required String userId,
  }) async {
    await messagesCollection(conversationId).doc(messageId).update({
      'readBy': FieldValue.arrayUnion([userId]),
    });
  }

  /// ------------------------------------------------------------
  /// Has user read?
  /// ------------------------------------------------------------
  bool hasUserRead({required Message message, required String userId}) {
    return message.readBy.contains(userId);
  }
}
