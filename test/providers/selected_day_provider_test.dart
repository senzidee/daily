import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylog/providers/selected_day_provider.dart';

DateTime _dateOnly(DateTime day) => DateTime(day.year, day.month, day.day);

void main() {
  test('SelectedDayNotifier navigates previous, next, today, and setDay', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = container.read(selectedDayProvider);
    expect(initial, _dateOnly(DateTime.now()));

    container.read(selectedDayProvider.notifier).goToNextDay();
    expect(
      container.read(selectedDayProvider),
      DateTime(initial.year, initial.month, initial.day + 1),
    );

    container.read(selectedDayProvider.notifier).goToPreviousDay();
    container.read(selectedDayProvider.notifier).goToPreviousDay();
    expect(
      container.read(selectedDayProvider),
      DateTime(initial.year, initial.month, initial.day - 1),
    );

    container
        .read(selectedDayProvider.notifier)
        .setDay(DateTime(2024, 2, 29, 15, 30));
    expect(container.read(selectedDayProvider), DateTime(2024, 2, 29));

    container.read(selectedDayProvider.notifier).goToToday();
    expect(container.read(selectedDayProvider), _dateOnly(DateTime.now()));
  });
}
