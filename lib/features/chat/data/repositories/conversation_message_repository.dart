import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/data/repositories/message_repository.dart';
import 'package:chat_app/features/chat/data/repositories/conversation_repository.dart';
import 'package:flutter/material.dart';

class ConversationMessageRepository {
  ConversationMessageRepository({
    required this.conversationId,
    required MessageRepository messageRepository,
    required ConversationRepository conversationRepository,
  }) : _messageRepository = messageRepository,
       _conversationRepository = conversationRepository;

  final String conversationId;

  final MessageRepository _messageRepository;

  final ConversationRepository _conversationRepository;

  /// ------------------------------------------------------------
  /// Create document
  /// ------------------------------------------------------------
  DocumentReference<Map<String, dynamic>> createMessageDocument() {
    return _messageRepository.createMessageDocument(conversationId);
  }

  Future<void> editTextMessage({
    required String messageId,
    required String userId,
    required String newText,
  }) => _messageRepository.editTextMessage(
    conversationId: conversationId,
    messageId: messageId,
    userId: userId,
    newText: newText,
  );

  /// ------------------------------------------------------------
  /// Forward
  /// ------------------------------------------------------------
  Future<void> forwardMessage({
    required Message originalMessage,
    required String currentUserId,
    required String currentUserName,
  }) async {
    final document = _messageRepository.createMessageDocument(conversationId);

    final forwardedMessage = originalMessage.asForwarded(
      newId: document.id,
      senderId: currentUserId,
      senderName: currentUserName,
      createdAt: Timestamp.now(),
      readBy: [currentUserId],
      forwardedFromUserId: originalMessage.senderId,
      forwardedFromUserName: originalMessage.senderName,
    );

    await document.set(forwardedMessage.toMap());
  }

  /// ------------------------------------------------------------
  /// Send
  /// ------------------------------------------------------------
  Future<void> sendMessage(Message message) async {
    debugPrint('🚀 [DEBUG] Starting sendMessage Flow...');
    debugPrint(
      '📦 [DEBUG] Message ID: ${message.id}, Sender: ${message.senderName}, Type: ${message.type}',
    );
    debugPrint(
      '📝 [Repository] sendMessage pipeline initialized for: ${message.id}',
    );
    try {
      // Step A: Save message
      debugPrint('⏳ [DEBUG] Step A: Saving message to Firestore...');
      await _messageRepository.sendMessage(
        conversationId: conversationId,
        message: message,
      );
      debugPrint('✅ [DEBUG] Step A Complete: Message saved.');

      // Step B: Update conversation
      debugPrint('⏳ [DEBUG] Step B: Updating conversation metadata...');
      await _conversationRepository.updateConversationAfterMessage(
        conversationId: conversationId,
        lastMessage: switch (message.type) {
          'image' => '📷 Photo',
          'video' => '🎥 Video',
          'voice' => '🎤 Voice message',
          'file' => '📎 File',
          'location' => '📍 Location',
          'call_system' => '📞 Call',

          _ => message.text,
        },
        lastSenderName: message.senderName,
      );
      debugPrint(
        '📡 [Repository] Step B complete: Parent conversation preview fields updated.',
      );

      // Step C: Increment the unread counts array maps for other group participants
      // example: await incrementUnread(conversationId, message.senderId);
      debugPrint(
        '⏳ [DEBUG] Step C: Incrementing unread counts for peer participants...',
      );
      await _conversationRepository.incrementUnread(
        conversationId: conversationId,
        senderId: message.senderId,
      );
      debugPrint(
        '📡 [Repository] Step C complete: Dynamic participant unread fields incremented.',
      );
    } catch (e, st) {
      // ✅ REQUIREMENT MET: Traps all async errors across database levels to prevent silent drops
      debugPrint('❌ [Chat] send failed inside repository stream: $e');
      debugPrintStack(stackTrace: st);
      rethrow; // Forward error upstream to notify parent UI indicators
    }
  }

  /// ------------------------------------------------------------
  /// Update last message
  /// ------------------------------------------------------------
  Future<void> sendConversationMessage({required Message message}) async {
    await sendMessage(message);

    await _conversationRepository.updateConversationPreview(
      conversationId: conversationId,
      message: message,
    );
  }

  /// ------------------------------------------------------------
  /// Send image message
  /// ------------------------------------------------------------

  Future<void> sendImageMessage({required Message message}) async {
    await sendMessage(message);

    await _conversationRepository.updateConversationPreview(
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

  // ------------------------------------------------------------
  // Toggle reaction
  // ------------------------------------------------------------
  Future<void> toggleReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) {
    return _messageRepository.toggleReaction(
      conversationId: conversationId,
      messageId: messageId,
      userId: userId,
      emoji: emoji,
    );
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
