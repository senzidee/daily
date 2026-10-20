import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/aggregation_mode.dart';
import '../domain/daily_summary.dart';
import '../domain/day.dart';
import '../domain/measurement.dart';
import '../domain/metric.dart';
import '../providers/metric_providers.dart';
import '../providers/selected_day_provider.dart';

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
        final measurements =
            measurementsAsync.value ?? const <Measurement>[];

        return Scaffold(
          body: metrics.isEmpty
              ? const Center(child: Text('No metrics yet'))
              : ListView(
                  children: [
                    for (final metric in metrics)
                      _MetricTile(
                        metric: metric,
                        day: day,
                        measurements: measurements,
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
  });

  final Metric metric;
  final DateTime day;
  final List<Measurement> measurements;

  @override
  Widget build(BuildContext context) {
    final dayMeasurements = measurements
        .where((m) => m.metricId == metric.id && isSameDay(m.recordedAt, day))
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final aggregate = aggregateMetric(metric.aggregationMode, dayMeasurements);

    return ExpansionTile(
      key: ValueKey(metric.id),
      title: Text(metric.name),
      subtitle: Text('${metric.unit} · ${metric.aggregationMode.name}'),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: aggregate == null
              ? const Text('No measurements for this day')
              : Text(
                  '${metric.aggregationMode.name}: '
                  '${_formatValue(aggregate)} ${metric.unit}',
                ),
        ),
        for (final m in dayMeasurements)
          ListTile(
            dense: true,
            title: Text('${_formatValue(m.value)} ${metric.unit}'),
            subtitle: Text(_formatTime(m.recordedAt)),
          ),
        _AddMeasurementForm(metricId: metric.id!, day: day),
      ],
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
          TextField(
            controller: _unitController,
            decoration: const InputDecoration(labelText: 'Unit'),
          ),
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
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
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
        ? DateTime.now()
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _valueController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Value',
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.access_time),
            tooltip: 'Pick time',
            onPressed: _pickTime,
          ),
          FilledButton(
            onPressed: _submit,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

String _formatValue(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

String _formatTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
