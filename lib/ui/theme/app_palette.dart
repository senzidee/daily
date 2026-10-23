import 'package:flutter/material.dart';

/// Data-viz accents that sit on top of the Material 3 color scheme.
///
/// UI chrome keeps using [ColorScheme] roles; these colors are reserved for
/// nutrition macros, metric accents and progress, so values stay readable in
/// both light and dark mode.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.kcal,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.success,
    required this.cardGradients,
  });

  final Color kcal;
  final Color carbs;
  final Color protein;
  final Color fat;
  final Color success;
  final List<List<Color>> cardGradients;

  static const AppPalette light = AppPalette(
    kcal: Color(0xFFE8833A),
    carbs: Color(0xFF3A8FE8),
    protein: Color(0xFF8C5BD8),
    fat: Color(0xFF3FA86A),
    success: Color(0xFF3FA86A),
    cardGradients: [
      [Color(0xFF6C4DD8), Color(0xFF3A8FE8)],
      [Color(0xFFE8833A), Color(0xFFF2C14E)],
      [Color(0xFF3FA86A), Color(0xFF56C8B0)],
    ],
  );

  static const AppPalette dark = AppPalette(
    kcal: Color(0xFFFFA45C),
    carbs: Color(0xFF6FB6FF),
    protein: Color(0xFFB48CFF),
    fat: Color(0xFF6BD69A),
    success: Color(0xFF6BD69A),
    cardGradients: [
      [Color(0xFF8A6BF0), Color(0xFF5EA8FF)],
      [Color(0xFFFFA45C), Color(0xFFFFD479)],
      [Color(0xFF6BD69A), Color(0xFF7ADDD0)],
    ],
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? light;

  @override
  AppPalette copyWith({
    Color? kcal,
    Color? carbs,
    Color? protein,
    Color? fat,
    Color? success,
    List<List<Color>>? cardGradients,
  }) {
    return AppPalette(
      kcal: kcal ?? this.kcal,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      success: success ?? this.success,
      cardGradients: cardGradients ?? this.cardGradients,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      kcal: Color.lerp(kcal, other.kcal, t) ?? kcal,
      carbs: Color.lerp(carbs, other.carbs, t) ?? carbs,
      protein: Color.lerp(protein, other.protein, t) ?? protein,
      fat: Color.lerp(fat, other.fat, t) ?? fat,
      success: Color.lerp(success, other.success, t) ?? success,
      cardGradients: t < 0.5 ? cardGradients : other.cardGradients,
    );
  }
}
