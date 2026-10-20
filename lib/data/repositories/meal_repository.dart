import 'package:drift/drift.dart';

import '../../domain/food.dart';
import '../../domain/macros.dart';
import '../../domain/meal.dart';
import '../app_database.dart';

abstract class MealRepository {
  Future<List<Meal>> getAll();

  Stream<List<Meal>> watchAll();

  Future<Meal> add({
    required Food food,
    required double grams,
    required DateTime consumedAt,
  });

  Future<void> update(Meal meal);

  Future<void> delete(int id);
}

class DriftMealRepository implements MealRepository {
  DriftMealRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Meal>> getAll() async {
    final rows = await (_db.select(_db.meals)
          ..orderBy([(t) => OrderingTerm.asc(t.consumedAt)]))
        .get();
    return rows.map(_toMeal).toList();
  }

  @override
  Stream<List<Meal>> watchAll() {
    return (_db.select(_db.meals)
          ..orderBy([(t) => OrderingTerm.asc(t.consumedAt)]))
        .watch()
        .map((rows) => rows.map(_toMeal).toList());
  }

  @override
  Future<Meal> add({
    required Food food,
    required double grams,
    required DateTime consumedAt,
  }) async {
    final macros = scaleMealMacros(food.per100g, grams);
    final id = await _db.insertMeal(
      foodId: food.id!,
      grams: grams,
      kcal: macros.kcal,
      carbs: macros.carbs,
      protein: macros.protein,
      fat: macros.fat,
      consumedAt: consumedAt,
    );
    return Meal(
      id: id,
      foodId: food.id!,
      grams: grams,
      macros: macros,
      consumedAt: consumedAt,
    );
  }

  @override
  Future<void> update(Meal meal) async {
    final food = await _db.foodById(meal.foodId);
    if (food == null) {
      throw StateError('Food with id ${meal.foodId} not found');
    }
    final macros = scaleMealMacros(
      Macros(kcal: food.kcal, carbs: food.carbs, protein: food.protein, fat: food.fat),
      meal.grams,
    );
    await _db.updateMeal(
      id: meal.id!,
      foodId: meal.foodId,
      grams: meal.grams,
      kcal: macros.kcal,
      carbs: macros.carbs,
      protein: macros.protein,
      fat: macros.fat,
      consumedAt: meal.consumedAt,
    );
  }

  @override
  Future<void> delete(int id) async {
    await _db.deleteMeal(id);
  }

  Meal _toMeal(MealRow row) => Meal(
        id: row.id,
        foodId: row.foodId,
        grams: row.grams,
        macros: Macros(kcal: row.kcal, carbs: row.carbs, protein: row.protein, fat: row.fat),
        consumedAt: row.consumedAt,
      );
}
