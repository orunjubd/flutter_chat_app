import 'package:flutter/material.dart';
import 'package:chat_app/features/chat/data/models/app_user.dart';
import 'package:chat_app/core/theme/app_colors.dart';

class AppUserTile extends StatelessWidget {
  const AppUserTile({super.key, required this.user, this.onTap});

  final AppUser user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user.imageUrl.trim().isNotEmpty
            ? NetworkImage(user.imageUrl)
            : null,
        child: user.imageUrl.trim().isEmpty ? const Icon(Icons.person) : null,
      ),
      title: Text(
        user.username.trim().isNotEmpty ? user.username : 'Unknown User',
      ),
      subtitle: Text(user.email),
      trailing: _OnlineIndicator(isOnline: user.isOnline),
    );
  }
}

class _OnlineIndicator extends StatelessWidget {
  const _OnlineIndicator({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.circle,
      size: 12,
      color: isOnline ? AppColors.online : AppColors.offline,
    );
  }
}
