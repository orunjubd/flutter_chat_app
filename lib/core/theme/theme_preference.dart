import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles local persistence of the application's theme.
///
/// This class is responsible only for reading and writing
/// the selected ThemeMode using SharedPreferences.
///
/// It has no dependency on Riverpod or the UI.
class ThemePreference {
  ThemePreference._();

  static const String _themeKey = 'theme_mode';

  /// Save the selected theme.
  static Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_themeKey, mode.name);
  }

  /// Load the saved theme.
  ///
  /// Returns:
  /// - ThemeMode.dark
  /// - ThemeMode.light
  /// - ThemeMode.system
  ///
  /// Defaults to ThemeMode.dark when no preference exists.
  static Future<ThemeMode> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString(_themeKey);

    switch (value) {
      case 'light':
        return ThemeMode.light;

      case 'system':
        return ThemeMode.system;

      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  /// Remove the saved theme preference.
  ///
  /// Useful during logout, debugging, or resetting app settings.
  static Future<void> clearTheme() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_themeKey);
  }
}
