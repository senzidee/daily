import '../../domain/food.dart';
import '../../domain/macros.dart';
import '../app_database.dart';
import '../food_source.dart';

abstract class FoodRepository {
  Future<List<Food>> search(String query);

  Future<Food?> findById(int id);
}

class DriftFoodRepository implements FoodRepository {
  DriftFoodRepository(this._db, this._source);

  final AppDatabase _db;
  final FoodSource _source;

  @override
  Future<List<Food>> search(String query) async {
    final results = await _source.search(query);
    final foods = <Food>[];
    for (final food in results) {
      await _db.upsertFood(
        FoodsCompanion.insert(
          name: food.name,
          kcal: food.per100g.kcal,
          carbs: food.per100g.carbs,
          protein: food.per100g.protein,
          fat: food.per100g.fat,
        ),
      );
      final row = await _db.foodByName(food.name);
      foods.add(Food(id: row!.id, name: food.name, per100g: food.per100g));
    }
    return foods;
  }

  @override
  Future<Food?> findById(int id) async {
    final row = await _db.foodById(id);
    if (row == null) {
      return null;
    }
    return Food(
      id: row.id,
      name: row.name,
      per100g: Macros(
        kcal: row.kcal,
        carbs: row.carbs,
        protein: row.protein,
        fat: row.fat,
      ),
    );
  }
}
