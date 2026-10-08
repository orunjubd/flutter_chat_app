import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CallColorsExtension extends ThemeExtension<CallColorsExtension> {
  const CallColorsExtension({
    required this.accept,
    required this.decline,
    required this.screenBackground,
  });

  final Color accept;
  final Color decline;
  final Color screenBackground;

  static const standard = CallColorsExtension(
    accept: AppColors.callAccept,
    decline: AppColors.callDecline,
    screenBackground: AppColors.callScreenBackground,
  );

  @override
  CallColorsExtension copyWith({
    Color? accept,
    Color? decline,
    Color? screenBackground,
  }) => CallColorsExtension(
    accept: accept ?? this.accept,
    decline: decline ?? this.decline,
    screenBackground: screenBackground ?? this.screenBackground,
  );

  @override
  CallColorsExtension lerp(
    ThemeExtension<CallColorsExtension>? other,
    double t,
  ) {
    if (other is! CallColorsExtension) return this;
    return CallColorsExtension(
      accept: Color.lerp(accept, other.accept, t)!,
      decline: Color.lerp(decline, other.decline, t)!,
      screenBackground: Color.lerp(
        screenBackground,
        other.screenBackground,
        t,
      )!,
    );
  }
}
