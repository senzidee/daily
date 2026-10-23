import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/selected_day_provider.dart';
import 'diary_tab.dart';
import 'meals_tab.dart';
import 'metrics_tab.dart';
import 'settings_page.dart';
import 'summary_tab.dart';
import 'theme/app_spacing.dart';
import 'widgets/app_floating_nav.dart';
import 'widgets/app_radial_background.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  /// Key for the selected-day title, used by widget tests.
  static const dayTitleKey = Key('day-title');

  /// Key for the settings button, used by widget tests.
  static const settingsButtonKey = Key('settings-button');

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
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
        toolbarHeight: 76,
        titleSpacing: AppSpacing.md,
        leadingWidth: 56,
        leading: _ToolbarAction(
          icon: Icons.chevron_left,
          tooltip: 'Previous day',
          onPressed: notifier.goToPreviousDay,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _weekdays[selectedDay.weekday - 1],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDay(selectedDay),
              key: HomeShell.dayTitleKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          _ToolbarAction(
            icon: Icons.today,
            tooltip: 'Today',
            onPressed: notifier.goToToday,
          ),
          _ToolbarAction(
            icon: Icons.chevron_right,
            tooltip: 'Next day',
            onPressed: notifier.goToNextDay,
          ),
          _ToolbarAction(
            icon: Icons.calendar_today,
            tooltip: 'Pick date',
            onPressed: () => _pickDate(context, selectedDay, notifier),
          ),
          _ToolbarAction(
            key: HomeShell.settingsButtonKey,
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onPressed: () => _openSettings(context),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: const AppRadialBackground(child: _TabbedBody()),
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

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  static String _formatDay(DateTime day) {
    final monthDay = '${_months[day.month - 1]} ${day.day}';
    // The year only earns its width when it isn't the current one.
    return day.year == DateTime.now().year
        ? monthDay
        : '$monthDay, ${day.year}';
  }
}

class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
      ),
    );
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

  static const _destinations = <AppNavDestination>[
    AppNavDestination(
      icon: Icons.book_outlined,
      selectedIcon: Icons.book,
      label: 'Diary',
    ),
    AppNavDestination(
      icon: Icons.straighten_outlined,
      selectedIcon: Icons.straighten,
      label: 'Metrics',
    ),
    AppNavDestination(
      icon: Icons.restaurant_outlined,
      selectedIcon: Icons.restaurant,
      label: 'Meals',
    ),
    AppNavDestination(
      icon: Icons.pie_chart_outline,
      selectedIcon: Icons.pie_chart,
      label: 'Summary',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IndexedStack(index: _index, children: _tabs),
        ),
        AppFloatingNav(
          index: _index,
          onChanged: (index) => setState(() => _index = index),
          destinations: _destinations,
        ),
      ],
    );
  }
}
