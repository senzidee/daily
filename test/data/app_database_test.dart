import 'package:daylog/data/app_database.dart';
import 'package:daylog/domain/aggregation_mode.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Metrics', () {
    test('insertMetric round-trips all aggregation modes via textEnum', () async {
      for (final mode in AggregationMode.values) {
        await db.insertMetric(
          MetricsCompanion.insert(name: 'metric_${mode.name}', unit: 'u', aggregationMode: mode),
        );
      }

      final metrics = await db.watchAllMetrics().first;
      expect(metrics.map((m) => m.aggregationMode).toSet(), AggregationMode.values.toSet());
    });

    test('seedWeightIfEmpty is idempotent', () async {
      await db.seedWeightIfEmpty();
      await db.seedWeightIfEmpty();

      final metrics = await db.watchAllMetrics().first;
      expect(metrics.length, 1);
      expect(metrics.single.name, 'weight');
      expect(metrics.single.unit, 'kg');
      expect(metrics.single.aggregationMode, AggregationMode.last);
    });

    test('seedWeightIfEmpty does not add a duplicate when metrics exist', () async {
      await db.insertMetric(
        MetricsCompanion.insert(name: 'custom', unit: 'x', aggregationMode: AggregationMode.sum),
      );
      await db.seedWeightIfEmpty();

      final metrics = await db.watchAllMetrics().first;
      expect(metrics.length, 1);
      expect(metrics.single.name, 'custom');
    });
  });

  group('Measurements', () {
    test('insertMeasurement and watchMeasurementsForMetric', () async {
      final metricId = await db.insertMetric(
        MetricsCompanion.insert(name: 'weight', unit: 'kg', aggregationMode: AggregationMode.last),
      );

      await db.insertMeasurement(
        metricId: metricId,
        value: 70.5,
        recordedAt: DateTime(2026, 10, 20, 8),
      );
      await db.insertMeasurement(
        metricId: metricId,
        value: 71.0,
        recordedAt: DateTime(2026, 10, 20, 9),
      );

      final rows = await db.watchMeasurementsForMetric(metricId).first;
      expect(rows.map((r) => r.value).toList(), [70.5, 71.0]);
      expect(rows.map((r) => r.metricId).toSet(), {metricId});
    });
  });

  group('DiaryEntries', () {
    test('watchEntriesForDay filters by day boundary', () async {
      final day = DateTime(2026, 10, 20);
      await db.insertEntry(occurredAt: DateTime(2026, 10, 20, 0, 0), text: 'start');
      await db.insertEntry(occurredAt: DateTime(2026, 10, 20, 23, 59), text: 'end');
      await db.insertEntry(occurredAt: DateTime(2026, 10, 19, 23, 59), text: 'prev');
      await db.insertEntry(occurredAt: DateTime(2026, 10, 21, 0, 0), text: 'next');

      final entries = await db.watchEntriesForDay(day).first;
      expect(entries.map((e) => e.textContent).toList(), ['start', 'end']);
    });

    test('insertEntry stores audioPath', () async {
      await db.insertEntry(occurredAt: DateTime(2026, 10, 20, 9), audioPath: '/tmp/a.m4a');

      final entries = await db.watchEntriesForDay(DateTime(2026, 10, 20)).first;
      expect(entries.single.textContent, isNull);
      expect(entries.single.audioPath, '/tmp/a.m4a');
    });

    test('updateEntry returns true and updates fields', () async {
      final id = await db.insertEntry(occurredAt: DateTime(2026, 10, 20, 9), text: 'old');

      final updated = await db.updateEntry(
        id: id,
        occurredAt: DateTime(2026, 10, 20, 10),
        text: 'new',
      );
      expect(updated, isTrue);

      final entries = await db.watchEntriesForDay(DateTime(2026, 10, 20)).first;
      expect(entries.single.textContent, 'new');
      expect(entries.single.occurredAt, DateTime(2026, 10, 20, 10));
    });

    test('updateEntry returns false for unknown id', () async {
      final updated = await db.updateEntry(
        id: 999,
        occurredAt: DateTime(2026, 10, 20, 9),
        text: 'x',
      );
      expect(updated, isFalse);
    });

    test('deleteEntry removes the entry', () async {
      final id = await db.insertEntry(occurredAt: DateTime(2026, 10, 20, 9), text: 'x');

      final deleted = await db.deleteEntry(id);
      expect(deleted, 1);

      final entries = await db.watchEntriesForDay(DateTime(2026, 10, 20)).first;
      expect(entries, isEmpty);
    });
  });

  group('Foods', () {
    test('upsertFood inserts then updates by unique name', () async {
      final id1 = await db.upsertFood(
        FoodsCompanion.insert(name: 'Apple', kcal: 52, carbs: 14, protein: 0.3, fat: 0.2),
      );
      final id2 = await db.upsertFood(
        FoodsCompanion.insert(name: 'Apple', kcal: 60, carbs: 15, protein: 0.4, fat: 0.3),
      );
      expect(id1, id2);

      final foods = await db.select(db.foods).get();
      expect(foods.length, 1);
      expect(foods.single.kcal, 60);
    });

    test('foodByName returns null when absent', () async {
      expect(await db.foodByName('Banana'), isNull);
    });

    test('foodById returns the row', () async {
      final id = await db.upsertFood(
        FoodsCompanion.insert(name: 'Rice', kcal: 130, carbs: 28, protein: 2.7, fat: 0.3),
      );

      final food = await db.foodById(id);
      expect(food!.name, 'Rice');
      expect(food.kcal, 130);
    });
  });

  group('Meals', () {
    test('insert, watch, update and delete a meal', () async {
      final foodId = await db.upsertFood(
        FoodsCompanion.insert(name: 'Rice', kcal: 130, carbs: 28, protein: 2.7, fat: 0.3),
      );

      final mealId = await db.insertMeal(
        foodId: foodId,
        grams: 150,
        kcal: 195,
        carbs: 42,
        protein: 4.05,
        fat: 0.45,
        consumedAt: DateTime(2026, 10, 20, 12),
      );

      var meals = await db.watchMealsForDay(DateTime(2026, 10, 20)).first;
      expect(meals.single.foodId, foodId);
      expect(meals.single.grams, 150);

      final updated = await db.updateMeal(
        id: mealId,
        foodId: foodId,
        grams: 200,
        kcal: 260,
        carbs: 56,
        protein: 5.4,
        fat: 0.6,
        consumedAt: DateTime(2026, 10, 20, 13),
      );
      expect(updated, isTrue);

      meals = await db.watchMealsForDay(DateTime(2026, 10, 20)).first;
      expect(meals.single.grams, 200);

      final deleted = await db.deleteMeal(mealId);
      expect(deleted, 1);

      meals = await db.watchMealsForDay(DateTime(2026, 10, 20)).first;
      expect(meals, isEmpty);
    });

    test('watchMealsForDay filters by day boundary', () async {
      final foodId = await db.upsertFood(
        FoodsCompanion.insert(name: 'Rice', kcal: 130, carbs: 28, protein: 2.7, fat: 0.3),
      );
      Future<int> add(DateTime at) => db.insertMeal(
            foodId: foodId,
            grams: 100,
            kcal: 130,
            carbs: 28,
            protein: 2.7,
            fat: 0.3,
            consumedAt: at,
          );

      await add(DateTime(2026, 10, 20, 8));
      await add(DateTime(2026, 10, 19, 23, 59));
      await add(DateTime(2026, 10, 21, 0, 0));

      final meals = await db.watchMealsForDay(DateTime(2026, 10, 20)).first;
      expect(meals.length, 1);
    });
  });

  group('NutritionGoals', () {
    test('upsertGoal replaces the single row', () async {
      expect(await db.getGoal(), isNull);

      await db.upsertGoal(
        NutritionGoalsCompanion.insert(kcalTarget: 2000, carbPercent: 50, proteinPercent: 20, fatPercent: 30),
      );

      var goal = await db.getGoal();
      expect(goal!.kcalTarget, 2000);

      await db.upsertGoal(
        NutritionGoalsCompanion.insert(kcalTarget: 2500, carbPercent: 40, proteinPercent: 30, fatPercent: 30),
      );

      final goals = await db.select(db.nutritionGoals).get();
      expect(goals.length, 1);
      expect(goals.single.kcalTarget, 2500);

      goal = await db.getGoal();
      expect(goal!.kcalTarget, 2500);
    });
  });
}
