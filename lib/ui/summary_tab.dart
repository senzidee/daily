import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/macros.dart';
import '../domain/nutrition_goal.dart';
import '../providers/daily_summary_provider.dart';
import '../providers/goal_providers.dart';

class SummaryTab extends ConsumerWidget {
  const SummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailySummaryProvider);

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (summary) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GoalCard(
            goal: summary.goal,
            consumedKcal: summary.consumedMacros.kcal,
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Metrics'),
          if (summary.metricAggregates.isEmpty)
            const _Note('No metrics yet')
          else
            Card(
              child: Column(
                children: [
                  for (final aggregate in summary.metricAggregates)
                    ListTile(
                      title: Text(
                        '${aggregate.metric.name}: '
                        '${_fmt(aggregate.value)} ${aggregate.metric.unit}',
                      ),
                      subtitle: Text(aggregate.metric.aggregationMode.name),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const _SectionHeader('Meals'),
          _MacrosCard(macros: summary.consumedMacros),
        ],
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal, required this.consumedKcal});

  final NutritionGoal? goal;
  final double consumedKcal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = this.goal;
    if (goal == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Goal', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('No nutrition goal set'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _showGoalEditor(context, null),
                child: const Text('Set goal'),
              ),
            ],
          ),
        ),
      );
    }

    final targets = goal.gramTargets;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Goal', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => _showGoalEditor(context, goal),
                  child: const Text('Edit goal'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${_fmt(goal.kcalTarget)} kcal target'),
            const SizedBox(height: 8),
            Text('Carbs ${_fmt(targets.carbs)} g'),
            Text('Protein ${_fmt(targets.protein)} g'),
            Text('Fat ${_fmt(targets.fat)} g'),
            const Divider(height: 24),
            Text(_remainingLabel(consumedKcal, goal.kcalTarget)),
          ],
        ),
      ),
    );
  }
}

class _MacrosCard extends StatelessWidget {
  const _MacrosCard({required this.macros});

  final Macros macros;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_fmt(macros.kcal)} kcal'),
            const SizedBox(height: 8),
            Text('Carbs ${_fmt(macros.carbs)} g'),
            Text('Protein ${_fmt(macros.protein)} g'),
            Text('Fat ${_fmt(macros.fat)} g'),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(message),
    );
  }
}

Future<void> _showGoalEditor(BuildContext context, NutritionGoal? goal) {
  return showDialog<void>(
    context: context,
    builder: (_) => _GoalEditorDialog(initial: goal),
  );
}

class _GoalEditorDialog extends ConsumerStatefulWidget {
  const _GoalEditorDialog({this.initial});

  final NutritionGoal? initial;

  @override
  ConsumerState<_GoalEditorDialog> createState() => _GoalEditorDialogState();
}

class _GoalEditorDialogState extends ConsumerState<_GoalEditorDialog> {
  late final TextEditingController _kcalController;
  late final TextEditingController _carbsController;
  late final TextEditingController _proteinController;
  late final TextEditingController _fatController;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _kcalController = TextEditingController(
      text: initial == null ? '' : _fmt(initial.kcalTarget),
    );
    _carbsController = TextEditingController(
      text: initial == null ? '' : _fmt(initial.carbPercent),
    );
    _proteinController = TextEditingController(
      text: initial == null ? '' : _fmt(initial.proteinPercent),
    );
    _fatController = TextEditingController(
      text: initial == null ? '' : _fmt(initial.fatPercent),
    );
  }

  @override
  void dispose() {
    _kcalController.dispose();
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  double? get _kcal => double.tryParse(_kcalController.text.trim());
  double? get _carbs => double.tryParse(_carbsController.text.trim());
  double? get _protein => double.tryParse(_proteinController.text.trim());
  double? get _fat => double.tryParse(_fatController.text.trim());

  bool get _percentsSumTo100 {
    final carbs = _carbs;
    final protein = _protein;
    final fat = _fat;
    if (carbs == null || protein == null || fat == null) return false;
    return ((carbs + protein + fat) - 100).abs() < 0.0001;
  }

  Future<void> _save() async {
    final kcal = _kcal;
    final carbs = _carbs;
    final protein = _protein;
    final fat = _fat;

    if (kcal == null || carbs == null || protein == null || fat == null) {
      setState(() => _error = 'All fields are required');
      return;
    }
    if (!_percentsSumTo100) {
      setState(() => _error = 'Percentages must add up to 100');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(nutritionGoalProvider.notifier).save(
            NutritionGoal(
              kcalTarget: kcal,
              carbPercent: carbs,
              proteinPercent: protein,
              fatPercent: fat,
            ),
          );
    } on ArgumentError catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = e.message?.toString() ?? 'Invalid goal';
        });
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Set goal' : 'Edit goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _kcalController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Kcal target'),
            ),
            TextField(
              controller: _carbsController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Carbs %'),
            ),
            TextField(
              controller: _proteinController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Protein %'),
            ),
            TextField(
              controller: _fatController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Fat %'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

String _fmt(double value) {
  final s = value.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

String _remainingLabel(double consumed, double target) {
  final diff = target - consumed;
  final consumedText = '${_fmt(consumed)} of ${_fmt(target)} kcal consumed';
  if (diff >= 0) {
    return '$consumedText — ${_fmt(diff)} kcal remaining';
  }
  return '$consumedText — ${_fmt(-diff)} kcal over';
}
