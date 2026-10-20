import 'package:daylog/data/app_database.dart';
import 'package:daylog/domain/food.dart';
import 'package:daylog/domain/macros.dart';
import 'package:daylog/domain/meal.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/providers/meal_providers.dart';
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

  Future<Food> insertFood({
    required double kcal,
    required double carbs,
    required double protein,
    required double fat,
  }) async {
    final id = await db.upsertFood(
      FoodsCompanion.insert(
        name: 'test food',
        kcal: kcal,
        carbs: carbs,
        protein: protein,
        fat: fat,
      ),
    );
    return Food(
      id: id,
      name: 'test food',
      per100g: Macros(kcal: kcal, carbs: carbs, protein: protein, fat: fat),
    );
  }

  test('add scales per-100g macros by grams', () async {
    final food = await insertFood(kcal: 100, carbs: 50, protein: 10, fat: 5);

    final notifier = container.read(mealsProvider.notifier);

    await notifier.add(
      food: food,
      grams: 250,
      consumedAt: DateTime(2026, 10, 20, 12),
    );

    final meals = container.read(mealsProvider).value!;
    expect(meals.length, 1);
    expect(meals.single.foodId, food.id);
    expect(meals.single.grams, 250);
    expect(meals.single.macros.kcal, 250);
    expect(meals.single.macros.carbs, 125);
    expect(meals.single.macros.protein, 25);
    expect(meals.single.macros.fat, 12.5);
  });

  test('update recomputes macros from new grams', () async {
    final food = await insertFood(kcal: 100, carbs: 50, protein: 10, fat: 5);

    final notifier = container.read(mealsProvider.notifier);

    await notifier.add(
      food: food,
      grams: 100,
      consumedAt: DateTime(2026, 10, 20, 12),
    );
    var meal = container.read(mealsProvider).value!.single;
    expect(meal.macros.kcal, 100);

    await notifier.updateMeal(
      Meal(
        id: meal.id,
        foodId: meal.foodId,
        grams: 200,
        macros: meal.macros,
        consumedAt: meal.consumedAt,
      ),
    );

    meal = container.read(mealsProvider).value!.single;
    expect(meal.grams, 200);
    expect(meal.macros.kcal, 200);
    expect(meal.macros.carbs, 100);
    expect(meal.macros.protein, 20);
    expect(meal.macros.fat, 10);
  });

  test('delete removes the meal', () async {
    final food = await insertFood(kcal: 100, carbs: 50, protein: 10, fat: 5);

    final notifier = container.read(mealsProvider.notifier);

    await notifier.add(
      food: food,
      grams: 100,
      consumedAt: DateTime(2026, 10, 20, 12),
    );
    final meal = container.read(mealsProvider).value!.single;

    await notifier.delete(meal.id!);

    expect(container.read(mealsProvider).value, isEmpty);
  });
}
