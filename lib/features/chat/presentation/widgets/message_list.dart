import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';
//import 'package:chat_app/features/chat/providers/message_provider.dart';
import 'package:chat_app/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_animation.dart';
import 'package:chat_app/core/utils/firebase_error_mapper.dart';
import 'package:chat_app/core/dialogs/app_snackbar.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList({
    super.key,
    required this.scrollController,
    required this.conversationId,
  });

  final ScrollController scrollController;
  final String conversationId;

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.scrollController.hasClients) return;

      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      conversationMessagesProvider(widget.conversationId),
    );

    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, _) => Center(
        child: Text(
          FirebaseErrorMapper.message(error),
          style: context.errorText,
        ),
      ),

      data: (messages) {
        final currentUserId = ref.read(currentUserIdProvider);

        // Security Guard Anchor
        if (currentUserId == null) {
          return const SizedBox.shrink();
        }

        // 🚀 UPSTREAM FILTERING MATRIX: Eliminates hidden text bubbles before it hits the UI layout tree
        final visibleMessages = messages.where((message) {
          return !message.deletedBy.contains(currentUserId);
        }).toList();

        _scrollToBottom();
        if (visibleMessages.isEmpty) {
          return Center(
            child: Text('No messages yet.', style: context.subtitleText),
          );
        }

        return ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: visibleMessages.length,
          itemBuilder: (context, index) {
            final message = visibleMessages[index];

            final repository = ref.read(
              conversationMessageRepositoryProvider(widget.conversationId),
            );
            //final repository = ref.read(messageRepositoryProvider);
            final isRead = message.readBy.length > 1;
            final isMe = message.senderId == currentUserId;

            // 🚀 2. THE ENTERPRISE AUTOMATED READ RECEIPT TRIGGER BATCH FILTER
            if (!isMe && !message.readBy.contains(currentUserId)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                repository.markMessageAsRead(
                  messageId: message.id,
                  userId: currentUserId,
                );
              });
            }

            // Return your animated chat bubble viewport wrappers down here seamlessly!
            return MessageAnimation(
              key: ValueKey(message.id),
              child: ChatBubble(
                key: ValueKey(message.id),
                messageData: message,
                //conversationId: widget.conversationId,
                isMe: isMe,
                isRead: isRead,
                onReaction: (emoji) async {
                  await repository.toggleReaction(
                    messageId: message.id,
                    emoji: emoji,
                    userId: currentUserId,
                  );

                  if (!context.mounted) return;

                  AppSnackBar.info(context, 'Reaction updated');
                },

                onDeleteForMe: () async {
                  await repository.deleteForMe(
                    messageId: message.id,
                    userId: currentUserId,
                  );
                  if (!context.mounted) return;
                  AppSnackBar.info(context, 'Message deleted for you');
                },

                onDeleteForEveryone: isMe
                    ? () async {
                        await repository.deleteForEveryone(
                          messageId: message.id,
                        );
                        if (!context.mounted) return;
                        AppSnackBar.info(
                          context,
                          'Message deleted for everyone',
                        );
                      }
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
