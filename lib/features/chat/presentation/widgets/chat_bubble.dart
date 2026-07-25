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

    //    required this.onDeletePressed,
    required this.deletedForEveryone,
    required this.deletedBy,
    required this.currentUserId,

    required this.onDeleteForMe,
    required this.onDeleteForEveryone,
  });

  final String senderName;
  final String message;
  final bool isMe;
  final DateTime createdAt;
  final bool isRead;
  //final VoidCallback onDeletePressed;

  final bool deletedForEveryone;
  final List<String> deletedBy;
  final String currentUserId;

  final VoidCallback onDeleteForMe;
  final VoidCallback? onDeleteForEveryone;

  // String _formatTime(DateTime dateTime) {
  //   final hour = dateTime.hour > 12
  //       ? dateTime.hour - 12
  //       : (dateTime.hour == 0 ? 12 : dateTime.hour);
  //   final minute = dateTime.minute.toString().padLeft(2, '0');
  //   final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  //   return '$hour:$minute $period';
  // }

  bool get _deletedForMe => deletedBy.contains(currentUserId);

  bool get _deleted => deletedForEveryone || _deletedForMe;

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
                title: const Text('Delete for Me'),
                onTap: () {
                  Navigator.pop(context, 'delete_me');
                },
              ),

              if (isMe)
                ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: context.errorColor,
                  ),
                  title: const Text('Delete for Everyone'),
                  onTap: () {
                    Navigator.pop(context, 'delete_everyone');
                  },
                ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || result == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: Text(
            result == 'delete_everyone'
                ? 'Delete this message for everyone?'
                : 'Delete this message only for you?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    switch (result) {
      case 'delete_me':
        onDeleteForMe();
        break;

      case 'delete_everyone':
        onDeleteForEveryone?.call();
        break;
    }
  }

  String get _displayMessage {
    if (deletedForEveryone) {
      return 'This message was deleted';
    }

    if (_deletedForMe) {
      return 'You deleted this message';
    }

    return message;
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
        onLongPress: _deleted ? null : () => _showMessageMenu(context),
        child: Material(
          elevation: 1.5,
          borderRadius: bubbleRadius,
          color: AppColors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: context.screenWidth * .72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _deleted
                  ? context.colorScheme.surfaceContainerHighest
                  : isMe
                  ? context.myBubbleColor
                  : context.otherBubbleColor,
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
                  _displayMessage,
                  style: context.bodyText?.copyWith(
                    fontStyle: _deleted ? FontStyle.italic : FontStyle.normal,
                    color: _deleted
                        ? context.textSecondaryColor
                        : isMe
                        ? Colors.white
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
