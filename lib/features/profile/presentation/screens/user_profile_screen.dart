import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/features/profile/presentation/widgets/profile_screen_widget.dart';
import 'package:chat_app/features/profile/repositories/private_contact_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peerEmail = ref.watch(contactEmailProvider(userId)).value;
    final peerPhone = ref.watch(contactPhoneProvider(userId)).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ref
          .watch(userByIdProvider(userId))
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                const Center(child: Text('Could not load this profile.')),
            data: (user) => user == null
                ? const Center(child: Text('User not found.'))
                : ProfileScreenWidget(
                    user: user,
                    readOnly: true,
                    email: peerEmail,
                    phone: peerPhone,
                  ),
          ),
    );
  }
}
