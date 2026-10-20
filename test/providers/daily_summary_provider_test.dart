import 'package:daylog/data/app_database.dart';
import 'package:daylog/domain/aggregation_mode.dart';
import 'package:daylog/domain/food.dart';
import 'package:daylog/domain/macros.dart';
import 'package:daylog/domain/nutrition_goal.dart';
import 'package:daylog/providers/daily_summary_provider.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/providers/goal_providers.dart';
import 'package:daylog/providers/meal_providers.dart';
import 'package:daylog/providers/metric_providers.dart';
import 'package:daylog/providers/selected_day_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<Food> insertFood() async {
    final id = await db.upsertFood(
      FoodsCompanion.insert(
        name: 'test food',
        kcal: 400,
        carbs: 40,
        protein: 30,
        fat: 10,
      ),
    );
    return Food(
      id: id,
      name: 'test food',
      per100g: const Macros(kcal: 400, carbs: 40, protein: 30, fat: 10),
    );
  }

  test('aggregates measurements and meals for the selected day', () async {
    final day = DateTime(2026, 10, 20);
    container.read(selectedDayProvider.notifier).setDay(day);

    await container.read(metricsProvider.future);
    final weightId =
        container.read(metricsProvider).requireValue.first.id!;

    await container
        .read(metricsProvider.notifier)
        .addMetric('steps', 'count', AggregationMode.sum);
    final stepsId = container
        .read(metricsProvider)
        .requireValue
        .firstWhere((m) => m.name == 'steps')
        .id!;

    final measurements = container.read(measurementsProvider.notifier);
    await measurements.addMeasurement(weightId, 70, DateTime(2026, 10, 20, 8));
    await measurements.addMeasurement(weightId, 72, DateTime(2026, 10, 20, 20));
    await measurements.addMeasurement(stepsId, 5000, DateTime(2026, 10, 20, 9));
    await measurements.addMeasurement(stepsId, 3000, DateTime(2026, 10, 20, 10));
    await measurements.addMeasurement(weightId, 99, DateTime(2026, 10, 21, 8));

    final food = await insertFood();
    await container.read(mealsProvider.notifier).add(
          food: food,
          grams: 250,
          consumedAt: DateTime(2026, 10, 20, 12),
        );
    await container.read(mealsProvider.notifier).add(
          food: food,
          grams: 100,
          consumedAt: DateTime(2026, 10, 21, 12),
        );

    final goal = NutritionGoal(
      kcalTarget: 2000,
      carbPercent: 40,
      proteinPercent: 40,
      fatPercent: 20,
    );
    await container.read(nutritionGoalProvider.notifier).save(goal);

    final summary = await container.read(dailySummaryProvider.future);

    final weight = summary.metricAggregates
        .firstWhere((a) => a.metric.id == weightId);
    final steps = summary.metricAggregates
        .firstWhere((a) => a.metric.id == stepsId);
    expect(weight.value, 72);
    expect(steps.value, 8000);

    expect(
      summary.consumedMacros,
      const Macros(kcal: 1000, carbs: 100, protein: 75, fat: 25),
    );

    expect(summary.goal!.kcalTarget, 2000);
    expect(summary.goal!.gramTargets, goal.gramTargets);
  });
}
