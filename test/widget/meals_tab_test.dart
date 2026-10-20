import 'package:daylog/data/app_database.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/ui/meals_tab.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpMealsTab(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: Scaffold(body: MealsTab())),
      ),
    );
  }

  Future<void> logFood(WidgetTester tester, String name, String grams) async {
    await tester.enterText(find.byType(TextField), name);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, name));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Grams'), grams);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('searching and logging a food shows the meal for the day',
      (WidgetTester tester) async {
    await pumpMealsTab(tester);

    await logFood(tester, 'banana', '150');

    expect(find.textContaining('150 g'), findsOneWidget);
  });

  testWidgets('swiping a meal deletes it from the day list',
      (WidgetTester tester) async {
    await pumpMealsTab(tester);

    await logFood(tester, 'banana', '150');

    expect(find.textContaining('150 g'), findsOneWidget);

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.textContaining('150 g'), findsNothing);
  });
}
