import 'package:daylog/data/app_database.dart';
import 'package:daylog/domain/aggregation_mode.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/ui/summary_tab.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildApp(AppDatabase db) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: const MaterialApp(home: Scaffold(body: SummaryTab())),
  );
}

void main() {
  testWidgets('set a goal via the UI and see it in the summary',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_buildApp(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set goal'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Kcal target'), '2000');
    await tester.enterText(find.widgetWithText(TextField, 'Carbs %'), '40');
    await tester.enterText(find.widgetWithText(TextField, 'Protein %'), '40');
    await tester.enterText(find.widgetWithText(TextField, 'Fat %'), '20');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('2000 kcal target'), findsOneWidget);
    expect(find.text('Edit goal'), findsOneWidget);
    expect(find.text('Carbs 0 of 200 g — 200 g remaining'), findsOneWidget);
  });

  testWidgets('shows aggregates and macros for a seeded day', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final stepsId = await db.insertMetric(
      MetricsCompanion.insert(
        name: 'steps',
        unit: 'count',
        aggregationMode: AggregationMode.sum,
      ),
    );
    await db.insertMeasurement(
      metricId: stepsId,
      value: 5000,
      recordedAt: DateTime.now(),
    );

    final foodId = await db.upsertFood(
      FoodsCompanion.insert(
        name: 'test food',
        kcal: 400,
        carbs: 40,
        protein: 30,
        fat: 10,
      ),
    );
    await db.insertMeal(
      foodId: foodId,
      grams: 250,
      kcal: 1000,
      carbs: 100,
      protein: 75,
      fat: 25,
      consumedAt: DateTime.now(),
    );

    await db.upsertGoal(
      NutritionGoalsCompanion.insert(
        kcalTarget: 2000,
        carbPercent: 40,
        proteinPercent: 40,
        fatPercent: 20,
      ),
    );

    await tester.pumpWidget(_buildApp(db));
    await tester.pumpAndSettle();

    expect(find.text('steps: 5000 count'), findsOneWidget);
    expect(find.text('1000 kcal'), findsOneWidget);
    expect(find.text('2000 kcal target'), findsOneWidget);
  });
}
