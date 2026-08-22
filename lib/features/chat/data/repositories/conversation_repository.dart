import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/data/models/message.dart';

class ConversationRepository {
  ConversationRepository();

  final _db = FirebaseFirestore.instance;

  //final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _dbCol =>
      _db.collection('conversations');

  ///------------------------------------------------------------
  /// Create conversation document reference
  ///------------------------------------------------------------
  DocumentReference<Map<String, dynamic>> createConversationDocument() {
    return _dbCol.doc();
  }

  ///------------------------------------------------------------
  /// Create a conversation
  ///------------------------------------------------------------
  Future<void> createConversation(Conversation conversation) async {
    await _dbCol.doc(conversation.id).set(conversation.toFirestore());
  }

  ///------------------------------------------------------------
  /// Stream all conversations
  /// 🚀 SECURED ISOLATED STREAM QUERY: Filters out all third-party room logs completely
  ///------------------------------------------------------------
  Stream<List<Conversation>> conversationStream({
    required String currentUserId,
  }) {
    return _dbCol
        .where(
          'participantIds',
          arrayContains: currentUserId,
        ) // 🛡️ Bulletproof privacy shield constraint
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Conversation.fromFirestore).toList());
  }

  // Stream<List<Conversation>> conversationStream() {
  //   return _dbCol
  //       .orderBy('updatedAt', descending: true)
  //       .snapshots()
  //       .map(
  //         (snapshot) => snapshot.docs.map(Conversation.fromFirestore).toList(),
  //       );
  // }

  ///------------------------------------------------------------
  /// Find conversation by participants
  ///------------------------------------------------------------

  Future<Conversation?> findConversation(List<String> participantIds) async {
    // Participant IDs must already be sorted array sequences before reaching here
    final snap = await _dbCol
        .where('participantIds', isEqualTo: participantIds)
        .get();

    if (snap.docs.isNotEmpty) {
      return Conversation.fromFirestore(snap.docs.first);
    }
    return null;
  }

  // Future<Conversation?> findConversation(List<String> participantIds) async {
  //   final snapshot = await _dbCol
  //       .where('participantIds', arrayContainsAny: participantIds)
  //       .get();

  //   for (final doc in snapshot.docs) {
  //     final conversation = Conversation.fromFirestore(doc);

  //     final ids = conversation.participantIds.toSet();

  //     if (ids.length == participantIds.length &&
  //         ids.containsAll(participantIds)) {
  //       return conversation;
  //     }
  //   }

  //   return null;
  // }

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
      //typingStatus: [],
      //messages: [],
      unreadCounts: {participants[0]: 0, participants[1]: 0},
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
    await _dbCol.doc(conversationId).update({
      'lastMessage': lastMessage,
      'lastMessageTime': timestamp,
      'updatedAt': timestamp,
    });
  }

  ///------------------------------------------------------------
  /// Update conversation after sending a message
  ///------------------------------------------------------------
  Future<void> updateConversationAfterMessage({
    required String conversationId,
    required String lastMessage,
  }) async {
    final now = Timestamp.now();

    await _dbCol.doc(conversationId).update({
      'lastMessage': lastMessage,
      'lastMessageTime': now,
      'updatedAt': now,
    });
  }
  //------------------------------------------------------------
  /// Update conversation preview
  ///------------------------------------------------------------

  Future<void> updateConversationPreview({
    required String conversationId,
    required Message message,
  }) async {
    final preview = switch (message) {
      VideoMessage() => '🎥 Video',

      LegacyMessage m when m.type == 'image' =>
        m.caption?.trim().isNotEmpty == true ? '📷 ${m.caption}' : '📷 Photo',

      LegacyMessage m when m.type == 'audio' => '🎤 Voice message',

      LegacyMessage m when m.type == 'file' => '📄 Document',

      _ => message.text,
    };

    await _dbCol.doc(conversationId).update({
      'lastMessage': preview,
      'lastMessageTime': message.createdAt,
      'updatedAt': message.createdAt,
    });
  }

  ///------------------------------------------------------------
  /// Increment unread count for all participants except the sender
  ///------------------------------------------------------------
  Future<void> incrementUnread({
    required Conversation conversation,
    required String senderId,
  }) async {
    final updates = <String, Object>{};

    for (final participant in conversation.participantIds) {
      if (participant == senderId) continue;

      updates['unreadCounts.$participant'] = FieldValue.increment(1);
    }

    await _dbCol.doc(conversation.id).update(updates);
  }

  ///------------------------------------------------------------
  /// Clear unread count for a specific user
  ///------------------------------------------------------------
  Future<void> clearUnread({
    required String conversationId,
    required String userId,
  }) async {
    await _dbCol.doc(conversationId).update({'unreadCounts.$userId': 0});
  }

  ///------------------------------------------------------------
  /// Clear conversation preview
  /// ------------------------------------------------------------
  Future<void> clearConversationPreview({
    required String conversationId,
  }) async {
    await _dbCol.doc(conversationId).update({
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }
}
