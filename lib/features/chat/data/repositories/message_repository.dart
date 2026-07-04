import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/features/chat/data/models/message.dart';

class MessageRepository {
  MessageRepository();

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  /// ------------------------------------------------------------
  /// Firestore Collection Reference
  /// ------------------------------------------------------------
  CollectionReference<Map<String, dynamic>> get messagesCollection =>
      _firebaseFirestore.collection('messages');

  DocumentReference<Map<String, dynamic>> createMessageDocument() {
    return messagesCollection.doc();
  }

  /// ------------------------------------------------------------
  /// Send a new message
  /// ------------------------------------------------------------
  Future<void> sendMessage(Message message) async {
    await messagesCollection.doc(message.id).set(message.toMap());
  }

  /// ------------------------------------------------------------
  /// Listen to messages in real-time
  /// ------------------------------------------------------------
  Stream<List<Message>> getMessages() {
    return messagesCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Message.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  /// ------------------------------------------------------------
  /// Get a single message
  /// ------------------------------------------------------------
  Future<Message?> getMessage(String messageId) async {
    final document = await messagesCollection.doc(messageId).get();

    if (!document.exists) {
      return null;
    }

    return Message.fromMap(document.id, document.data()!);
  }

  /// ------------------------------------------------------------
  /// Delete message
  /// ------------------------------------------------------------
  Future<void> deleteMessage(String messageId) async {
    await messagesCollection.doc(messageId).delete();
  }
}
