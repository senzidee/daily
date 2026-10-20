import 'aggregation_mode.dart';

class Metric {
  const Metric({
    required this.name,
    required this.unit,
    required this.aggregationMode,
    this.id,
  });

  final int? id;
  final String name;
  final String unit;
  final AggregationMode aggregationMode;
}
