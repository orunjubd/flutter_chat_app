import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:flutter/material.dart';

class ContactMessageBubble extends StatelessWidget {
  const ContactMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });
  final ContactMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.contactName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(message.contactPhone),
                if (message.contactEmail != null &&
                    message.contactEmail!.trim().isNotEmpty)
                  Text(message.contactEmail!),
                if (message.contactAddress != null &&
                    message.contactAddress!.trim().isNotEmpty)
                  Text(message.contactAddress!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
