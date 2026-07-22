import 'package:flutter/material.dart';
import 'package:chat_app/core/extensions/chat_bubble_theme_extension.dart';
import 'package:chat_app/core/theme/app_colors.dart';

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

  /// Retrieves the custom chat bubble theme extension data securely from the active widget tree context.
  ChatBubbleThemeExtension get chatBubbleTheme =>
      theme.extension<ChatBubbleThemeExtension>()!;

  /// Current user's outgoing chat bubble color (Dynamic Light/Dark).
  Color get myBubbleColor => chatBubbleTheme.myBubbleColor;

  /// Conversational partner's incoming chat bubble color (Dynamic Light/Dark).
  Color get otherBubbleColor => chatBubbleTheme.otherBubbleColor;

  /// 🚀 THE ADAPTIVE READ RECEIPT COLOR SHORTCUT
  Color get readReceiptColor => chatBubbleTheme.readReceiptColor;

  // 🚀 THE ADAPTIVE UNREAD RECEIPT COLOR SHORTCUT
  Color get unreadReceiptColor => chatBubbleTheme.unreadReceiptColor;

  /// Current ColorScheme.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Current TextTheme.
  TextTheme get textTheme => theme.textTheme;

  /// Current AppBarTheme.
  AppBarThemeData get appBarTheme => theme.appBarTheme;

  /// Current InputDecorationTheme.
  InputDecorationThemeData get inputDecorationTheme =>
      theme.inputDecorationTheme;

  // ===========================================================================
  // 📝 UNIFIED SEMANTIC TYPOGRAPHY GETTERS
  // ===========================================================================

  /// Main App Bar Header typography style (Maps to global titleLarge).
  TextStyle? get titleText => textTheme.titleLarge;

  /// Secondary component headers or preview subtitle rows (Maps to global titleMedium).
  TextStyle? get subtitleText => textTheme.titleMedium;

  /// Primary chat message bubbles and description inputs (Maps to global bodyLarge).
  TextStyle? get bodyText => textTheme.bodyLarge;

  /// Perfect for normal alerts, input field entries, and middle-tier text cards!
  TextStyle? get bodyTextMedium => textTheme.bodyMedium;

  /// Perfect for customized buttons, action links, and chip tags!
  TextStyle? get labelTextLarge => textTheme.labelLarge;

  /// Perfect for capitalized section titles (e.g., "CHOOSE THEME")!
  TextStyle? get labelTextMedium => textTheme.labelMedium;

  /// Perfect for small section headers (e.g., "Settings")
  TextStyle? get captionText => textTheme.labelSmall;

  // ===========================================================================
  // Navigation helpers
  // ===========================================================================
  NavigatorState get navigator => Navigator.of(this);

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  // ===========================================================================
  // Brightness shortcut
  // ===========================================================================
  Brightness get brightness => theme.brightness;

  bool get isDark => brightness == Brightness.dark;

  bool get isLight => brightness == Brightness.light;

  // ===========================================================================
  // Radius helper shortcuts
  // ===========================================================================
  BorderRadius get defaultRadius => BorderRadius.circular(16);

  // ===========================================================================
  // Padding helper (optional) shortcuts
  // ===========================================================================
  EdgeInsets get pagePadding => const EdgeInsets.all(16);

  // ===========================================================================
  // errorText shortcuts
  // ===========================================================================
  /// High-readability critical failure error notifications.
  /// Automatically combines your text body sizes with active error colors!
  TextStyle? get errorText => textTheme.bodyMedium?.copyWith(color: errorColor);

  // ===========================================================================
  // Semantic Colors / Colors Shortcuts (For Dynamic Light/Dark)
  // ===========================================================================
  /// Current Card color.
  Color get cardColor => theme.cardColor;

  /// Current Divider color.
  Color get dividerColor => theme.dividerColor;

  /// Current Scaffold background color.
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;

  /// Current primary color.
  Color get primaryColor => theme.colorScheme.primary;

  // Current secondary color.
  Color get secondaryColor => theme.colorScheme.secondary;

  /// Current medium-emphasis text/icon gray color (Automatically switches light/dark shades).
  /// Perfect for unread counts, idle chat ticks, and secondary labels!
  Color get textSecondaryColor => theme.colorScheme.onSurfaceVariant;

  /// Current surface color.
  Color get surfaceColor => theme.colorScheme.surface;

  /// Current error color.
  Color get errorColor => theme.colorScheme.error;

  // Inside extension ThemeContextExtension on BuildContext in lib/core/theme/theme_extensions.dart

  // ===========================================================================
  // 📐 UNIFIED RESPONSIVE DIMENSION METRICS
  // ===========================================================================

  /// Real-time total physical device screen width resolution.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Real-time total physical device screen height resolution.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // ===========================================================================
  // ✉️ OUTGOING MESSAGES TEXT INK TOKENS
  // ===========================================================================

  /// High-contrast text color for my outgoing chat bubbles (Always crisp and legible).
  /// ✅ ফিক্সড: চ্যাট বাবল ডিরেক্ট কালার চিনবে না, সে এক্সটেনশন হয়ে অ্যাপ-কালার টোকেন রিড করবে
  Color get myBubbleTextPrimary => AppColors.white;

  /// Soft, semi-translucent metadata color for my outgoing timestamps and clock details.
  Color get myBubbleTextSecondary => AppColors.white70;

  // ===========================================================================
  // additional Colors / Colors Shortcuts (For Dynamic Light/Dark)
  // ===========================================================================
  // Color get onlineColor;

  // Color get offlineColor;

  // Color get typingColor;

  // Color get archiveColor;

  // Color get destructiveColor;
}
