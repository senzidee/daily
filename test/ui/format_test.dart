import 'package:daylog/ui/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatTime pads to two digits', () {
    expect(formatTime(DateTime(2026, 10, 20, 9, 5)), '09:05');
    expect(formatTime(DateTime(2026, 10, 20, 23, 59)), '23:59');
  });

  test('formatValue uses one decimal and drops trailing .0', () {
    expect(formatValue(72.5), '72.5');
    expect(formatValue(5000.0), '5000');
    expect(formatValue(44.44), '44.4');
  });

  test('formatDate renders ISO date', () {
    expect(formatDate(DateTime(2026, 10, 20)), '2026-10-20');
  });
}
