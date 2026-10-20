import 'package:drift/drift.dart';

import '../../domain/aggregation_mode.dart';
import '../../domain/metric.dart';
import '../app_database.dart';

abstract class MetricRepository {
  Future<List<Metric>> getAll();
  Stream<List<Metric>> watchAll();
  Future<Metric> add(String name, String unit, AggregationMode mode);
}

class DriftMetricRepository implements MetricRepository {
  DriftMetricRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Metric>> getAll() async {
    await _db.seedWeightIfEmpty();
    final rows = await (_db.select(_db.metrics)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return rows.map(_toMetric).toList();
  }

  @override
  Stream<List<Metric>> watchAll() async* {
    await _db.seedWeightIfEmpty();
    yield* (_db.select(_db.metrics)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .watch()
        .map((rows) => rows.map(_toMetric).toList());
  }

  @override
  Future<Metric> add(String name, String unit, AggregationMode mode) async {
    final id = await _db.into(_db.metrics).insert(
      MetricsCompanion.insert(name: name, unit: unit, aggregationMode: mode),
    );
    return Metric(id: id, name: name, unit: unit, aggregationMode: mode);
  }

  Metric _toMetric(MetricRow row) => Metric(
        id: row.id,
        name: row.name,
        unit: row.unit,
        aggregationMode: row.aggregationMode,
      );
}
