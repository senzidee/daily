import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDayProvider =
    NotifierProvider<SelectedDayNotifier, DateTime>(SelectedDayNotifier.new);

class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => _today();

  void goToPreviousDay() {
    state = _dateOnly(state.subtract(const Duration(days: 1)));
  }

  void goToNextDay() {
    state = _dateOnly(state.add(const Duration(days: 1)));
  }

  void goToToday() {
    state = _today();
  }

  void setDay(DateTime day) {
    state = _dateOnly(day);
  }

  static DateTime _today() => _dateOnly(DateTime.now());

  static DateTime _dateOnly(DateTime day) => DateTime(day.year, day.month, day.day);
}
