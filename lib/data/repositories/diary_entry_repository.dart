import 'package:drift/drift.dart';

import '../../domain/diary_entry.dart';
import '../app_database.dart';

abstract class DiaryEntryRepository {
  Future<List<DiaryEntry>> getAll();

  Stream<List<DiaryEntry>> watchAll();

  Future<DiaryEntry> add({
    required DateTime occurredAt,
    String? text,
    String? audioPath,
  });

  Future<void> update(DiaryEntry entry);

  Future<void> delete(int id);
}

class DriftDiaryEntryRepository implements DiaryEntryRepository {
  DriftDiaryEntryRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<DiaryEntry>> getAll() async {
    final rows = await (_db.select(_db.diaryEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<DiaryEntry>> watchAll() {
    return (_db.select(_db.diaryEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<DiaryEntry> add({
    required DateTime occurredAt,
    String? text,
    String? audioPath,
  }) async {
    final id = await _db.into(_db.diaryEntries).insert(
          DiaryEntriesCompanion.insert(
            occurredAt: occurredAt,
            textContent: Value(text),
            audioPath: Value(audioPath),
          ),
        );
    return DiaryEntry(
      id: id,
      occurredAt: occurredAt,
      text: text,
      audioPath: audioPath,
    );
  }

  @override
  Future<void> update(DiaryEntry entry) async {
    final id = entry.id;
    if (id == null) {
      throw ArgumentError('Cannot update a DiaryEntry without an id');
    }
    await (_db.update(_db.diaryEntries)..where((t) => t.id.equals(id))).write(
      DiaryEntriesCompanion(
        occurredAt: Value(entry.occurredAt),
        textContent: Value(entry.text),
        audioPath: Value(entry.audioPath),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.diaryEntries)..where((t) => t.id.equals(id))).go();
  }

  DiaryEntry _toDomain(DiaryEntryRow row) => DiaryEntry(
        id: row.id,
        occurredAt: row.occurredAt,
        text: row.textContent,
        audioPath: row.audioPath,
      );
}
