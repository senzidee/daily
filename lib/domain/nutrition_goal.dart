import 'macros.dart';

class NutritionGoal {
  NutritionGoal({
    required this.kcalTarget,
    required this.carbPercent,
    required this.proteinPercent,
    required this.fatPercent,
    this.id,
  }) {
    final total = carbPercent + proteinPercent + fatPercent;
    if ((total - 100).abs() > 0.0001) {
      throw ArgumentError(
        'carbPercent + proteinPercent + fatPercent must equal 100, got $total',
      );
    }
  }

  final int? id;
  final double kcalTarget;
  final double carbPercent;
  final double proteinPercent;
  final double fatPercent;

  Macros get gramTargets => Macros(
        kcal: kcalTarget,
        carbs: kcalTarget * carbPercent / 100 / 4,
        protein: kcalTarget * proteinPercent / 100 / 4,
        fat: kcalTarget * fatPercent / 100 / 9,
      );
}

Macros nutritionGoalMacros(NutritionGoal goal) => goal.gramTargets;
