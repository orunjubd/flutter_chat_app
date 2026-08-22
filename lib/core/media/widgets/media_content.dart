//import 'package:chat_app/features/chat/presentation/widgets/video_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/chat/presentation/widgets/voice_message_bubble.dart';
import 'package:chat_app/features/chat/data/models/message.dart';

class MediaContent extends StatelessWidget {
  const MediaContent({super.key, required this.message, required this.isMe});

  final LegacyMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      // ============================================================
      // IMAGE MESSAGE
      // ============================================================
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260, maxHeight: 320),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return const SizedBox(
                      width: 260,
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (_, _, _) {
                    return const SizedBox(
                      width: 260,
                      height: 180,
                      child: Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              ),
            ),

            if (message.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  message.text,
                  style: context.bodyText?.copyWith(
                    color: isMe
                        ? context.myBubbleTextPrimary
                        : context.colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        );

      // ============================================================
      // FILE MESSAGE
      // ============================================================
      // case 'file':
      //   return FileMessageBubble(message: message, isMe: isMe);

      // =======================================================================
      // 🎙️ NEW: ENTERPRISE VOICE RECORDING ROUTING CELL
      // =======================================================================
      case 'audio':
        return VoiceMessageBubble(message: message, isMe: isMe);

      // ============================================================
      // FALLBACK
      // ============================================================
      default:
        return Text(message.text, style: context.bodyText);
    }
  }
}
