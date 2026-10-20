import 'package:flutter_test/flutter_test.dart';

import 'package:daylog/domain/day.dart';

void main() {
  test('dateOnly strips time', () {
    final d = DateTime(2026, 10, 20, 15, 30);
    expect(dateOnly(d), DateTime(2026, 10, 20));
  });

  test('isSameDay matches on date only', () {
    expect(isSameDay(DateTime(2026, 10, 20, 1), DateTime(2026, 10, 20, 23)), isTrue);
    expect(isSameDay(DateTime(2026, 10, 20), DateTime(2026, 10, 21)), isFalse);
  });
}
