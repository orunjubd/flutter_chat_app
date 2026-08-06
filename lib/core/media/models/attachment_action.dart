import 'package:flutter/material.dart';

typedef AttachmentActionHandler = Future<void> Function();

class AttachmentAction {
  const AttachmentAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  /// Unique identifier
  final String id;

  /// Display title
  final String title;

  /// Material icon
  final IconData icon;

  /// Icon/background color
  final Color color;

  /// Whether the action is currently enabled
  final bool enabled;

  /// Action executed when selected
  final AttachmentActionHandler onTap;
}
