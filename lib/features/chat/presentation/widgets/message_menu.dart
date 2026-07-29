import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/providers/reply_provider.dart';
import 'package:chat_app/features/chat/presentation/widgets/reaction_picker.dart';

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
    required ValueChanged<String> onReaction,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              ReactionPicker(
                onSelected: (emoji) {
                  Navigator.pop(context);

                  onReaction(emoji);
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);

                  ref.read(replyProvider.notifier).replyTo(message);
                },
              ),

              ListTile(
                leading: const Icon(Icons.forward),
                title: const Text('Forward'),
                onTap: () {
                  Navigator.pop(context);

                  onForward();
                },
              ),

              const Divider(),

              ListTile(
                leading: Icon(Icons.delete_outline, color: context.errorColor),
                title: const Text('Delete for Me'),
                onTap: () {
                  Navigator.pop(context);

                  onDeleteForMe();
                },
              ),

              if (canDeleteForEveryone)
                ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: context.errorColor,
                  ),
                  title: const Text('Delete for Everyone'),
                  onTap: () {
                    Navigator.pop(context);

                    onDeleteForEveryone?.call();
                  },
                ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
