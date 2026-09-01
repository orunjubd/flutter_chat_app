// lib/features/people/presentation/widgets/invite_friends_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/peoples/providers/invite_friend_provider.dart';

class InviteFriendsTile extends ConsumerWidget {
  const InviteFriendsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person_add)),
      title: const Text('Invite Friends'),
      subtitle: const Text('Invite your friends to join Chat App'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        try {
          final service = ref.read(inviteFriendServiceProvider);
          await service.shareInvite();
        } catch (e, stackTrace) {
          debugPrint('❌ Invite Friends failed: $e');
          debugPrintStack(stackTrace: stackTrace);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to open the share menu.')),
          );
        }
      },
    );
  }
}
