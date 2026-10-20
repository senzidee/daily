import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylog/data/app_database.dart';
import 'package:daylog/domain/aggregation_mode.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/providers/metric_providers.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    final db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
    ]);
    addTearDown(container.dispose);
    addTearDown(db.close);
  });

  test('weight metric is seeded on first metricsProvider read', () async {
    final metrics = await container.read(metricsProvider.future);

    expect(metrics, hasLength(1));
    expect(metrics.first.name, 'weight');
    expect(metrics.first.unit, 'kg');
    expect(metrics.first.aggregationMode, AggregationMode.last);
  });

  test('addMetric adds a metric and it appears', () async {
    await container.read(metricsProvider.future);

    await container
        .read(metricsProvider.notifier)
        .addMetric('steps', 'count', AggregationMode.sum);

    final metrics = container.read(metricsProvider).requireValue;
    expect(metrics, hasLength(2));
    final steps = metrics.firstWhere((m) => m.name == 'steps');
    expect(steps.unit, 'count');
    expect(steps.aggregationMode, AggregationMode.sum);
  });

  test('addMeasurement adds and appears in measurementsProvider', () async {
    await container.read(metricsProvider.future);
    final weightId = container.read(metricsProvider).requireValue.first.id!;

    await container
        .read(measurementsProvider.notifier)
        .addMeasurement(weightId, 72.5, DateTime(2024, 1, 1, 8));

    final measurements = container.read(measurementsProvider).requireValue;
    expect(measurements, hasLength(1));
    expect(measurements.first.metricId, weightId);
    expect(measurements.first.value, 72.5);
    expect(measurements.first.recordedAt, DateTime(2024, 1, 1, 8));
  });
}
