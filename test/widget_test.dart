import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylog/main.dart';

void main() {
  testWidgets('shell builds and next-day control changes the selected day',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.byType(NavigationBar), findsOneWidget);

    final appBarTitle = find.descendant(
      of: find.byType(AppBar),
      matching: find.byType(Text),
    );
    final before = tester.widget<Text>(appBarTitle).data;

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();

    final after = tester.widget<Text>(appBarTitle).data;
    expect(after, isNot(before));
  });
}
