import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// SettingsTile
/// ---------------------------------------------------------------------------
///
/// A reusable Material 3 settings tile used throughout the ECE application.
///
/// This widget provides a consistent appearance for all settings entries,
/// including:
///
/// • Theme
/// • Notifications
/// • Privacy
/// • Language
/// • Storage
/// • About
/// • Logout
///
/// Keeping all settings entries visually identical improves consistency
/// and allows future UI updates from a single location.
/// ---------------------------------------------------------------------------
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    required this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  /// Leading icon or widget.
  final Widget leading;

  /// Main title.
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// Optional trailing widget.
  ///
  /// Defaults to a chevron when null.
  final Widget? trailing;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Enables or disables interaction.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      enabled: enabled,

      leading: leading,

      title: Text(title, style: theme.textTheme.titleMedium),

      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: theme.textTheme.bodySmall),

      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),

      onTap: enabled ? onTap : null,

      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),

      minLeadingWidth: 28,

      visualDensity: VisualDensity.standard,
    );
  }
}
