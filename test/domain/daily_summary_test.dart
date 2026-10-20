import 'package:daylog/domain/aggregation_mode.dart';
import 'package:daylog/domain/daily_summary.dart';
import 'package:daylog/domain/macros.dart';
import 'package:daylog/domain/meal.dart';
import 'package:daylog/domain/measurement.dart';
import 'package:daylog/domain/metric.dart';
import 'package:daylog/domain/nutrition_goal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('aggregateMetric', () {
    final measurements = [
      Measurement(
        metricId: 1,
        value: 10,
        recordedAt: DateTime(2026, 10, 20, 8),
      ),
      Measurement(
        metricId: 1,
        value: 30,
        recordedAt: DateTime(2026, 10, 20, 12),
      ),
      Measurement(
        metricId: 1,
        value: 20,
        recordedAt: DateTime(2026, 10, 20, 9),
      ),
    ];

    test('last returns the value of the latest measurement', () {
      expect(aggregateMetric(measurements, AggregationMode.last), 30);
    });

    test('sum returns the sum of values', () {
      expect(aggregateMetric(measurements, AggregationMode.sum), 60);
    });

    test('avg returns the mean of values', () {
      expect(aggregateMetric(measurements, AggregationMode.avg), 20);
    });

    test('empty measurements yield 0 for every mode', () {
      for (final mode in AggregationMode.values) {
        expect(aggregateMetric([], mode), 0, reason: 'mode $mode');
      }
    });
  });

  group('totalMealMacros', () {
    test('sums each meal macros component-wise', () {
      final meals = [
        Meal(
          foodId: 1,
          grams: 100,
          macros: const Macros(kcal: 100, carbs: 10, protein: 20, fat: 5),
          consumedAt: DateTime(2026, 10, 20),
        ),
        Meal(
          foodId: 2,
          grams: 200,
          macros: const Macros(kcal: 250, carbs: 25, protein: 12, fat: 8),
          consumedAt: DateTime(2026, 10, 20),
        ),
      ];

      expect(
        totalMealMacros(meals),
        const Macros(kcal: 350, carbs: 35, protein: 32, fat: 13),
      );
    });

    test('empty meals yield zero macros', () {
      expect(
        totalMealMacros([]),
        const Macros(kcal: 0, carbs: 0, protein: 0, fat: 0),
      );
    });
  });

  group('computeDailySummary', () {
    final day = DateTime(2026, 10, 20);
    final metrics = [
      const Metric(name: 'weight', unit: 'kg', aggregationMode: AggregationMode.last, id: 1),
      const Metric(name: 'steps', unit: 'count', aggregationMode: AggregationMode.sum, id: 2),
    ];

    test('aggregates each metric from that day only and carries the goal', () {
      final measurements = [
        Measurement(metricId: 1, value: 70, recordedAt: DateTime(2026, 10, 20, 8)),
        Measurement(metricId: 1, value: 72, recordedAt: DateTime(2026, 10, 20, 20)),
        Measurement(metricId: 2, value: 5000, recordedAt: DateTime(2026, 10, 20, 9)),
        Measurement(metricId: 2, value: 3000, recordedAt: DateTime(2026, 10, 20, 10)),
        Measurement(metricId: 1, value: 99, recordedAt: DateTime(2026, 10, 21, 8)),
      ];
      final meals = [
        Meal(
          foodId: 1,
          grams: 250,
          macros: const Macros(kcal: 1000, carbs: 100, protein: 75, fat: 25),
          consumedAt: DateTime(2026, 10, 20, 12),
        ),
        Meal(
          foodId: 1,
          grams: 100,
          macros: const Macros(kcal: 9999, carbs: 1, protein: 1, fat: 1),
          consumedAt: DateTime(2026, 10, 21, 12),
        ),
      ];
      final goal = NutritionGoal(
        kcalTarget: 2000,
        carbPercent: 40,
        proteinPercent: 40,
        fatPercent: 20,
      );

      final summary = computeDailySummary(
        day: day,
        metrics: metrics,
        measurements: measurements,
        meals: meals,
        goal: goal,
      );

      expect(summary.metricAggregates, hasLength(2));
      final weight = summary.metricAggregates
          .firstWhere((a) => a.metric.id == 1);
      final steps = summary.metricAggregates
          .firstWhere((a) => a.metric.id == 2);
      expect(weight.value, 72);
      expect(steps.value, 8000);

      expect(
        summary.consumedMacros,
        const Macros(kcal: 1000, carbs: 100, protein: 75, fat: 25),
      );

      expect(summary.goal, same(goal));
      expect(summary.goal!.gramTargets, goal.gramTargets);
    });

    test('produces zero aggregates and null-free zero macros without data', () {
      final summary = computeDailySummary(
        day: day,
        metrics: metrics,
        measurements: const [],
        meals: const [],
        goal: null,
      );

      expect(summary.metricAggregates, hasLength(2));
      expect(summary.metricAggregates.map((a) => a.value), everyElement(0));
      expect(
        summary.consumedMacros,
        const Macros(kcal: 0, carbs: 0, protein: 0, fat: 0),
      );
      expect(summary.goal, isNull);
    });
  });
}
