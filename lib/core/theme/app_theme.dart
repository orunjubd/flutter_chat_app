import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_component_theme.dart';
import 'app_text_theme.dart';

class AppTheme {
  const AppTheme._();

  //===========================================================================
  // LIGHT THEME
  //===========================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      //-----------------------------------------------------------------------
      // Color Scheme
      //-----------------------------------------------------------------------
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.lightSurface,
      ),

      scaffoldBackgroundColor: AppColors.lightBackground,

      //-----------------------------------------------------------------------
      // Typography
      //-----------------------------------------------------------------------
      textTheme: AppTextTheme.textTheme,

      //-----------------------------------------------------------------------
      // Component Themes
      //-----------------------------------------------------------------------
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
    );
  }

  //===========================================================================
  // DARK THEME
  //===========================================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      //-----------------------------------------------------------------------
      // Color Scheme
      //-----------------------------------------------------------------------
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,

      //-----------------------------------------------------------------------
      // Typography
      //-----------------------------------------------------------------------
      textTheme: AppTextTheme.textTheme,

      //-----------------------------------------------------------------------
      // Component Themes
      //-----------------------------------------------------------------------
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
    );
  }
}
