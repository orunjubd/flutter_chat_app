import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/providers/message_provider.dart';

class MessageList extends ConsumerWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider);

    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, stackTrace) => Center(
        child: Text(
          error.toString(),
          style: const TextStyle(color: Colors.red),
        ),
      ),

      data: (messages) {
        if (messages.isEmpty) {
          return const Center(
            child: Text('No messages yet.', style: TextStyle(fontSize: 18)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(message.senderName),
                subtitle: Text(message.text),
                trailing: Text(
                  message.type,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
