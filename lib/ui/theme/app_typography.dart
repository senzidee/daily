import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String family = 'Lato';

  static TextTheme textTheme(TextTheme base) {
    return base
        .copyWith(
          displayLarge: _style(
            base.displayLarge,
            35,
            FontWeight.w900,
            height: 1.1,
          ),
          displayMedium: _style(
            base.displayMedium,
            30,
            FontWeight.w700,
            height: 1.15,
          ),
          headlineLarge: _style(
            base.headlineLarge,
            28,
            FontWeight.w700,
            height: 1.2,
          ),
          headlineMedium: _style(
            base.headlineMedium,
            25,
            FontWeight.w700,
            height: 1.2,
          ),
          headlineSmall: _style(
            base.headlineSmall,
            22,
            FontWeight.w700,
            height: 1.25,
          ),
          titleLarge: _style(base.titleLarge, 20, FontWeight.w700, height: 1.3),
          titleMedium: _style(
            base.titleMedium,
            17,
            FontWeight.w700,
            height: 1.3,
          ),
          titleSmall: _style(
            base.titleSmall,
            15,
            FontWeight.w700,
            height: 1.35,
          ),
          bodyLarge: _style(base.bodyLarge, 17, FontWeight.w400, height: 1.45),
          bodyMedium: _style(
            base.bodyMedium,
            15,
            FontWeight.w400,
            height: 1.45,
          ),
          bodySmall: _style(base.bodySmall, 13, FontWeight.w400, height: 1.4),
          labelLarge: _style(base.labelLarge, 15, FontWeight.w700, height: 1.2),
          labelMedium: _style(
            base.labelMedium,
            13,
            FontWeight.w700,
            height: 1.2,
            letterSpacing: 0.3,
          ),
          labelSmall: _style(
            base.labelSmall,
            12,
            FontWeight.w700,
            height: 1.2,
            letterSpacing: 0.6,
          ),
        )
        .apply(fontFamily: family);
  }

  static TextStyle _style(
    TextStyle? base,
    double size,
    FontWeight weight, {
    double? height,
    double? letterSpacing,
  }) {
    return (base ?? const TextStyle()).copyWith(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
