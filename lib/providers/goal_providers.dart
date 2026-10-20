import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/nutrition_goal_repository.dart';
import '../domain/nutrition_goal.dart';
import 'database_provider.dart';

final nutritionGoalRepositoryProvider = Provider<NutritionGoalRepository>(
  (ref) => DriftNutritionGoalRepository(ref.watch(databaseProvider)),
);

class NutritionGoalNotifier extends AsyncNotifier<NutritionGoal?> {
  @override
  Future<NutritionGoal?> build() {
    return ref.watch(nutritionGoalRepositoryProvider).get();
  }

  Future<void> save(NutritionGoal goal) async {
    await ref.read(nutritionGoalRepositoryProvider).save(goal);
    state = AsyncData(goal);
  }
}

final nutritionGoalProvider =
    AsyncNotifierProvider<NutritionGoalNotifier, NutritionGoal?>(
  NutritionGoalNotifier.new,
);
