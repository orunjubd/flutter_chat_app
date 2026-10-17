import 'package:chat_app/features/chat/constants/conversation_strings.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_settings_provider.dart';
import 'package:chat_app/features/chat/providers/group_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showConversationActions(
  BuildContext context,
  WidgetRef ref,
  String conversationId,
) {
  return showModalBottomSheet(
    context: context,
    builder: (sheetContext) => Consumer(
      builder: (_, ref, _) {
        final s = ref.watch(conversationSettingsProvider(conversationId));
        final actions = ref.read(conversationSettingsActionsProvider);

        void run(Future<dynamic> Function() action) async {
          Navigator.pop(sheetContext);
          final result = await action();
          if (result is String && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(result)));
          }
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  s.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                title: Text(
                  s.pinned
                      ? ConversationStrings.unpin
                      : ConversationStrings.pin,
                ),
                onTap: () => run(() => actions.togglePin(conversationId)),
              ),
              ListTile(
                leading: Icon(s.favorite ? Icons.star : Icons.star_border),
                title: Text(
                  s.favorite
                      ? ConversationStrings.unfavorite
                      : ConversationStrings.favorite,
                ),
                onTap: () => run(() => actions.toggleFavorite(conversationId)),
              ),
              ListTile(
                leading: Icon(
                  s.archived
                      ? Icons.unarchive_outlined
                      : Icons.archive_outlined,
                ),
                title: Text(
                  s.archived
                      ? ConversationStrings.unarchive
                      : ConversationStrings.archive,
                ),
                onTap: () => run(() => actions.toggleArchive(conversationId)),
              ),
              if (s.isMuted)
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text(ConversationStrings.unmute),
                  onTap: () => run(() => actions.unmute(conversationId)),
                )
              else
                ListTile(
                  leading: const Icon(Icons.notifications_off_outlined),
                  title: const Text(ConversationStrings.mute),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final choice = await showModalBottomSheet<Duration?>(
                      context: context,
                      builder: (_) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text(ConversationStrings.mute8h),
                              onTap: () => Navigator.pop(
                                context,
                                const Duration(hours: 8),
                              ),
                            ),
                            ListTile(
                              title: const Text(ConversationStrings.mute1w),
                              onTap: () => Navigator.pop(
                                context,
                                const Duration(days: 7),
                              ),
                            ),
                            ListTile(
                              title: const Text(ConversationStrings.muteAlways),
                              onTap: () =>
                                  Navigator.pop(context, Duration.zero),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (choice == null) return; // dismissed
                    await actions.mute(
                      conversationId,
                      duration: choice == Duration.zero ? null : choice,
                    );
                  },
                ),

              if (ref
                      .watch(conversationByIdProvider(conversationId))
                      ?.isGroup ==
                  false)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: const Text(ConversationStrings.deleteChat),
                  onTap: () async {
                    // capture everything BEFORE closing the sheet and awaiting
                    final repo = ref.read(conversationRepositoryProvider);
                    final uid = ref.read(currentUserIdProvider);
                    Navigator.pop(sheetContext);
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (d) => AlertDialog(
                        title: const Text(ConversationStrings.deleteChat),
                        content: const Text(ConversationStrings.deleteChatBody),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(d, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(d, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true || uid == null) return;
                    try {
                      await repo.removeConversationForUser(
                        conversationId: conversationId,
                        userId: uid,
                      );
                    } catch (e, st) {
                      debugPrint('❌ [Delete] failed: $e');
                      debugPrintStack(stackTrace: st);
                    }
                    // final uid = ref.read(currentUserIdProvider);
                    // if (ok != true || uid == null) return;
                    // await ref
                    //     .read(conversationRepositoryProvider)
                    //     .removeConversationForUser(
                    //       conversationId: conversationId,
                    //       userId: uid,
                    //     );
                  },
                ),
            ],
          ),
        );
      },
    ),
  );
}
