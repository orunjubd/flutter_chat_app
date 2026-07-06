import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/providers/message_provider.dart';
import 'package:chat_app/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_animation.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key, required this.scrollController});

  final ScrollController scrollController;

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
    final messagesAsync = ref.watch(messagesProvider);

    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, _) => Center(
        child: Text(
          error.toString(),
          style: const TextStyle(color: Colors.red),
        ),
      ),

      data: (messages) {
        _scrollToBottom();
        if (messages.isEmpty) {
          return const Center(
            child: Text('No messages yet.', style: TextStyle(fontSize: 18)),
          );
        }

        return ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final currentUserId = ref.read(currentUserIdProvider);
            final repository = ref.read(messageRepositoryProvider);
            final isRead =
                currentUserId != null &&
                message.readBy.any((uid) => uid != currentUserId);

            // 🚀 2. THE ENTERPRISE AUTOMATED READ RECEIPT TRIGGER BATCH FILTER
            if (currentUserId != null &&
                message.senderId != currentUserId &&
                !message.readBy.contains(currentUserId)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                repository.markMessageAsRead(
                  messageId: message.id,
                  userId: currentUserId,
                );
              });
            }

            return MessageAnimation(
              key: ValueKey(message.id),
              child: ChatBubble(
                senderName: message.senderName,
                message: message.text,
                createdAt: message.createdAt.toDate(),
                isMe: message.senderId == currentUserId,
                isRead: isRead,
              ),
            );
          },
        );
      },
    );
  }
}
