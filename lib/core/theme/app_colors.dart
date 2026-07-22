import 'package:flutter/material.dart';

/// ============================================================================
/// ECE Chat Engine
/// Design Tokens
/// ----------------------------------------------------------------------------
///
/// This file contains every reusable color used throughout the application.
///
/// Rules:
/// • Never hardcode Colors.white, Colors.black, etc. inside screens.
/// • Always use AppColors or Theme.of(context).colorScheme.
/// • Keep all application colors centralized here.
///
/// ============================================================================

class AppColors {
  const AppColors._();

  // ===========================================================================
  // 🟢 BRAND COLORS
  // ===========================================================================

  /// Primary ECE brand color.
  static const Color primary = Color(0xFF1E4D40);

  /// Darker variation of the primary color.
  static const Color primaryDark = Color(0xFF163C32);

  /// Lighter variation.
  static const Color primaryLight = Color(0xFF2C6B5B);

  /// Premium accent color.
  static const Color accent = Color(0xFFE2125D);

  // ===========================================================================
  // ☀️ LIGHT THEME
  // ===========================================================================

  static const Color lightBackground = Color(0xFFF5F7F6);

  static const Color lightSurface = Color(0xFFFFFFFF);

  static const Color lightSurfaceTint = Colors.transparent;

  static const Color lightShadow = Color(0x1F000000);

  /// TextField, Card and Input borders.
  static const Color lightBorder = Color(0xFFD0D5DD);

  static const Color lightCard = Color(0xFFFFFFFF);

  static const Color lightDivider = Color(0xFFE0E0E0);

  static const Color lightTextPrimary = Color(0xFF1A1D1C);

  static const Color lightTextSecondary = Color(0xFF626A67);

  static const Color lightIcon = Color(0xFF3D4744);

  static const Color lightDisabled = Color(0xFFBDBDBD);

  // ===========================================================================
  // 🌙 DARK THEME
  // ===========================================================================

  static const Color darkBackground = Color(0xFF112D25);

  static const Color darkShadow = Color(0x42000000);

  static const Color darkSurfaceTint = Colors.transparent;

  static const Color darkSurface = Color(0xFF183E33);

  static const Color darkBorder = Color(0xFF4B5563);

  static const Color darkCard = Color(0xFF183E33);

  static const Color darkDivider = Color(0xFF2F3A44);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  static const Color darkTextSecondary = Color(0xFF9EABA7);

  static const Color darkIcon = Colors.white70;

  static const Color darkDisabled = Color(0xFF6B7280);

  static const Color darkTextDisabled = Color(0xFF5D6B67);

  // ===========================================================================
  // 💬 CHAT
  // ===========================================================================

  /// Message bubble sent by me (Light Theme).
  static const Color lightBubbleMe = Color(0xFFD2E8E2);

  /// Message bubble from other user (Light Theme).
  static const Color lightBubbleOther = Color(0xFFEAEAEA);

  /// Message bubble sent by me (Dark Theme).
  static const Color darkBubbleMe = Color(0xFF1E4D40);

  /// Message bubble from other user (Dark Theme).
  static const Color darkBubbleOther = Color(0xFF233B33);

  // ===========================================================================
  // 📶 USER STATUS
  // ===========================================================================

  //Last seen
  static const Color lastSeen = Color(0xFF0000FF);

  static const Color online = Color(0xFF2E7D32);

  static const Color offline = Color(0xFF757575);

  static const Color typing = Color(0xFF0288D1);

  // ===========================================================================
  // ⚠️ FEEDBACK
  // ===========================================================================

  static const Color success = Color(0xFF388E3C);

  static const Color warning = Color(0xFFF9A825);

  static const Color error = Color(0xFFD32F2F);

  static const Color info = Color(0xFF0288D1);

  // ===========================================================================
  // ✈️ TELEGRAM / ECE BLUE ACCENT TOKENS
  // ===========================================================================
  static const Color telegramBlue = Color(0xFF2481CC);
  static const Color telegramBlueDark = Color(0xFF50A7EA);

  // ===========================================================================
  // 🔲 COMMON
  // ===========================================================================

  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
}
