// lib/features/peoples/presentation/widgets/app_users_list.dart
import 'package:flutter/material.dart';
import 'package:chat_app/features/chat/data/models/app_user.dart';
import 'package:chat_app/features/peoples/presentation/widgets/app_user_tile.dart';

class AppUsersList extends StatelessWidget {
  const AppUsersList({super.key, required this.users, required this.onUserTap});
  final List<AppUser> users;
  final ValueChanged<AppUser> onUserTap;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No users found.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];
        return AppUserTile(user: user, onTap: () => onUserTap(user));
      },
    );
  }
}
