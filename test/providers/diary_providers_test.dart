import 'package:daylog/data/app_database.dart';
import 'package:daylog/domain/day.dart';
import 'package:daylog/domain/diary_entry.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/providers/diary_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('add then list', () async {
    await container.read(diaryEntriesProvider.future);

    await container
        .read(diaryEntriesProvider.notifier)
        .add(occurredAt: DateTime(2026, 10, 20, 9), text: 'hello');

    final entries = await container.read(diaryEntriesProvider.future);
    expect(entries.length, 1);
    expect(entries.single.text, 'hello');
    expect(entries.single.audioPath, isNull);
    expect(entries.single.id, isNotNull);
  });

  test('update text', () async {
    final notifier = container.read(diaryEntriesProvider.notifier);
    await notifier.add(occurredAt: DateTime(2026, 10, 20, 9), text: 'before');

    final entries = await container.read(diaryEntriesProvider.future);
    final entry = entries.single;

    await notifier.updateEntry(
      DiaryEntry(
        id: entry.id,
        occurredAt: entry.occurredAt,
        text: 'after',
      ),
    );

    final updated = await container.read(diaryEntriesProvider.future);
    expect(updated.single.text, 'after');
  });

  test('delete', () async {
    final notifier = container.read(diaryEntriesProvider.notifier);
    await notifier.add(occurredAt: DateTime(2026, 10, 20, 9), text: 'gone');

    final entries = await container.read(diaryEntriesProvider.future);
    await notifier.delete(entries.single.id!);

    final remaining = await container.read(diaryEntriesProvider.future);
    expect(remaining, isEmpty);
  });

  test('filters by day with isSameDay', () async {
    final notifier = container.read(diaryEntriesProvider.notifier);
    await notifier.add(occurredAt: DateTime(2026, 10, 20, 9), text: 'a');
    await notifier.add(occurredAt: DateTime(2026, 10, 21, 9), text: 'b');

    final all = await container.read(diaryEntriesProvider.future);
    final day = DateTime(2026, 10, 20);
    final forDay =
        all.where((e) => isSameDay(e.occurredAt, day)).toList();

    expect(forDay.length, 1);
    expect(forDay.single.text, 'a');
  });
}
