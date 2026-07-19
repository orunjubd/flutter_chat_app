import 'package:flutter/material.dart';

class AppTextTheme {
  const AppTextTheme._();

  static const TextTheme textTheme = TextTheme(
    headlineSmall: TextStyle(fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(fontSize: 15),
    labelLarge: TextStyle(fontWeight: FontWeight.w600),
  );
}
//------------------------------------------------------------------------------
// Extension to access the AppTextTheme from BuildContext

// extension AppTextThemeExtension on BuildContext {
//   TextTheme get textTheme => AppTextTheme.textTheme;
// }
