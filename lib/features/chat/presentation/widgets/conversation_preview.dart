import 'package:flutter/material.dart';

class ConversationPreview extends StatelessWidget {
  const ConversationPreview({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message.isEmpty ? 'No messages yet' : message,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14),
    );
  }
}
