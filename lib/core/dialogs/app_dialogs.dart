import 'package:flutter/material.dart';

import 'app_confirmation_dialog.dart';

class AppDialogs {
  AppDialogs._();

  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );

    return result ?? false;
  }
}
