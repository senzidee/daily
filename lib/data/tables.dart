import 'package:drift/drift.dart';

import '../domain/aggregation_mode.dart';

@DataClassName('DiaryEntryRow')
class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get textContent => text().nullable()();
  TextColumn get audioPath => text().nullable()();
}

@DataClassName('MetricRow')
class Metrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get unit => text()();
  TextColumn get aggregationMode => textEnum<AggregationMode>()();
}

@DataClassName('MeasurementRow')
class Measurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get metricId => integer().references(Metrics, #id)();
  RealColumn get value => real()();
  DateTimeColumn get recordedAt => dateTime()();
}

@DataClassName('FoodRow')
class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  RealColumn get kcal => real()();
  RealColumn get carbs => real()();
  RealColumn get protein => real()();
  RealColumn get fat => real()();
}

@DataClassName('MealRow')
class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get foodId => integer().references(Foods, #id)();
  RealColumn get grams => real()();
  RealColumn get kcal => real()();
  RealColumn get carbs => real()();
  RealColumn get protein => real()();
  RealColumn get fat => real()();
  DateTimeColumn get consumedAt => dateTime()();
}

@DataClassName('NutritionGoalRow')
class NutritionGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get kcalTarget => real()();
  RealColumn get carbPercent => real()();
  RealColumn get proteinPercent => real()();
  RealColumn get fatPercent => real()();
}
