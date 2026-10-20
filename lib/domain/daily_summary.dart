import 'aggregation_mode.dart';
import 'measurement.dart';

double? aggregateMetric(AggregationMode mode, List<Measurement> measurements) {
  if (measurements.isEmpty) return null;

  switch (mode) {
    case AggregationMode.last:
      final latest = measurements.reduce(
        (a, b) => a.recordedAt.isAfter(b.recordedAt) ? a : b,
      );
      return latest.value;
    case AggregationMode.sum:
      return measurements.fold<double>(0.0, (total, m) => total + m.value);
    case AggregationMode.avg:
      final total =
          measurements.fold<double>(0.0, (sum, m) => sum + m.value);
      return total / measurements.length;
  }
}
