import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/providers/reply_provider.dart';
//import 'package:chat_app/features/chat/providers/forward_provider.dart';

//--------------------------------------------------------------------
//What this class now owns

// It completely owns

// ✅ BottomSheet
// ✅ Reply selection
// ✅ Delete dialog
// ✅ Delete callbacks
// ✅ ReplyProvider

// ChatBubble will no longer know any of this.
//
//
//--------------------------------------------------------------------
class MessageMenu {
  const MessageMenu._();

  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required Message message,
    required bool canDeleteForEveryone,
    required VoidCallback onForward,
    required VoidCallback onDeleteForMe,
    required VoidCallback? onDeleteForEveryone,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!message.deletedForEveryone)
                ListTile(
                  leading: const Icon(Icons.forward),
                  title: const Text('Forward'),
                  onTap: () {
                    Navigator.pop(context, 'forward');
                  },
                ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () => Navigator.pop(context, 'reply'),
              ),

              ListTile(
                leading: Icon(Icons.delete_outline, color: context.errorColor),
                title: const Text('Delete for Me'),
                onTap: () => Navigator.pop(context, 'delete_me'),
              ),

              if (canDeleteForEveryone)
                ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: context.errorColor,
                  ),
                  title: const Text('Delete for Everyone'),
                  onTap: () => Navigator.pop(context, 'delete_everyone'),
                ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || result == null) {
      return;
    }

    //==================================================
    // Forward
    //==================================================

    if (result == 'forward') {
      // ref.read(forwardProvider.notifier).forward(message);

      onForward();

      return;
    }

    //--------------------------------------------------
    // Reply
    //--------------------------------------------------

    if (result == 'reply') {
      ref.read(replyProvider.notifier).replyTo(message);
      return;
    }

    //--------------------------------------------------
    // Delete Confirmation
    //--------------------------------------------------

    final confirm = await showDialog<bool>(
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

    if (confirm != true) {
      return;
    }

    //--------------------------------------------------
    // Execute
    //--------------------------------------------------

    switch (result) {
      case 'delete_me':
        onDeleteForMe();
        break;

      case 'delete_everyone':
        onDeleteForEveryone?.call();
        break;
    }
  }
}
