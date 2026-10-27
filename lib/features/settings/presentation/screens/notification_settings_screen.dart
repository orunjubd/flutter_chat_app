import 'package:chat_app/core/notifications/models/global_notification_settings.dart';
import 'package:chat_app/core/notifications/providers/notification_provider.dart';
import 'package:chat_app/features/chat/constants/conversation_strings.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserIdProvider);
    final s =
        ref.watch(globalNotificationSettingsProvider).value ??
        const GlobalNotificationSettings();
    final repo = ref.read(globalNotificationSettingsRepositoryProvider);

    Future<void> chooseMute() async {
      final choice = await showModalBottomSheet<Duration?>(
        context: context,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(ConversationStrings.mute8h),
                onTap: () => Navigator.pop(context, const Duration(hours: 8)),
              ),
              ListTile(
                title: const Text(ConversationStrings.mute1w),
                onTap: () => Navigator.pop(context, const Duration(days: 7)),
              ),
              ListTile(
                title: const Text(ConversationStrings.muteAlways),
                onTap: () => Navigator.pop(context, Duration.zero),
              ),
            ],
          ),
        ),
      );
      if (choice == null || uid == null) return;
      await repo.mute(uid, duration: choice == Duration.zero ? null : choice);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text('Message sound'),
            subtitle: const Text(
              'Play a sound for new messages while the app is open',
            ),
            value: s.messageSound,
            onChanged: uid == null ? null : (v) => repo.setSound(uid, v),
          ),
          ListTile(
            leading: Icon(
              s.isMuted
                  ? Icons.notifications_off
                  : Icons.notifications_active_outlined,
            ),
            title: Text(
              s.isMuted ? 'Notifications muted' : 'Mute all notifications',
            ),
            subtitle: Text(
              s.isMuted
                  ? (s.mutedUntil!.toDate().year >= 2100
                        ? 'Until you turn it back on'
                        : 'Until ${s.mutedUntil!.toDate().toLocal()}')
                  : 'Messages are silenced. Calls still ring.',
            ),
            trailing: s.isMuted
                ? TextButton(
                    onPressed: uid == null ? null : () => repo.unmute(uid),
                    child: const Text('Unmute'),
                  )
                : null,
            onTap: s.isMuted ? null : chooseMute,
          ),
        ],
      ),
    );
  }
}
