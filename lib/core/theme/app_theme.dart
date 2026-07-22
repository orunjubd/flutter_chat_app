// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/core/theme/app_text_theme.dart';
import 'package:chat_app/core/theme/app_component_theme.dart';
import 'package:chat_app/core/extensions/chat_bubble_theme_extension.dart';

/// ---------------------------------------------------------------------------
/// Final Architecture
/// ---------------------------------------------------------------------------
///
// AppColors
//         │
//         ▼
// AppTextTheme
//         │
//         ▼
// AppComponentTheme
//         │
//         ▼
// AppTheme
//         │
//         ▼
// MaterialApp
//         │
//         ▼
// ThemeExtensions
//         │
//         ▼
// Widgets
/// ---------------------------------------------------------------------------
class AppTheme {
  // ✅ Bulletproof private named constructor blocking unnecessary allocations
  const AppTheme._();

  // ===========================================================================
  // ☀️ PUBLIC LIGHT THEME GATEWAY
  // ===========================================================================
  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.lightSurface,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppComponentTheme.lightAppBarTheme,
      cardTheme: AppComponentTheme.lightCardTheme,
      dividerTheme: AppComponentTheme.lightDividerTheme,
      listTileTheme: AppComponentTheme.lightListTileTheme,
      dialogTheme: AppComponentTheme.lightDialogTheme,
      bottomSheetTheme: AppComponentTheme.lightBottomSheetTheme,
      snackBarTheme: AppComponentTheme.lightSnackBarTheme,
      filledButtonTheme: AppComponentTheme.lightFilledButtonTheme,
      elevatedButtonTheme: AppComponentTheme.lightElevatedButtonTheme,
      outlinedButtonTheme: AppComponentTheme.lightOutlinedButtonTheme,
      inputDecorationTheme: AppComponentTheme.lightInputDecorationTheme,
      bubbleTheme: const ChatBubbleThemeExtension(
        myBubbleColor: AppColors.lightBubbleMe,
        otherBubbleColor: AppColors.lightBubbleOther,
        readReceiptColor: AppColors.telegramBlue,
        unreadReceiptColor: AppColors.lightTextSecondary,
      ),
    );
  }

  // ===========================================================================
  // 🌙 PUBLIC DARK THEME GATEWAY
  // ===========================================================================
  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppComponentTheme.darkAppBarTheme,
      cardTheme: AppComponentTheme.darkCardTheme,
      dividerTheme: AppComponentTheme.darkDividerTheme,
      listTileTheme: AppComponentTheme.darkListTileTheme,
      dialogTheme: AppComponentTheme.darkDialogTheme,
      bottomSheetTheme: AppComponentTheme.darkBottomSheetTheme,
      snackBarTheme: AppComponentTheme.darkSnackBarTheme,
      filledButtonTheme: AppComponentTheme.darkFilledButtonTheme,
      elevatedButtonTheme: AppComponentTheme.darkElevatedButtonTheme,
      outlinedButtonTheme: AppComponentTheme.darkOutlinedButtonTheme,
      inputDecorationTheme: AppComponentTheme.darkInputDecorationTheme,
      bubbleTheme: const ChatBubbleThemeExtension(
        myBubbleColor: AppColors.darkBubbleMe,
        otherBubbleColor: AppColors.darkBubbleOther,
        readReceiptColor: AppColors.telegramBlueDark,
        unreadReceiptColor: AppColors.darkTextSecondary,
      ),
    );
  }

  // ===========================================================================
  // 🔒 THE PRIVATE THEME BUILDER CENTRALIZED UNIFIED FABRICATION CORE ENGINE
  // ===========================================================================
  // ✅ ফিক্সড: লাইট আর ডার্ক থিমের ডুপ্লিকেট কোড দূর করতে একটি সিঙ্গেল প্রাইভেট বিল্ডার মেথড তৈরি করা হলো
  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
    required AppBarThemeData appBarTheme,
    required CardThemeData cardTheme,
    required DividerThemeData dividerTheme,
    required ListTileThemeData listTileTheme,
    required DialogThemeData dialogTheme,
    required BottomSheetThemeData bottomSheetTheme,
    required SnackBarThemeData snackBarTheme,
    required FilledButtonThemeData filledButtonTheme,
    required ElevatedButtonThemeData elevatedButtonTheme,
    required OutlinedButtonThemeData outlinedButtonTheme,
    required InputDecorationThemeData inputDecorationTheme,
    required ChatBubbleThemeExtension bubbleTheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: AppTextTheme.textTheme,

      // Safe initialization passing parameters cleanly without explicit type constraints forcing crashes
      appBarTheme: appBarTheme,
      cardTheme: cardTheme,
      dividerTheme: dividerTheme,
      listTileTheme: listTileTheme,
      dialogTheme: dialogTheme,
      bottomSheetTheme: bottomSheetTheme,
      snackBarTheme: snackBarTheme,
      filledButtonTheme: filledButtonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      inputDecorationTheme: inputDecorationTheme,

      extensions: <ThemeExtension<dynamic>>[bubbleTheme],
    );
  }
}
