import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylog/data/app_database.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/ui/metrics_tab.dart';

Widget _buildApp(AppDatabase db) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: const MaterialApp(home: Scaffold(body: MetricsTab())),
  );
}

void main() {
  testWidgets('add a metric via UI and see it listed', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_buildApp(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add metric'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'steps');
    await tester.enterText(find.widgetWithText(TextField, 'Unit'), 'count');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('steps'), findsOneWidget);
    expect(find.text('count · last'), findsOneWidget);
  });

  testWidgets('add a measurement under a metric and see it appear',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_buildApp(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('weight'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '72.5');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('72.5 kg'), findsWidgets);
  });
}
