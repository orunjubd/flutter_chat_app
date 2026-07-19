import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ---------------------------------------------------------------------------
/// ECE Component Theme
/// ---------------------------------------------------------------------------
///
/// Centralizes all Material component themes.
///
/// This keeps `app_theme.dart` clean while allowing every Material widget
/// (buttons, cards, dialogs, snackbars, inputs, etc.) to share a consistent
/// appearance throughout the application.
///
/// Architecture:
///
/// AppTheme
///     ↓
/// AppComponentTheme
///     ↓
/// Material Components
/// ---------------------------------------------------------------------------
class AppComponentTheme {
  const AppComponentTheme._();

  //===========================================================================
  // LIGHT COMPONENT THEMES
  //===========================================================================

  static AppBarThemeData get lightAppBarTheme => const AppBarThemeData(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
  );

  static CardThemeData get lightCardTheme => CardThemeData(
    elevation: 1,
    color: AppColors.lightSurface,
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static DividerThemeData get lightDividerTheme => const DividerThemeData(
    space: 1,
    color: AppColors.lightDivider,
    thickness: 1,
  );

  static ListTileThemeData get lightListTileTheme => const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );

  static DialogThemeData get lightDialogTheme => DialogThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );

  static BottomSheetThemeData get lightBottomSheetTheme =>
      const BottomSheetThemeData(showDragHandle: true);

  static SnackBarThemeData get lightSnackBarTheme =>
      const SnackBarThemeData(behavior: SnackBarBehavior.floating);

  static FilledButtonThemeData get lightFilledButtonTheme =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static OutlinedButtonThemeData get lightOutlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static ElevatedButtonThemeData get lightElevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static InputDecorationThemeData get lightInputDecorationTheme =>
      InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightDisabled),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        errorStyle: const TextStyle(color: AppColors.error),

        labelStyle: const TextStyle(color: AppColors.lightTextSecondary),

        hintStyle: const TextStyle(color: AppColors.lightTextSecondary),

        iconColor: AppColors.lightTextSecondary,

        suffixIconColor: AppColors.lightTextSecondary,

        prefixIconColor: AppColors.lightTextSecondary,
      );

  //===========================================================================
  // DARK COMPONENT THEMES
  //===========================================================================

  static AppBarThemeData get darkAppBarTheme => const AppBarThemeData(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
  );

  static CardThemeData get darkCardTheme => CardThemeData(
    elevation: 1,
    color: AppColors.darkSurface,
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static DividerThemeData get darkDividerTheme => const DividerThemeData(
    space: 1,
    color: AppColors.darkDivider,
    thickness: 1,
  );

  static ListTileThemeData get darkListTileTheme => const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );

  static DialogThemeData get darkDialogTheme => DialogThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );

  static BottomSheetThemeData get darkBottomSheetTheme =>
      const BottomSheetThemeData(showDragHandle: true);

  static SnackBarThemeData get darkSnackBarTheme =>
      const SnackBarThemeData(behavior: SnackBarBehavior.floating);

  static FilledButtonThemeData get darkFilledButtonTheme =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static OutlinedButtonThemeData get darkOutlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static ElevatedButtonThemeData get darkElevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static InputDecorationThemeData get darkInputDecorationTheme =>
      InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        // 🔒 THE DARK DISABLED BORDER AND STYLE CHANNELS
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkDisabled),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          //borderSide: BorderSide(color: Colors.white30),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          //borderSide: BorderSide(color: Colors.white, width: 2),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
          //borderSide: const BorderSide(color: AppColors.primary),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),

        errorStyle: const TextStyle(color: AppColors.error),

        //labelStyle: const TextStyle(color: Colors.white70),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        hintStyle: const TextStyle(color: AppColors.darkTextSecondary),

        iconColor: AppColors.darkTextSecondary,
        suffixIconColor: AppColors.darkTextSecondary,

        //prefixIconColor: Colors.white70,
        prefixIconColor: AppColors.darkTextSecondary,
      );
}
