import 'package:flutter/material.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';

class ReplyCard extends StatelessWidget {
  const ReplyCard({
    super.key,
    required this.senderName,
    required this.message,
    this.onClose,
    this.compact = false,
  });

  final String senderName;
  final String message;
  final VoidCallback? onClose;

  /// false = preview above input
  /// true  = inside chat bubble
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final previewText = message.length > 80
        ? '${message.substring(0, 80)}...'
        : message;

    return Container(
      width: double.infinity,
      margin: compact
          ? const EdgeInsets.only(bottom: 6)
          : const EdgeInsets.symmetric(horizontal: 8),
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: compact
            ? (context.theme.brightness == Brightness.dark
                  ? Colors.white.withValues(
                      alpha: 0.12,
                    ) // Dims inner cards inside night me-bubbles cleanly
                  : context.colorScheme.onSurface.withValues(alpha: 0.06))
            : context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: compact && !context.isDarkMode
                ? context.primaryColor
                : context.primaryColor,
            width: compact ? 3.5 : 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  senderName,
                  style: context.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  previewText,
                  //message,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.captionText?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          if (onClose != null && !compact) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
