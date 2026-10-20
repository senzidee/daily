import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/aggregation_mode.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [DiaryEntries, Metrics, Measurements, Foods, Meals, NutritionGoals],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() => driftDatabase(name: 'daylog');

  Stream<List<MetricRow>> watchAllMetrics() => select(metrics).watch();

  Future<int> insertMetric(MetricsCompanion metric) => into(metrics).insert(metric);

  Future<void> seedWeightIfEmpty() async {
    final count = await metrics.count().getSingle();
    if (count == 0) {
      await into(metrics).insert(
        MetricsCompanion.insert(
          name: 'weight',
          unit: 'kg',
          aggregationMode: AggregationMode.last,
        ),
      );
    }
  }

  Stream<List<MeasurementRow>> watchMeasurementsForMetric(int metricId) {
    return (select(measurements)
          ..where((t) => t.metricId.equals(metricId))
          ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
        .watch();
  }

  Future<int> insertMeasurement({
    required int metricId,
    required double value,
    required DateTime recordedAt,
  }) {
    return into(measurements).insert(
      MeasurementsCompanion.insert(
        metricId: metricId,
        value: value,
        recordedAt: recordedAt,
      ),
    );
  }

  Stream<List<DiaryEntryRow>> watchEntriesForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (select(diaryEntries)
          ..where(
            (t) =>
                t.occurredAt.isBiggerOrEqualValue(start) &
                t.occurredAt.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
        .watch();
  }

  Future<int> insertEntry({
    required DateTime occurredAt,
    String? text,
    String? audioPath,
  }) {
    return into(diaryEntries).insert(
      DiaryEntriesCompanion.insert(
        occurredAt: occurredAt,
        textContent: Value(text),
        audioPath: Value(audioPath),
      ),
    );
  }

  Future<bool> updateEntry({
    required int id,
    required DateTime occurredAt,
    String? text,
    String? audioPath,
  }) async {
    final rows = await (update(diaryEntries)..where((t) => t.id.equals(id)))
        .write(
      DiaryEntriesCompanion(
        occurredAt: Value(occurredAt),
        textContent: Value(text),
        audioPath: Value(audioPath),
      ),
    );
    return rows > 0;
  }

  Future<int> deleteEntry(int id) =>
      (delete(diaryEntries)..where((t) => t.id.equals(id))).go();

  Future<FoodRow?> foodByName(String name) =>
      (select(foods)..where((t) => t.name.equals(name))).getSingleOrNull();

  Future<int> upsertFood(FoodsCompanion food) {
    return into(foods).insert(
      food,
      onConflict: DoUpdate(
        (_) => food,
        target: [foods.name],
      ),
    );
  }

  Future<FoodRow?> foodById(int id) =>
      (select(foods)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<MealRow>> watchMealsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (select(meals)
          ..where(
            (t) =>
                t.consumedAt.isBiggerOrEqualValue(start) &
                t.consumedAt.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.consumedAt)]))
        .watch();
  }

  Future<int> insertMeal({
    required int foodId,
    required double grams,
    required double kcal,
    required double carbs,
    required double protein,
    required double fat,
    required DateTime consumedAt,
  }) {
    return into(meals).insert(
      MealsCompanion.insert(
        foodId: foodId,
        grams: grams,
        kcal: kcal,
        carbs: carbs,
        protein: protein,
        fat: fat,
        consumedAt: consumedAt,
      ),
    );
  }

  Future<bool> updateMeal({
    required int id,
    required int foodId,
    required double grams,
    required double kcal,
    required double carbs,
    required double protein,
    required double fat,
    required DateTime consumedAt,
  }) async {
    final rows = await (update(meals)..where((t) => t.id.equals(id))).write(
      MealsCompanion(
        foodId: Value(foodId),
        grams: Value(grams),
        kcal: Value(kcal),
        carbs: Value(carbs),
        protein: Value(protein),
        fat: Value(fat),
        consumedAt: Value(consumedAt),
      ),
    );
    return rows > 0;
  }

  Future<int> deleteMeal(int id) =>
      (delete(meals)..where((t) => t.id.equals(id))).go();

  Future<NutritionGoalRow?> getGoal() =>
      select(nutritionGoals).getSingleOrNull();

  Future<void> upsertGoal(NutritionGoalsCompanion goal) async {
    final existing = await getGoal();
    if (existing == null) {
      await into(nutritionGoals).insert(goal);
    } else {
      await (update(nutritionGoals)..where((t) => t.id.equals(existing.id)))
          .write(goal);
    }
  }
}
