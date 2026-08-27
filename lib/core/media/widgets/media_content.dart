//import 'package:chat_app/features/chat/presentation/widgets/video_message_bubble.dart';
import 'package:chat_app/core/media/widgets/fullscreen_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/chat/presentation/widgets/voice_message_bubble.dart';
import 'package:chat_app/features/chat/data/models/message.dart';

class MediaContent extends StatelessWidget {
  const MediaContent({super.key, required this.message, required this.isMe});

  final LegacyMessage message;
  final bool isMe;

  /// Falls back to a reasonable default when width/height are unknown
  /// (e.g. older messages sent before dimensions were tracked), and
  /// clamps out-of-range metadata the same way VideoMessageBubble does.
  double _imageAspectRatio(LegacyMessage message) {
    final width = message.imageWidth;
    final height = message.imageHeight;

    if (width == null || height == null || height <= 0) {
      return 4 / 3;
    }

    final ratio = width / height;
    if (ratio < 0.4 || ratio > 2.5) {
      return 4 / 3;
    }

    return ratio;
  }

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      // ============================================================
      // IMAGE MESSAGE
      // ============================================================
      // MediaContent — case 'image':
      case 'image':
        final aspectRatio = _imageAspectRatio(message);
        final heroTag = 'image-${message.imageUrl}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullscreenImageViewer(
                      imageUrl: message.imageUrl!,
                      heroTag: heroTag,
                    ),
                  ),
                );
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(
                        message.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const ColoredBox(
                            color: Colors.black12,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Colors.black12,
                          child: Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                  ),
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
