import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final bool isRead = unreadCount == 0;
    if (unreadCount <= 0) {
      return Icon(
        Icons.done_all,
        size: 18,
        color: isRead
            ? context
                  .secondaryColor // Maps to our bKash Pink/Accent or user success green
            : context.textSecondaryColor,
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: context.captionText?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
