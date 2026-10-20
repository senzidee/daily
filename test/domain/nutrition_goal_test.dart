import 'package:daylog/domain/macros.dart';
import 'package:daylog/domain/nutrition_goal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NutritionGoal', () {
    test('derives gram targets from kcal + energy percentages', () {
      final goal = NutritionGoal(
        kcalTarget: 2000,
        carbPercent: 40,
        proteinPercent: 40,
        fatPercent: 20,
      );

      expect(goal.gramTargets, const Macros(kcal: 2000, carbs: 200, protein: 200, fat: 44.44444444444444));
    });

    test('nutritionGoalMacros returns the derived gram targets', () {
      final goal = NutritionGoal(
        kcalTarget: 1800,
        carbPercent: 50,
        proteinPercent: 30,
        fatPercent: 20,
      );

      expect(nutritionGoalMacros(goal), goal.gramTargets);
    });

    test('accepts percentages that sum to 100 within tolerance', () {
      expect(
        () => NutritionGoal(
          kcalTarget: 2000,
          carbPercent: 33.33333333333333,
          proteinPercent: 33.33333333333333,
          fatPercent: 33.33333333333334,
        ),
        returnsNormally,
      );
    });

    test('throws ArgumentError when percentages do not sum to 100', () {
      expect(
        () => NutritionGoal(
          kcalTarget: 2000,
          carbPercent: 40,
          proteinPercent: 40,
          fatPercent: 30,
        ),
        throwsArgumentError,
      );
    });
  });
}
