// lib/core/theme/app_theme.dart
import 'package:chat_app/core/extensions/call_colors_extension.dart';
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

      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,
        elevation: 3,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: TextStyle(
          color: Color.fromARGB(255, 166, 128, 86), // Light brown
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        iconColor: Color.fromARGB(255, 166, 128, 86), // Light brown
      ), // Synchronizes trailing/leading icons with text automatically
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
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.darkBubbleMe, // Dark surface
        elevation: 3,
        surfaceTintColor: AppColors.darkBubbleMe,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: TextStyle(
          color: Color.fromARGB(255, 210, 175, 125), // Soft warm brown
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        iconColor: Color.fromARGB(255, 210, 175, 125), // Soft warm brown
      ),
    );
  }

  // ===========================================================================
  // 🔒 THE PRIVATE THEME BUILDER CENTRALIZED UNIFIED FABRICATION CORE ENGINE
  // ===========================================================================
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
    PopupMenuThemeData? popupMenuTheme,
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
      popupMenuTheme:
          popupMenuTheme ??
          const PopupMenuThemeData(
            color: Color.fromARGB(255, 255, 255, 255),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            textStyle: TextStyle(
              color: Color.fromARGB(
                255,
                255,
                255,
                255,
              ), // Premium high-contrast Slate Dark Charcoal text color
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      extensions: <ThemeExtension<dynamic>>[
        bubbleTheme,
        CallColorsExtension.standard,
      ],
    );
  }
}
