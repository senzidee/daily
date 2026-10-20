import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/day.dart';

final selectedDayProvider =
    NotifierProvider<SelectedDayNotifier, DateTime>(SelectedDayNotifier.new);

class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => _today();

  void goToPreviousDay() {
    state = dateOnly(state.subtract(const Duration(days: 1)));
  }

  void goToNextDay() {
    state = dateOnly(state.add(const Duration(days: 1)));
  }

  void goToToday() {
    state = _today();
  }

  void setDay(DateTime day) {
    state = dateOnly(day);
  }

  static DateTime _today() => dateOnly(DateTime.now());
}
