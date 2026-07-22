import 'package:chat_app/core/theme/app_text_theme.dart';
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

  // ===========================================================================
  // 🔒 THE PRIVATE STATIC BORDER FACTORY UTILITY
  // ===========================================================================
  // ✅ ফিক্সড: বারবার একই রেডিয়াস কোড ডুপ্লিকেট করা বন্ধ করতে তোমার তৈরি করা হেল্পার মেথডটি বসানো হলো
  static OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  //===========================================================================
  // LIGHT COMPONENT THEMES
  //===========================================================================

  static AppBarThemeData get lightAppBarTheme => const AppBarThemeData(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.lightBackground,
    surfaceTintColor: Colors.transparent,
  );

  static CardThemeData get lightCardTheme => CardThemeData(
    elevation: 0,
    shadowColor: AppColors.lightShadow,
    surfaceTintColor: AppColors.lightSurfaceTint,
    color: AppColors.lightSurface,
    //margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias,
  );

  static DividerThemeData get lightDividerTheme => const DividerThemeData(
    color: AppColors.lightDivider,
    thickness: 1,
    space: 1,
    indent: 16,
    endIndent: 16,
  );

  static MenuThemeData get lightMenuTheme => MenuThemeData(
    style: MenuStyle(
      backgroundColor: const WidgetStatePropertyAll(AppColors.lightSurface),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      elevation: const WidgetStatePropertyAll(4),
      shadowColor: const WidgetStatePropertyAll(Colors.black12),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static ListTileThemeData get lightListTileTheme => const ListTileThemeData(
    iconColor: AppColors.lightTextSecondary,
    textColor: AppColors.lightTextPrimary,
    tileColor: Colors.transparent,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    minLeadingWidth: 24,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  static DialogThemeData get lightDialogTheme => DialogThemeData(
    backgroundColor: AppColors.lightSurface,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    titleTextStyle: AppTextTheme.textTheme.titleLarge,
    contentTextStyle: AppTextTheme.textTheme.bodyMedium,
  );

  static BottomSheetThemeData get lightBottomSheetTheme =>
      const BottomSheetThemeData(
        showDragHandle: true, // 🌟 Premium touch-swipe indicator bar
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      );

  static SnackBarThemeData get lightSnackBarTheme => const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    showCloseIcon: true,
  );

  static FilledButtonThemeData get lightFilledButtonTheme =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static NavigationDrawerThemeData get lightNavigationDrawerTheme =>
      const NavigationDrawerThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 1,
        shadowColor: Colors.black12,
        indicatorColor: AppColors.primaryLight,
        surfaceTintColor: Colors.transparent,
      );

  static OutlinedButtonThemeData get lightOutlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static ElevatedButtonThemeData get lightElevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          elevation: 1,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static ProgressIndicatorThemeData get lightProgressIndicatorTheme =>
      const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.lightDivider,
        circularTrackColor: AppColors.lightDivider,
      );

  static CheckboxThemeData get lightCheckboxTheme => CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: const WidgetStatePropertyAll(Colors.white),
  );

  static RadioThemeData get lightRadioTheme => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }

      return AppColors.lightBorder;
    }),
  );

  static SwitchThemeData get lightSwitchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }

      return AppColors.lightSurface;
    }),

    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight;
      }

      return AppColors.lightDisabled;
    }),

    trackOutlineColor: WidgetStatePropertyAll(AppColors.lightBorder),
  );

  static InputDecorationThemeData get lightInputDecorationTheme =>
      InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: _border(AppColors.lightBorder),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        disabledBorder: _border(AppColors.lightDisabled),
        enabledBorder: _border(AppColors.lightBorder),
        focusedBorder: _border(AppColors.primary),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error, 2),
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
    backgroundColor: AppColors.darkBackground,
    surfaceTintColor: Colors.transparent,
  );

  static CardThemeData get darkCardTheme => CardThemeData(
    elevation: 0,
    shadowColor: AppColors.darkShadow,
    surfaceTintColor: AppColors.darkSurfaceTint,
    color: AppColors.darkSurface,
    //margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias,
  );

  static DividerThemeData get darkDividerTheme => const DividerThemeData(
    color: AppColors.darkDivider,
    thickness: 1,
    space: 1,
    indent: 16,
    endIndent: 16,
  );

  static MenuThemeData get darkMenuTheme => MenuThemeData(
    style: MenuStyle(
      backgroundColor: const WidgetStatePropertyAll(AppColors.darkSurface),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      elevation: const WidgetStatePropertyAll(4),
      shadowColor: const WidgetStatePropertyAll(Colors.black26),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static ListTileThemeData get darkListTileTheme => const ListTileThemeData(
    iconColor: AppColors.darkTextSecondary,
    textColor: AppColors.darkTextPrimary,
    tileColor: Colors.transparent,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    minLeadingWidth: 24,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  static NavigationDrawerThemeData get darkNavigationDrawerTheme =>
      const NavigationDrawerThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 1,
        shadowColor: Colors.black26,
        indicatorColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
      );

  static DialogThemeData get darkDialogTheme => DialogThemeData(
    backgroundColor: AppColors.darkSurface,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle: AppTextTheme.textTheme.titleLarge,
    contentTextStyle: AppTextTheme.textTheme.bodyMedium,
  );

  static BottomSheetThemeData get darkBottomSheetTheme =>
      const BottomSheetThemeData(
        showDragHandle: true, // 🌟 Premium touch-swipe indicator bar
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      );

  static SnackBarThemeData get darkSnackBarTheme => const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    showCloseIcon: true,
  );

  static FilledButtonThemeData get darkFilledButtonTheme =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static OutlinedButtonThemeData get darkOutlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: Colors.white,
          side: const BorderSide(color: AppColors.darkBorder),
          disabledForegroundColor: AppColors.darkTextDisabled,
          //elevation: 1,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      );

  static ElevatedButtonThemeData
  get darkElevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      elevation:
          0, // Enterprise Rule: Zero shadows on pure dark cards preserves visual layout clarity
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.darkDisabled,
      disabledForegroundColor: AppColors.darkTextDisabled,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ProgressIndicatorThemeData get darkProgressIndicatorTheme =>
      const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.darkDivider,
        circularTrackColor: AppColors.darkDivider,
      );

  static CheckboxThemeData get darkCheckboxTheme => CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight;
      }

      return Colors.transparent;
    }),
    checkColor: const WidgetStatePropertyAll(Colors.white),
  );

  static SwitchThemeData get darkSwitchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight;
      }

      return AppColors.darkSurface;
    }),

    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }

      return AppColors.darkDisabled;
    }),

    trackOutlineColor: WidgetStatePropertyAll(AppColors.darkBorder),
  );

  static RadioThemeData get darkRadioTheme => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight;
      }

      return AppColors.darkBorder;
    }),
  );

  static InputDecorationThemeData get darkInputDecorationTheme =>
      InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.darkSurface,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        // 🔒 THE DARK DISABLED BORDER AND STYLE CHANNELS
        border: _border(AppColors.darkBorder),
        disabledBorder: _border(AppColors.darkDisabled),
        enabledBorder: _border(AppColors.darkBorder),
        focusedBorder: _border(AppColors.primary, 2),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error, 2),

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
