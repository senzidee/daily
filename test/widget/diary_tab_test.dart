import 'package:daylog/data/app_database.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/ui/diary_tab.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('adding an entry shows it in the list; delete removes it',
      (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: Scaffold(body: DiaryTab()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No entries for this day'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'My first note');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('My first note'), findsOneWidget);
    expect(find.text('No entries for this day'), findsNothing);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('My first note'), findsNothing);
    expect(find.text('No entries for this day'), findsOneWidget);
  });

  testWidgets('saving an empty entry is rejected', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: Scaffold(body: DiaryTab()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Text is required'), findsOneWidget);
  });
}
