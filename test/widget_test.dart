import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylog/data/app_database.dart';
import 'package:daylog/main.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/ui/home_shell.dart';
import 'package:daylog/ui/widgets/app_floating_nav.dart';

void main() {
  testWidgets('shell builds and next-day control changes the selected day', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppFloatingNav), findsOneWidget);

    final dayTitle = find.byKey(HomeShell.dayTitleKey);
    final before = tester.widget<Text>(dayTitle).data;

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();

    final after = tester.widget<Text>(dayTitle).data;
    expect(after, isNot(before));
  });
}
