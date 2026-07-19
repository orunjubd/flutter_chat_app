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

  static const Color lightSurface = Colors.white;

  /// TextField, Card and Input borders.
  static const Color lightBorder = Color(0xFFD0D5DD);

  static const Color lightCard = Colors.white;

  static const Color lightDivider = Color(0xFFE5E7EB);

  static const Color lightTextPrimary = Color(0xFF1A1D1C);

  static const Color lightTextSecondary = Color(0xFF626A67);

  static const Color lightIcon = Color(0xFF3D4744);

  static const Color lightDisabled = Color(0xFFBDBDBD);

  // ===========================================================================
  // 🌙 DARK THEME
  // ===========================================================================

  static const Color darkBackground = Color(0xFF112D25);

  static const Color darkSurface = Color(0xFF183E33);

  static const Color darkBorder = Color(0xFF4B5563);

  static const Color darkCard = Color(0xFF183E33);

  static const Color darkDivider = Color(0xFF374151);

  static const Color darkTextPrimary = Colors.white;

  static const Color darkTextSecondary = Color(0xFF9EABA7);

  static const Color darkIcon = Colors.white70;

  static const Color darkDisabled = Color(0xFF6B7280);

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
  // 🔲 COMMON
  // ===========================================================================

  static const Color white = Colors.white;

  static const Color black = Colors.black;

  static const Color transparent = Colors.transparent;
}
