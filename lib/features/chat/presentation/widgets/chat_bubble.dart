import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/core/utils/date_time_formatter.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.senderName,
    required this.message,
    required this.isMe,
    required this.createdAt,
    required this.isRead,
    required this.onDeletePressed,
    //required this.onLongPress,
    //required this.onMessageTap,
  });

  final String senderName;
  final String message;
  final bool isMe;
  final DateTime createdAt;
  final bool isRead;
  final VoidCallback onDeletePressed;
  //final VoidCallback onLongPress;
  //final VoidCallback onMessageTap;

  // String _formatTime(DateTime dateTime) {
  //   final hour = dateTime.hour > 12
  //       ? dateTime.hour - 12
  //       : (dateTime.hour == 0 ? 12 : dateTime.hour);
  //   final minute = dateTime.minute.toString().padLeft(2, '0');
  //   final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  //   return '$hour:$minute $period';
  // }

  Future<void> _showMessageMenu(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete_outline, color: context.errorColor),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context, 'delete');
                },
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted) return;

    if (result == 'delete') {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (shouldDelete == true) {
        onDeletePressed();
      }
    }
  }

  BorderRadius get bubbleRadius => BorderRadius.only(
    topLeft: const Radius.circular(18),
    topRight: const Radius.circular(18),
    bottomLeft: Radius.circular(isMe ? 18 : 4),
    bottomRight: Radius.circular(isMe ? 4 : 18),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GestureDetector(
        onLongPress: () => _showMessageMenu(context),
        child: Material(
          elevation: 1.5,
          borderRadius: bubbleRadius,
          color: AppColors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: context.screenWidth * .72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? context.myBubbleColor : context.otherBubbleColor,
              borderRadius: bubbleRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender Name
                Text(
                  senderName,
                  style: context.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isMe
                        ? context.myBubbleTextPrimary
                        : context.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                // Message
                Text(
                  message,
                  style: context.bodyText?.copyWith(
                    color: isMe
                        ? context.myBubbleTextPrimary
                        : context.colorScheme.onSurface.withValues(alpha: 0.87),
                  ),
                ),

                const SizedBox(height: 8),

                // Timestamp + Read Receipt
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateTimeFormatter.messageTime(createdAt),
                      style: context.captionText?.copyWith(
                        color: isMe
                            ? context.unreadReceiptColor
                            : context.textSecondaryColor,
                      ),
                    ),

                    if (isMe) ...[
                      const SizedBox(width: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          isRead ? Icons.done_all : Icons.done,
                          key: ValueKey(isRead),
                          size: 16,
                          color: isRead
                              ? context.readReceiptColor
                              : context.unreadReceiptColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
