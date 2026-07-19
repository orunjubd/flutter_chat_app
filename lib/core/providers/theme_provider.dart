import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/theme_preference.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Default theme while loading.
    // The saved preference is loaded immediately afterwards.
    _loadTheme();

    return ThemeMode.light;
  }

  /// Load the saved theme from SharedPreferences.
  Future<void> _loadTheme() async {
    final savedTheme = await ThemePreference.loadTheme();

    if (savedTheme != state) {
      state = savedTheme;
    }
  }

  Future<void> _updateTheme(ThemeMode mode) async {
    if (state == mode) return;

    state = mode;
    await ThemePreference.saveTheme(mode);
  }

  /// Set a specific theme and persist it.
  Future<void> setTheme(ThemeMode mode) async {
    // if (state == mode) return;

    // state = mode;

    await _updateTheme(mode);
  }

  /// Toggle between Light and Dark themes.
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    state = newTheme;

    await ThemePreference.saveTheme(newTheme);
  }

  /// Follow the device's system theme.
  Future<void> useSystemTheme() async {
    //state = ThemeMode.system;

    await _updateTheme(ThemeMode.system);
  }

  /// Force Light Theme.
  Future<void> useLightTheme() async {
    //state = ThemeMode.light;

    await _updateTheme(ThemeMode.light);
  }

  /// Force Dark Theme.
  Future<void> useDarkTheme() async {
    //state = ThemeMode.dark;

    await _updateTheme(ThemeMode.dark);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
