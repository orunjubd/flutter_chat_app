import 'package:flutter/material.dart';
import 'package:chat_app/core/navigation/app_navigator_key.dart';
import 'package:chat_app/core/theme/app_colors.dart';

enum NotificationKind { info, success, warning, error }

class NotificationService {
  void show(
    String message, {
    NotificationKind kind = NotificationKind.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    final messenger = ScaffoldMessenger.maybeOf(ctx);
    if (messenger == null) return;

    final color = switch (kind) {
      NotificationKind.info => null,
      NotificationKind.success => AppColors.success,
      NotificationKind.warning => AppColors.warning,
      NotificationKind.error => AppColors.error,
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }

  void info(String m) => show(m);
  void success(String m) => show(m, kind: NotificationKind.success);
  void warning(String m) => show(m, kind: NotificationKind.warning);
  void error(String m) => show(m, kind: NotificationKind.error);
}
