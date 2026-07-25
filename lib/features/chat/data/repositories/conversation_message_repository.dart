import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/data/repositories/message_repository.dart';

class ConversationMessageRepository {
  ConversationMessageRepository({
    required this.conversationId,
    required MessageRepository messageRepository,
  }) : _messageRepository = messageRepository;

  final String conversationId;

  final MessageRepository _messageRepository;

  /// ------------------------------------------------------------
  /// Create document
  /// ------------------------------------------------------------
  DocumentReference<Map<String, dynamic>> createMessageDocument() {
    return _messageRepository.createMessageDocument(conversationId);
  }

  /// ------------------------------------------------------------
  /// Send
  /// ------------------------------------------------------------
  Future<void> sendMessage(Message message) {
    return _messageRepository.sendMessage(
      conversationId: conversationId,
      message: message,
    );
  }

  /// ------------------------------------------------------------
  /// Stream
  /// ------------------------------------------------------------
  Stream<List<Message>> getMessages() {
    return _messageRepository.getMessages(conversationId);
  }

  /// ------------------------------------------------------------
  /// Get one
  /// ------------------------------------------------------------
  Future<Message?> getMessage(String messageId) {
    return _messageRepository.getMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  /// ------------------------------------------------------------
  /// Latest
  /// ------------------------------------------------------------
  Future<Message?> getLatestMessage() {
    return _messageRepository.getLatestMessage(conversationId);
  }

  /// ------------------------------------------------------------
  /// Delete
  /// ------------------------------------------------------------
  Future<void> deleteMessage(String messageId) {
    return _messageRepository.deleteMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }
  // ------------------------------------------------------------
  // Delete for me
  // ------------------------------------------------------------

  Future<void> deleteForMe({
    required String messageId,
    required String userId,
  }) async {
    await _messageRepository.deleteMessageForMe(
      conversationId: conversationId,
      messageId: messageId,
      userId: userId,
    );
  }

  // ------------------------------------------------------------
  // Delete for everyone
  // ------------------------------------------------------------
  Future<void> deleteForEveryone({required String messageId}) async {
    await _messageRepository.deleteMessageForEveryone(
      conversationId: conversationId,
      messageId: messageId,
    );
  }

  /// ------------------------------------------------------------
  /// Read receipt
  /// ------------------------------------------------------------
  Future<void> markMessageAsRead({
    required String messageId,
    required String userId,
  }) {
    return _messageRepository.markMessageAsRead(
      conversationId: conversationId,
      messageId: messageId,
      userId: userId,
    );
  }

  /// ------------------------------------------------------------
  /// Has user read?
  /// ------------------------------------------------------------
  bool hasUserRead({required Message message, required String userId}) {
    return _messageRepository.hasUserRead(message: message, userId: userId);
  }
}
