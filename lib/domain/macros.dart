class Macros {
  const Macros({
    required this.kcal,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  final double kcal;
  final double carbs;
  final double protein;
  final double fat;

  Macros operator +(Macros other) => Macros(
        kcal: kcal + other.kcal,
        carbs: carbs + other.carbs,
        protein: protein + other.protein,
        fat: fat + other.fat,
      );

  Macros operator *(double factor) => Macros(
        kcal: kcal * factor,
        carbs: carbs * factor,
        protein: protein * factor,
        fat: fat * factor,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Macros &&
          other.kcal == kcal &&
          other.carbs == carbs &&
          other.protein == protein &&
          other.fat == fat;

  @override
  int get hashCode => Object.hash(kcal, carbs, protein, fat);

  @override
  String toString() =>
      'Macros(kcal: $kcal, carbs: $carbs, protein: $protein, fat: $fat)';
}

Macros scaleMealMacros(Macros per100g, double grams) => per100g * (grams / 100);
