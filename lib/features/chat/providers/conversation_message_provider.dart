import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/data/repositories/conversation_message_repository.dart';
import 'package:chat_app/features/chat/providers/message_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';

/// ------------------------------------------------------------
/// Conversation Message Repository Provider
/// One repository instance per conversation.
/// ------------------------------------------------------------
final conversationMessageRepositoryProvider =
    Provider.family<ConversationMessageRepository, String>((
      ref,
      conversationId,
    ) {
      return ConversationMessageRepository(
        conversationId: conversationId,
        messageRepository: ref.read(messageRepositoryProvider),
        conversationRepository: ref.read(conversationRepositoryProvider),
      );
    });

/// ------------------------------------------------------------
/// Conversation Messages Stream Provider
/// Real-time messages for one conversation.
/// ------------------------------------------------------------
final conversationMessagesProvider = StreamProvider.autoDispose
    .family<List<Message>, String>((ref, conversationId) {
      final repository = ref.watch(
        conversationMessageRepositoryProvider(conversationId),
      );

      return repository.getMessages();
    });
