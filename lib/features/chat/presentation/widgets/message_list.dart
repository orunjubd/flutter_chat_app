import 'package:chat_app/features/chat/presentation/widgets/message_date_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';
//import 'package:chat_app/features/chat/providers/message_provider.dart';
import 'package:chat_app/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_animation.dart';
import 'package:chat_app/core/utils/firebase_error_mapper.dart';
import 'package:chat_app/core/dialogs/app_snackbar.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/chat/providers/message_scroll_provider.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList({
    super.key,
    required this.scrollController,
    required this.conversationId,

    this.highlightMessageId,
  });

  final ScrollController scrollController;
  final String conversationId;

  final String? highlightMessageId;

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  // void _scrollToBottom() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (!widget.scrollController.hasClients) return;

  //     widget.scrollController.animateTo(
  //       widget.scrollController.position.maxScrollExtent,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      conversationMessagesProvider(widget.conversationId),
    );
    final currentUserId = ref.read(currentUserIdProvider);
    final scrollEngine = ref.read(messageScrollControllerProvider);

    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, _) => Center(
        child: Text(
          FirebaseErrorMapper.message(error),
          style: context.errorText,
        ),
      ),

      data: (messages) {
        // Security Guard Anchor
        if (currentUserId == null) {
          return const SizedBox.shrink();
        }

        // 🚀 UPSTREAM FILTERING MATRIX: Eliminates hidden text bubbles before it hits the UI layout tree
        final visibleMessages = messages.where((message) {
          return !message.deletedBy.contains(currentUserId);
        }).toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          scrollEngine.onMessageCountChanged(visibleMessages.length);
        });

        if (visibleMessages.isEmpty) {
          return Center(
            child: Text('No messages yet.', style: context.subtitleText),
          );
        }
        return ScrollablePositionedList.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          initialScrollIndex: visibleMessages.isEmpty
              ? 0
              : visibleMessages.length - 1,
          itemScrollController: scrollEngine.itemScrollController,

          itemPositionsListener: scrollEngine.itemPositionsListener,
          physics: const BouncingScrollPhysics(),
          reverse: false,
          itemCount: visibleMessages.length,
          itemBuilder: (context, index) {
            final message = visibleMessages[index];

            final currentDate = message.createdAt.toDate();

            final previousDate = index == 0
                ? null
                : visibleMessages[index - 1].createdAt.toDate();

            final showDateSeparator =
                previousDate == null ||
                currentDate.year != previousDate.year ||
                currentDate.month != previousDate.month ||
                currentDate.day != previousDate.day;

            final isHighlighted = widget.highlightMessageId == message.id;

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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showDateSeparator) MessageDateSeparator(date: currentDate),

                // Return your animated chat bubble viewport wrappers down here seamlessly!
                MessageAnimation(
                  key: ValueKey(message.id),
                  child: ChatBubble(
                    key: ValueKey(message.id),
                    messageData: message,
                    //conversationId: widget.conversationId,
                    isMe: isMe,
                    isRead: isRead,
                    highlight: isHighlighted,
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
                ),
              ],
            );
          },
        );
      },
    );
  }
}
