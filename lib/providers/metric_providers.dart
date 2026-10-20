import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/measurement_repository.dart';
import '../data/repositories/metric_repository.dart';
import '../domain/aggregation_mode.dart';
import '../domain/measurement.dart';
import '../domain/metric.dart';
import 'database_provider.dart';

final metricRepositoryProvider = Provider<MetricRepository>(
  (ref) => DriftMetricRepository(ref.watch(databaseProvider)),
);

final measurementRepositoryProvider = Provider<MeasurementRepository>(
  (ref) => DriftMeasurementRepository(ref.watch(databaseProvider)),
);

class MetricsNotifier extends AsyncNotifier<List<Metric>> {
  @override
  Future<List<Metric>> build() async {
    return ref.read(metricRepositoryProvider).getAll();
  }

  Future<void> addMetric(String name, String unit, AggregationMode mode) async {
    await ref.read(metricRepositoryProvider).add(name, unit, mode);
    state = AsyncData(await ref.read(metricRepositoryProvider).getAll());
  }
}

final metricsProvider =
    AsyncNotifierProvider<MetricsNotifier, List<Metric>>(MetricsNotifier.new);

class MeasurementsNotifier extends AsyncNotifier<List<Measurement>> {
  @override
  Future<List<Measurement>> build() =>
      ref.read(measurementRepositoryProvider).getAll();

  Future<void> addMeasurement(
      int metricId, double value, DateTime recordedAt) async {
    await ref
        .read(measurementRepositoryProvider)
        .add(metricId, value, recordedAt);
    state = AsyncData(await ref.read(measurementRepositoryProvider).getAll());
  }
}

final measurementsProvider =
    AsyncNotifierProvider<MeasurementsNotifier, List<Measurement>>(
        MeasurementsNotifier.new);
