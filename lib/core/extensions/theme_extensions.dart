import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Theme Extensions
/// ---------------------------------------------------------------------------
///
/// Provides convenient access to commonly used ThemeData objects.
///
/// Instead of:
///   Theme.of(context).textTheme
///
/// Use:
///   context.textTheme
///
/// This keeps UI code shorter, cleaner, and consistent throughout ECE.
/// ---------------------------------------------------------------------------
extension ThemeContextExtension on BuildContext {
  /// Current ThemeData.
  ThemeData get theme => Theme.of(this);

  /// Current ColorScheme.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Current TextTheme.
  TextTheme get textTheme => theme.textTheme;

  /// Current AppBarTheme.
  AppBarThemeData get appBarTheme => theme.appBarTheme;

  /// Current InputDecorationTheme.
  InputDecorationThemeData get inputDecorationTheme =>
      theme.inputDecorationTheme;

  /// Current Card color.
  Color get cardColor => theme.cardColor;

  /// Current Divider color.
  Color get dividerColor => theme.dividerColor;

  /// Current Scaffold background color.
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;

  /// Current primary color.
  Color get primaryColor => theme.colorScheme.primary;

  /// Current surface color.
  Color get surfaceColor => theme.colorScheme.surface;

  /// Current error color.
  Color get errorColor => theme.colorScheme.error;
}
