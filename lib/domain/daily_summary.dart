import 'aggregation_mode.dart';
import 'day.dart';
import 'macros.dart';
import 'meal.dart';
import 'measurement.dart';
import 'metric.dart';
import 'nutrition_goal.dart';

class MetricAggregate {
  const MetricAggregate({required this.metric, required this.value});

  final Metric metric;
  final double value;
}

class DailySummary {
  const DailySummary({
    required this.metricAggregates,
    required this.consumedMacros,
    required this.goal,
  });

  final List<MetricAggregate> metricAggregates;
  final Macros consumedMacros;
  final NutritionGoal? goal;
}

double aggregateMetric(List<Measurement> measurements, AggregationMode mode) {
  if (measurements.isEmpty) {
    return 0;
  }
  switch (mode) {
    case AggregationMode.last:
      return measurements
          .reduce((a, b) => a.recordedAt.isAfter(b.recordedAt) ? a : b)
          .value;
    case AggregationMode.sum:
      return measurements.fold(0.0, (acc, m) => acc + m.value);
    case AggregationMode.avg:
      final sum = measurements.fold(0.0, (acc, m) => acc + m.value);
      return sum / measurements.length;
  }
}

Macros totalMealMacros(Iterable<Meal> meals) {
  const zero = Macros(kcal: 0, carbs: 0, protein: 0, fat: 0);
  return meals.fold(zero, (acc, meal) => acc + meal.macros);
}

DailySummary computeDailySummary({
  required DateTime day,
  required List<Metric> metrics,
  required List<Measurement> measurements,
  required List<Meal> meals,
  required NutritionGoal? goal,
}) {
  final dayMeasurements = measurements
      .where((m) => isSameDay(m.recordedAt, day))
      .toList();
  final dayMeals = meals.where((m) => isSameDay(m.consumedAt, day)).toList();

  final metricAggregates = metrics.map((metric) {
    final metricMeasurements = dayMeasurements
        .where((m) => m.metricId == metric.id)
        .toList();
    return MetricAggregate(
      metric: metric,
      value: aggregateMetric(metricMeasurements, metric.aggregationMode),
    );
  }).toList();

  return DailySummary(
    metricAggregates: metricAggregates,
    consumedMacros: totalMealMacros(dayMeals),
    goal: goal,
  );
}
