// lib/features/chat/utils/start_conversation.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';
import 'package:chat_app/features/chat/providers/forward_provider.dart';

/// Opens (or creates) a conversation with [otherUserId], and — if a
/// forward is currently pending — forwards it into that conversation.
/// This is the single source of truth for "tap a user, start chatting"
/// behavior; UserSelectionScreen and the People screen both call this
/// rather than each having their own copy.
Future<void> startConversationWithUser({
  required BuildContext context,
  required WidgetRef ref,
  required String otherUserId,
}) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final repository = ref.read(conversationRepositoryProvider);
  final conversation = await repository.createOrOpenConversation(
    currentUserId: currentUser.uid,
    otherUserId: otherUserId,
  );

  if (!context.mounted) return;

  final forwardMessage = ref.read(forwardProvider);
  if (forwardMessage != null) {
    final messageRepository = ref.read(
      conversationMessageRepositoryProvider(conversation.id),
    );
    await messageRepository.forwardMessage(
      originalMessage: forwardMessage,
      currentUserId: currentUser.uid,
      currentUserName: currentUser.displayName ?? '',
    );
    ref.read(forwardProvider.notifier).clear();

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
    );
    return;
  }

  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
  );
}
