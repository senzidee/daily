import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/meal_repository.dart';
import '../domain/food.dart';
import '../domain/meal.dart';
import 'database_provider.dart';

final mealRepositoryProvider = Provider<MealRepository>(
  (ref) => DriftMealRepository(ref.watch(databaseProvider)),
);

final mealsProvider = AsyncNotifierProvider<MealsNotifier, List<Meal>>(
  MealsNotifier.new,
);

class MealsNotifier extends AsyncNotifier<List<Meal>> {
  MealRepository get _repo => ref.read(mealRepositoryProvider);

  @override
  Future<List<Meal>> build() => ref.watch(mealRepositoryProvider).getAll();

  Future<void> add({
    required Food food,
    required double grams,
    required DateTime consumedAt,
  }) async {
    await _repo.add(food: food, grams: grams, consumedAt: consumedAt);
    await _refresh();
  }

  Future<void> updateMeal(Meal meal) async {
    await _repo.update(meal);
    await _refresh();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await _refresh();
  }

  Future<void> _refresh() async {
    await update((_) => _repo.getAll());
  }
}
