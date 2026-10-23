import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylog/data/app_database.dart';
import 'package:daylog/main.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/ui/home_shell.dart';
import 'package:daylog/ui/settings_page.dart';
import 'package:daylog/ui/widgets/app_floating_nav.dart';

Widget _app(AppDatabase db) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: const MyApp(),
  );
}

Finder _navItem(String label) => find.descendant(
      of: find.byType(AppFloatingNav),
      matching: find.text(label),
    );

void main() {
  testWidgets('gear opens Settings and back restores the tab and day', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_app(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();
    final dayBefore =
        tester.widget<Text>(find.byKey(HomeShell.dayTitleKey)).data;

    await tester.tap(_navItem('Metrics'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppFloatingNav>(find.byType(AppFloatingNav)).index,
      1,
    );

    await tester.tap(find.byKey(HomeShell.settingsButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(SettingsPage.titleKey), findsOneWidget);
    expect(find.byType(AppFloatingNav), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(AppFloatingNav), findsOneWidget);
    expect(
      tester.widget<AppFloatingNav>(find.byType(AppFloatingNav)).index,
      1,
    );
    expect(
      tester.widget<Text>(find.byKey(HomeShell.dayTitleKey)).data,
      dayBefore,
    );
  });

  testWidgets('the gear is available from every tab', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_app(db));
    await tester.pumpAndSettle();

    for (final label in ['Diary', 'Metrics', 'Meals', 'Summary']) {
      await tester.tap(_navItem(label));
      await tester.pumpAndSettle();
      expect(find.byKey(HomeShell.settingsButtonKey), findsOneWidget);
    }
  });

  testWidgets('day title keeps room for the date on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_app(db));
    await tester.pumpAndSettle();

    expect(find.byKey(HomeShell.settingsButtonKey), findsOneWidget);

    final titleFinder = find.byKey(HomeShell.dayTitleKey);
    final title = tester.widget<Text>(titleFinder);
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(title.data, isNot(contains(RegExp(r'\d{4}'))));

    final size = tester.getSize(titleFinder);
    expect(size.height, lessThan(30), reason: 'the title must stay one line');
    expect(
      size.width,
      greaterThanOrEqualTo(60),
      reason: 'the four actions must not squeeze the date out',
    );
  });
}
