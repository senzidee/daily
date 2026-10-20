import 'package:drift/drift.dart';

import '../../domain/nutrition_goal.dart';
import '../app_database.dart';

abstract class NutritionGoalRepository {
  Future<NutritionGoal?> get();
  Future<void> save(NutritionGoal goal);
}

class DriftNutritionGoalRepository implements NutritionGoalRepository {
  DriftNutritionGoalRepository(this._db);

  final AppDatabase _db;

  @override
  Future<NutritionGoal?> get() async {
    final row = await _db.getGoal();
    if (row == null) {
      return null;
    }
    return NutritionGoal(
      id: row.id,
      kcalTarget: row.kcalTarget,
      carbPercent: row.carbPercent,
      proteinPercent: row.proteinPercent,
      fatPercent: row.fatPercent,
    );
  }

  @override
  Future<void> save(NutritionGoal goal) {
    return _db.upsertGoal(
      NutritionGoalsCompanion(
        kcalTarget: Value(goal.kcalTarget),
        carbPercent: Value(goal.carbPercent),
        proteinPercent: Value(goal.proteinPercent),
        fatPercent: Value(goal.fatPercent),
      ),
    );
  }
}
