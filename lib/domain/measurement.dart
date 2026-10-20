class Measurement {
  const Measurement({
    required this.metricId,
    required this.value,
    required this.recordedAt,
    this.id,
  });

  final int? id;
  final int metricId;
  final double value;
  final DateTime recordedAt;
}
