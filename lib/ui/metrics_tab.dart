import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/aggregation_mode.dart';
import '../domain/daily_summary.dart';
import '../domain/day.dart';
import '../domain/measurement.dart';
import '../domain/metric.dart';
import '../providers/metric_providers.dart';
import '../providers/selected_day_provider.dart';
import 'format.dart';
import 'theme/app_palette.dart';
import 'theme/app_spacing.dart';
import 'widgets/app_card.dart';
import 'widgets/app_empty_state.dart';
import 'widgets/app_section_label.dart';

class MetricsTab extends ConsumerWidget {
  const MetricsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(metricsProvider);
    final measurementsAsync = ref.watch(measurementsProvider);
    final day = ref.watch(selectedDayProvider);

    return metricsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (metrics) {
        final measurements = measurementsAsync.value ?? const <Measurement>[];
        final palette = AppPalette.of(context);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: metrics.isEmpty
              ? const AppEmptyState(
                  icon: Icons.straighten_outlined,
                  message: 'No metrics yet',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.xxxl * 2,
                  ),
                  children: [
                    const AppSectionLabel('Metrics'),
                    const SizedBox(height: AppSpacing.xs),
                    for (var i = 0; i < metrics.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _MetricTile(
                          metric: metrics[i],
                          day: day,
                          measurements: measurements,
                          accent: palette
                              .cardGradients[i % palette.cardGradients.length]
                              .first,
                        ),
                      ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddMetricDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add metric'),
          ),
        );
      },
    );
  }

  Future<void> _showAddMetricDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const _AddMetricDialog(),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.metric,
    required this.day,
    required this.measurements,
    required this.accent,
  });

  final Metric metric;
  final DateTime day;
  final List<Measurement> measurements;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final dayMeasurements =
        measurements
            .where(
              (m) => m.metricId == metric.id && isSameDay(m.recordedAt, day),
            )
            .toList()
          ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final aggregate = aggregateMetric(dayMeasurements, metric.aggregationMode);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: Theme.of(context).expansionTileTheme.copyWith(
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xxs,
            ),
          ),
        ),
        child: ExpansionTile(
          key: ValueKey(metric.id),
          title: Text(metric.name, style: textTheme.titleMedium),
          subtitle: Text('${metric.unit} · ${metric.aggregationMode.name}'),
          leading: Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${metric.aggregationMode.name}: '
                '${formatValue(aggregate)} ${metric.unit}',
                style: textTheme.titleMedium?.copyWith(color: accent),
              ),
            ),
            if (dayMeasurements.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No measurements for this day',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              for (final m in dayMeasurements)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Row(
                    children: [
                      Text(
                        formatTime(m.recordedAt),
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${formatValue(m.value)} ${metric.unit}',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
            _AddMeasurementForm(metricId: metric.id!, day: day),
          ],
        ),
      ),
    );
  }
}

class _AddMetricDialog extends ConsumerStatefulWidget {
  const _AddMetricDialog();

  @override
  ConsumerState<_AddMetricDialog> createState() => _AddMetricDialogState();
}

class _AddMetricDialogState extends ConsumerState<_AddMetricDialog> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  AggregationMode _mode = AggregationMode.last;

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final unit = _unitController.text.trim();
    if (name.isEmpty || unit.isEmpty) return;

    await ref.read(metricsProvider.notifier).addMetric(name, unit, _mode);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add metric'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _unitController,
            decoration: const InputDecoration(labelText: 'Unit'),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<AggregationMode>(
            initialValue: _mode,
            decoration: const InputDecoration(labelText: 'Aggregation'),
            items: [
              for (final mode in AggregationMode.values)
                DropdownMenuItem(value: mode, child: Text(mode.name)),
            ],
            onChanged: (mode) {
              if (mode != null) {
                setState(() => _mode = mode);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}

class _AddMeasurementForm extends ConsumerStatefulWidget {
  const _AddMeasurementForm({required this.metricId, required this.day});

  final int metricId;
  final DateTime day;

  @override
  ConsumerState<_AddMeasurementForm> createState() =>
      _AddMeasurementFormState();
}

class _AddMeasurementFormState extends ConsumerState<_AddMeasurementForm> {
  final _valueController = TextEditingController();
  TimeOfDay? _time;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _submit() async {
    final value = double.tryParse(_valueController.text.trim());
    if (value == null) return;

    final recordedAt = _time == null
        ? widget.day
        : DateTime(
            widget.day.year,
            widget.day.month,
            widget.day.day,
            _time!.hour,
            _time!.minute,
          );

    await ref
        .read(measurementsProvider.notifier)
        .addMeasurement(widget.metricId, value, recordedAt);

    if (mounted) {
      _valueController.clear();
      setState(() => _time = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Value',
                isDense: true,
                fillColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.access_time),
            tooltip: 'Pick time',
            onPressed: _pickTime,
          ),
          FilledButton(onPressed: _submit, child: const Text('Add')),
        ],
      ),
    );
  }
}
