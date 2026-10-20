import 'package:daylog/domain/aggregation_mode.dart';
import 'package:daylog/domain/daily_summary.dart';
import 'package:daylog/domain/measurement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final measurements = [
    Measurement(
      metricId: 1,
      value: 30,
      recordedAt: DateTime(2026, 10, 20, 7),
    ),
    Measurement(
      metricId: 1,
      value: 10,
      recordedAt: DateTime(2026, 10, 20, 8),
    ),
    Measurement(
      metricId: 1,
      value: 20,
      recordedAt: DateTime(2026, 10, 20, 9),
    ),
  ];

  test('aggregateMetric last returns the latest value', () {
    expect(aggregateMetric(AggregationMode.last, measurements), 20.0);
  });

  test('aggregateMetric sum returns the total', () {
    expect(aggregateMetric(AggregationMode.sum, measurements), 60.0);
  });

  test('aggregateMetric avg returns the average', () {
    expect(aggregateMetric(AggregationMode.avg, measurements), 20.0);
  });

  test('aggregateMetric returns null for an empty list', () {
    expect(aggregateMetric(AggregationMode.sum, const []), isNull);
  });
}
