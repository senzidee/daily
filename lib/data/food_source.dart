import '../domain/food.dart';
import '../domain/macros.dart';

abstract class FoodSource {
  Future<List<Food>> search(String query);
}

class FakeFoodSource implements FoodSource {
  static const List<Food> _catalog = [
    Food(name: 'apple', per100g: Macros(kcal: 52, carbs: 14, protein: 0.3, fat: 0.2)),
    Food(name: 'banana', per100g: Macros(kcal: 89, carbs: 23, protein: 1.1, fat: 0.3)),
    Food(name: 'chicken breast', per100g: Macros(kcal: 165, carbs: 0, protein: 31, fat: 3.6)),
    Food(name: 'egg', per100g: Macros(kcal: 155, carbs: 1.1, protein: 13, fat: 11)),
    Food(name: 'white rice', per100g: Macros(kcal: 130, carbs: 28, protein: 2.7, fat: 0.3)),
    Food(name: 'rolled oats', per100g: Macros(kcal: 389, carbs: 66, protein: 17, fat: 7)),
    Food(name: 'whole milk', per100g: Macros(kcal: 61, carbs: 4.8, protein: 3.2, fat: 3.3)),
    Food(name: 'beef (lean)', per100g: Macros(kcal: 250, carbs: 0, protein: 26, fat: 15)),
    Food(name: 'salmon', per100g: Macros(kcal: 208, carbs: 0, protein: 20, fat: 13)),
    Food(name: 'broccoli', per100g: Macros(kcal: 34, carbs: 7, protein: 2.8, fat: 0.4)),
    Food(name: 'olive oil', per100g: Macros(kcal: 884, carbs: 0, protein: 0, fat: 100)),
    Food(name: 'white bread', per100g: Macros(kcal: 265, carbs: 49, protein: 9, fat: 3.2)),
    Food(name: 'pasta (dry)', per100g: Macros(kcal: 371, carbs: 75, protein: 13, fat: 1.5)),
    Food(name: 'greek yogurt', per100g: Macros(kcal: 59, carbs: 3.6, protein: 10, fat: 0.4)),
    Food(name: 'almonds', per100g: Macros(kcal: 579, carbs: 22, protein: 21, fat: 50)),
    Food(name: 'avocado', per100g: Macros(kcal: 160, carbs: 8.5, protein: 2, fat: 15)),
    Food(name: 'potato', per100g: Macros(kcal: 77, carbs: 17, protein: 2, fat: 0.1)),
    Food(name: 'lentils', per100g: Macros(kcal: 116, carbs: 20, protein: 9, fat: 0.4)),
  ];

  @override
  Future<List<Food>> search(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }
    final results = _catalog
        .where((food) => food.name.toLowerCase().contains(normalized))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return results;
  }
}
