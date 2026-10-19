import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/data/repositories/message_repository.dart';
import 'package:chat_app/features/chat/presentation/widgets/edit_message_dialog.dart';
import 'package:chat_app/features/chat/presentation/widgets/group_sender_label.dart';
import 'package:chat_app/features/chat/presentation/widgets/group_system_bubble.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_date_separator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';
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
    this.showSenderNames = false,
    this.memberCount = 2,
    this.onSenderTap,
    this.canDeleteOthers = false,
    this.visibleFrom,
  });

  final ScrollController scrollController;
  final String conversationId;

  final String? highlightMessageId;
  final bool showSenderNames;
  final int memberCount;
  final void Function(String userId)? onSenderTap;
  final bool canDeleteOthers;
  final DateTime? visibleFrom;

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
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
        final visibleMessages = messages.where((m) {
          if (m.deletedBy.contains(currentUserId)) return false;
          final from = widget.visibleFrom;
          return from == null ||
              m.createdAt.compareTo(Timestamp.fromDate(from)) >= 0;
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

            if (message is GroupSystemMessage) {
              return Column(
                children: [
                  if (showDateSeparator)
                    MessageDateSeparator(date: currentDate),
                  GroupSystemBubble(text: message.text),
                ],
              );
            }

            final isHighlighted = widget.highlightMessageId == message.id;

            final repository = ref.read(
              conversationMessageRepositoryProvider(widget.conversationId),
            );
            final isMe = message.senderId == currentUserId;
            //final repository = ref.read(messageRepositoryProvider);
            final isRead = widget.showSenderNames
                ? message.readBy.length >= widget.memberCount
                : message.readBy.length > 1;
            // 🚀 COMPUTE PROXIMITY CHAIN TO PREVENT REPETITIVE NAME LABELS
            final prev = index == 0 ? null : visibleMessages[index - 1];

            // Only displays the custom label if it is an incoming group message and the sender changes
            final showName =
                widget.showSenderNames &&
                !isMe &&
                (showDateSeparator || prev?.senderId != message.senderId);

            debugPrint(
              'USERNAME DEBUG: '
              'showSenderNames=${widget.showSenderNames}, '
              'showName=$showName, '
              'senderName=${message.senderName}',
            );

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

                if (showName)
                  GroupSenderLabel(
                    senderId: message.senderId,
                    name: message.senderName,
                    onTap: widget.onSenderTap == null
                        ? null
                        : () => widget.onSenderTap!(message.senderId),
                  ),
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
                    onEdit:
                        (isMe &&
                            message is TextMessage &&
                            !message.deletedForEveryone &&
                            DateTime.now().difference(
                                  message.createdAt.toDate(),
                                ) <
                                MessageRepository.editWindow)
                        ? () async {
                            debugPrint(
                              '========== EDIT MESSAGE DEBUG ==========',
                            );
                            debugPrint('[EDIT 1] Edit callback started.');
                            debugPrint('[EDIT 1] Message ID: ${message.id}');
                            debugPrint(
                              '[EDIT 1] Message type: ${message.runtimeType}',
                            );
                            debugPrint(
                              '[EDIT 1] Current user ID: $currentUserId',
                            );
                            debugPrint(
                              '[EDIT 1] Original text: ${message.text}',
                            );
                            final newText = await showDialog<String>(
                              context: context,
                              builder: (_) =>
                                  EditMessageDialog(initialText: message.text),
                            );
                            debugPrint('[EDIT 3] Dialog builder executed.');
                            if (!context.mounted || newText == null) return;
                            if (newText.isEmpty ||
                                newText == message.text.trim()) {
                              return;
                            }
                            try {
                              debugPrint(
                                '[EDIT 6] Calling repository.editTextMessage().',
                              );
                              await repository.editTextMessage(
                                messageId: message.id,
                                userId: currentUserId,
                                newText: newText,
                              );
                              debugPrint(
                                '[EDIT 7] Repository update completed successfully.',
                              );
                            } catch (e, stackTrace) {
                              debugPrint('[EDIT DIALOG ERROR] $e');
                              debugPrintStack(stackTrace: stackTrace);
                              if (!context.mounted) return;
                              AppSnackBar.info(
                                context,
                                e is StateError
                                    ? e.message
                                    : 'Could not edit the message.',
                              );
                            }
                            debugPrint('========== EDIT DEBUG END ==========');
                          }
                        : null,
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

                    onDeleteForEveryone: (isMe || widget.canDeleteOthers)
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
