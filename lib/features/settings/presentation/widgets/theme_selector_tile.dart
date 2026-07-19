import 'package:flutter/material.dart';

import 'settings_tile.dart';
import 'theme_bottom_sheet.dart';

/// ---------------------------------------------------------------------------
/// ThemeSelectorTile
/// ---------------------------------------------------------------------------
///
/// Displays the application's current theme setting.
///
/// This widget is responsible only for:
/// • Displaying the current theme.
/// • Opening the ThemeBottomSheet.
///
/// Theme selection logic is handled by ThemeBottomSheet.
/// ---------------------------------------------------------------------------
class ThemeSelectorTile extends StatelessWidget {
  const ThemeSelectorTile({super.key, required this.currentTheme});

  /// Currently selected application theme.
  final ThemeMode currentTheme;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      leading: const Icon(Icons.palette_outlined),

      title: 'Appearance',

      subtitle: _themeLabel(currentTheme),

      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          useSafeArea: true,
          showDragHandle: true,
          builder: (_) => const ThemeBottomSheet(),
        );
      },
    );
  }

  /// Returns a user-friendly theme name.
  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';

      case ThemeMode.dark:
        return 'Dark';

      case ThemeMode.system:
        return 'Follow system';
    }
  }
}
