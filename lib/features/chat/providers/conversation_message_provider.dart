import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/data/repositories/conversation_message_repository.dart';

/// ------------------------------------------------------------
/// Conversation Message Repository Provider
/// One repository instance per conversation.
/// ------------------------------------------------------------
final conversationMessageRepositoryProvider =
    Provider.family<ConversationMessageRepository, String>((
      ref,
      conversationId,
    ) {
      return ConversationMessageRepository(conversationId: conversationId);
    });

/// ------------------------------------------------------------
/// Conversation Messages Stream Provider
/// Real-time messages for one conversation.
/// ------------------------------------------------------------
final conversationMessagesProvider =
    StreamProvider.family<List<Message>, String>((ref, conversationId) {
      final repository = ref.watch(
        conversationMessageRepositoryProvider(conversationId),
      );

      return repository.messageStream();
    });

// final currentUserIdProvider = Provider<String?>((ref) {
//   return FirebaseAuth.instance.currentUser?.uid;
// });
