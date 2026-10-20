import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/selected_day_provider.dart';
import 'diary_tab.dart';
import 'meals_tab.dart';
import 'metrics_tab.dart';
import 'summary_tab.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final notifier = ref.read(selectedDayProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatDay(selectedDay)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous day',
          onPressed: notifier.goToPreviousDay,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Today',
            onPressed: notifier.goToToday,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next day',
            onPressed: notifier.goToNextDay,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Pick date',
            onPressed: () => _pickDate(context, selectedDay, notifier),
          ),
        ],
      ),
      body: const _TabbedBody(),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    DateTime selectedDay,
    SelectedDayNotifier notifier,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      notifier.setDay(picked);
    }
  }

  static String _formatDay(DateTime day) {
    return '${_weekdays[day.weekday - 1]}, '
        '${_months[day.month - 1]} ${day.day}, ${day.year}';
  }
}

class _TabbedBody extends StatefulWidget {
  const _TabbedBody();

  @override
  State<_TabbedBody> createState() => _TabbedBodyState();
}

class _TabbedBodyState extends State<_TabbedBody> {
  int _index = 0;

  static const _tabs = <Widget>[
    DiaryTab(),
    MetricsTab(),
    MealsTab(),
    SummaryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Diary',
          ),
          NavigationDestination(
            icon: Icon(Icons.straighten_outlined),
            selectedIcon: Icon(Icons.straighten),
            label: 'Metrics',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}
