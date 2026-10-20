import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/daily_summary.dart';
import 'goal_providers.dart';
import 'meal_providers.dart';
import 'metric_providers.dart';
import 'selected_day_provider.dart';

final dailySummaryProvider = FutureProvider<DailySummary>((ref) async {
  final day = ref.watch(selectedDayProvider);
  final metrics = await ref.watch(metricsProvider.future);
  final measurements = await ref.watch(measurementsProvider.future);
  final meals = await ref.watch(mealsProvider.future);
  final goal = await ref.watch(nutritionGoalProvider.future);
  return computeDailySummary(
    day: day,
    metrics: metrics,
    measurements: measurements,
    meals: meals,
    goal: goal,
  );
});
