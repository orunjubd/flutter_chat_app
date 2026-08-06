import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/features/chat/data/models/message.dart';

class MediaContent extends StatelessWidget {
  const MediaContent({super.key, required this.message, required this.isMe});

  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: AspectRatio(
                aspectRatio:
                    (message.imageWidth != null &&
                        message.imageHeight != null &&
                        message.imageHeight! > 0)
                    ? message.imageWidth! / message.imageHeight!
                    : 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    message.imageUrl!,
                    fit: BoxFit.cover,

                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          }

                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },

                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    },

                    errorBuilder: (_, __, ___) {
                      return const Center(child: Icon(Icons.broken_image));
                    },
                  ),
                ),
              ),
            ),

            if (message.caption != null && message.caption!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  message.caption!,
                  style: context.bodyText?.copyWith(
                    color: isMe
                        ? context.myBubbleTextPrimary
                        : context.colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        );

      default:
        return Text(message.text);
    }
  }
}
