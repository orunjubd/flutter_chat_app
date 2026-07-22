import 'package:flutter/material.dart';

/// ===========================================================================
/// ECE Responsive Helper
/// ---------------------------------------------------------------------------
/// Centralized screen size utilities used throughout the application.
///
/// Breakpoints
/// - Mobile  : < 600
/// - Tablet  : 600 - 1023
/// - Desktop : >= 1024
///
/// This keeps MediaQuery logic out of feature screens.
/// ===========================================================================
class Responsive {
  const Responsive._();

  // ---------------------------------------------------------------------------
  // Breakpoints
  // ---------------------------------------------------------------------------

  static const double mobileBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  // ---------------------------------------------------------------------------
  // Screen Size
  // ---------------------------------------------------------------------------

  static Size screenSize(BuildContext context) {
    return MediaQuery.sizeOf(context);
  }

  static double width(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double height(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  // ---------------------------------------------------------------------------
  // Device Type
  // ---------------------------------------------------------------------------

  static bool isMobile(BuildContext context) {
    return width(context) < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    return width(context) >= mobileBreakpoint &&
        width(context) < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return width(context) >= desktopBreakpoint;
  }

  // ---------------------------------------------------------------------------
  // Orientation
  // ---------------------------------------------------------------------------

  static bool isPortrait(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  // ---------------------------------------------------------------------------
  // Responsive Value
  // ---------------------------------------------------------------------------

  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }

    if (isTablet(context)) {
      return tablet ?? mobile;
    }

    return mobile;
  }
}
