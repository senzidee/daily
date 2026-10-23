import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/daily_summary.dart';
import '../domain/macros.dart';
import '../domain/nutrition_goal.dart';
import '../providers/daily_summary_provider.dart';
import '../providers/goal_providers.dart';
import 'format.dart';
import 'theme/app_palette.dart';
import 'theme/app_spacing.dart';
import 'widgets/app_card.dart';
import 'widgets/app_section_label.dart';

class SummaryTab extends ConsumerWidget {
  const SummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailySummaryProvider);

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (summary) => ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          _GoalCard(goal: summary.goal, consumed: summary.consumedMacros),
          const SizedBox(height: AppSpacing.lg),
          const AppSectionLabel('Metrics'),
          const SizedBox(height: AppSpacing.xs),
          if (summary.metricAggregates.isEmpty)
            const _Note('No metrics yet')
          else
            _MetricAggregates(aggregates: summary.metricAggregates),
          const SizedBox(height: AppSpacing.lg),
          const AppSectionLabel('Meals'),
          const SizedBox(height: AppSpacing.xs),
          _MacrosCard(macros: summary.consumedMacros),
        ],
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal, required this.consumed});

  final NutritionGoal? goal;
  final Macros consumed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = this.goal;
    final palette = AppPalette.of(context);
    final gradient = palette.cardGradients.first;

    if (goal == null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Goal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'No nutrition goal set',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: () => _showGoalEditor(context, null),
              child: const Text('Set goal'),
            ),
          ],
        ),
      );
    }

    final targets = goal.gramTargets;
    final ratio = goal.kcalTarget <= 0
        ? 0.0
        : (consumed.kcal / goal.kcalTarget).clamp(0.0, 1.0);

    return AppCard(
      gradient: gradient,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Goal',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _showGoalEditor(context, goal),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Edit goal'),
                          ),
                        ],
                      ),
                      Text(
                        '${formatValue(goal.kcalTarget)} kcal target',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _remainingLabel(consumed.kcal, goal.kcalTarget),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _GoalRing(ratio: ratio),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _GoalBar(
              label: 'Carbs',
              consumed: consumed.carbs,
              target: targets.carbs,
              color: palette.carbs,
            ),
            const SizedBox(height: AppSpacing.sm),
            _GoalBar(
              label: 'Protein',
              consumed: consumed.protein,
              target: targets.protein,
              color: palette.protein,
            ),
            const SizedBox(height: AppSpacing.sm),
            _GoalBar(
              label: 'Fat',
              consumed: consumed.fat,
              target: targets.fat,
              color: palette.fat,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: CircularProgressIndicator(
              value: ratio,
              strokeWidth: 7,
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
          ),
          Text(
            '${(ratio * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalBar extends StatelessWidget {
  const _GoalBar({
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
  });

  final String label;
  final double consumed;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = target <= 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _macroRemainingLabel(label, consumed, target),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: Colors.white24,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MetricAggregates extends StatelessWidget {
  const _MetricAggregates({required this.aggregates});

  final List<MetricAggregate> aggregates;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);

    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < aggregates.length; i++) ...[
            if (i > 0) const Divider(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: palette
                        .cardGradients[i % palette.cardGradients.length]
                        .first,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${aggregates[i].metric.name}: '
                        '${formatValue(aggregates[i].value)} '
                        '${aggregates[i].metric.unit}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        aggregates[i].metric.aggregationMode.name,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MacrosCard extends StatelessWidget {
  const _MacrosCard({required this.macros});

  final Macros macros;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatValue(macros.kcal)} kcal',
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MacroStat(
                  label: 'Carbs',
                  grams: macros.carbs,
                  color: palette.carbs,
                  mutedColor: scheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: _MacroStat(
                  label: 'Protein',
                  grams: macros.protein,
                  color: palette.protein,
                  mutedColor: scheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: _MacroStat(
                  label: 'Fat',
                  grams: macros.fat,
                  color: palette.fat,
                  mutedColor: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat({
    required this.label,
    required this.grams,
    required this.color,
    required this.mutedColor,
  });

  final String label;
  final double grams;
  final Color color;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: mutedColor),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '${formatValue(grams)} g',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
      text: initial == null ? '' : formatValue(initial.kcalTarget),
    );
    _carbsController = TextEditingController(
      text: initial == null ? '' : formatValue(initial.carbPercent),
    );
    _proteinController = TextEditingController(
      text: initial == null ? '' : formatValue(initial.proteinPercent),
    );
    _fatController = TextEditingController(
      text: initial == null ? '' : formatValue(initial.fatPercent),
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
      await ref
          .read(nutritionGoalProvider.notifier)
          .save(
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Kcal target'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _carbsController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Carbs %'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _proteinController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Protein %'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _fatController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Fat %'),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
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

String _remainingLabel(double consumed, double target) {
  final diff = target - consumed;
  final consumedText =
      '${formatValue(consumed)} of ${formatValue(target)} kcal consumed';
  if (diff >= 0) {
    return '$consumedText — ${formatValue(diff)} kcal remaining';
  }
  return '$consumedText — ${formatValue(-diff)} kcal over';
}

String _macroRemainingLabel(String name, double consumed, double target) {
  final diff = target - consumed;
  final label = '$name ${formatValue(consumed)} of ${formatValue(target)} g';
  if (diff >= 0) {
    return '$label — ${formatValue(diff)} g remaining';
  }
  return '$label — ${formatValue(-diff)} g over';
}
