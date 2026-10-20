import 'package:daylog/data/app_database.dart';
import 'package:daylog/domain/nutrition_goal.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/providers/goal_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

NutritionGoal _goal(double kcal) => NutritionGoal(
      kcalTarget: kcal,
      carbPercent: 40,
      proteinPercent: 40,
      fatPercent: 20,
    );

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

  test('defaults to null when no goal has been saved', () async {
    expect(await container.read(nutritionGoalProvider.future), isNull);
  });

  test('save then get returns the goal', () async {
    await container.read(nutritionGoalProvider.notifier).save(_goal(2000));

    final goal = await container.read(nutritionGoalProvider.future);
    expect(goal!.kcalTarget, 2000);
    expect(goal.carbPercent, 40);
    expect(goal.proteinPercent, 40);
    expect(goal.fatPercent, 20);
  });

  test('saving again replaces the single row', () async {
    final notifier = container.read(nutritionGoalProvider.notifier);
    await notifier.save(_goal(2000));
    await notifier.save(_goal(2500));

    final repo = container.read(nutritionGoalRepositoryProvider);
    final latest = await repo.get();
    expect(latest!.kcalTarget, 2500);

    final rows = await db.select(db.nutritionGoals).get();
    expect(rows.length, 1);
  });
}
