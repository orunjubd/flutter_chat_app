import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/features/chat/data/models/conversation.dart';

class ConversationRepository {
  ConversationRepository();

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get conversationsCollection =>
      _firebaseFirestore.collection('conversations');

  ///------------------------------------------------------------
  /// Create conversation document reference
  ///------------------------------------------------------------
  DocumentReference<Map<String, dynamic>> createConversationDocument() {
    return conversationsCollection.doc();
  }

  ///------------------------------------------------------------
  /// Create a conversation
  ///------------------------------------------------------------
  Future<void> createConversation(Conversation conversation) async {
    await conversationsCollection
        .doc(conversation.id)
        .set(conversation.toFirestore());
  }

  ///------------------------------------------------------------
  /// Stream all conversations
  ///------------------------------------------------------------
  Stream<List<Conversation>> conversationStream() {
    return conversationsCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(Conversation.fromFirestore).toList(),
        );
  }

  ///------------------------------------------------------------
  /// Find conversation by participants
  ///------------------------------------------------------------
  Future<Conversation?> findConversation(List<String> participantIds) async {
    final snapshot = await conversationsCollection
        .where('participantIds', arrayContainsAny: participantIds)
        .get();

    for (final doc in snapshot.docs) {
      final conversation = Conversation.fromFirestore(doc);

      final ids = conversation.participantIds.toSet();

      if (ids.length == participantIds.length &&
          ids.containsAll(participantIds)) {
        return conversation;
      }
    }

    return null;
  }

  ///------------------------------------------------------------
  /// Create or open a conversation
  ///------------------------------------------------------------
  Future<Conversation> createOrOpenConversation({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final participants = [currentUserId, otherUserId]..sort();

    final existing = await findConversation(participants);

    if (existing != null) {
      return existing;
    }

    final document = createConversationDocument();

    final now = Timestamp.now();

    final conversation = Conversation(
      id: document.id,
      participantIds: participants,
      createdAt: now,
      updatedAt: now,
      lastMessage: '',
      lastMessageTime: now,
    );

    await createConversation(conversation);

    return conversation;
  }

  ///------------------------------------------------------------
  /// Update last message
  ///------------------------------------------------------------
  Future<void> updateLastMessage({
    required String conversationId,
    required String lastMessage,
    required Timestamp timestamp,
  }) async {
    await conversationsCollection.doc(conversationId).update({
      'lastMessage': lastMessage,
      'lastMessageTime': timestamp,
      'updatedAt': timestamp,
    });
  }
}
