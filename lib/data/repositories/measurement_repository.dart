import 'package:drift/drift.dart';

import '../../domain/measurement.dart';
import '../app_database.dart';

abstract class MeasurementRepository {
  Future<List<Measurement>> getAll();
  Stream<List<Measurement>> watchAll();
  Future<Measurement> add(int metricId, double value, DateTime recordedAt);
}

class DriftMeasurementRepository implements MeasurementRepository {
  DriftMeasurementRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Measurement>> getAll() async {
    final rows = await (_db.select(_db.measurements)
          ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
        .get();
    return rows.map(_toMeasurement).toList();
  }

  @override
  Stream<List<Measurement>> watchAll() {
    return (_db.select(_db.measurements)
          ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
        .watch()
        .map((rows) => rows.map(_toMeasurement).toList());
  }

  @override
  Future<Measurement> add(
      int metricId, double value, DateTime recordedAt) async {
    final id = await _db.into(_db.measurements).insert(
      MeasurementsCompanion.insert(
        metricId: metricId,
        value: value,
        recordedAt: recordedAt,
      ),
    );
    return Measurement(
      id: id,
      metricId: metricId,
      value: value,
      recordedAt: recordedAt,
    );
  }

  Measurement _toMeasurement(MeasurementRow row) => Measurement(
        id: row.id,
        metricId: row.metricId,
        value: row.value,
        recordedAt: row.recordedAt,
      );
}
