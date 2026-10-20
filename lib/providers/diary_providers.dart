import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/diary_entry_repository.dart';
import '../domain/diary_entry.dart';
import 'database_provider.dart';

final diaryRepositoryProvider = Provider<DiaryEntryRepository>((ref) {
  return DriftDiaryEntryRepository(ref.watch(databaseProvider));
});

class DiaryEntriesNotifier extends AsyncNotifier<List<DiaryEntry>> {
  @override
  Future<List<DiaryEntry>> build() {
    return ref.watch(diaryRepositoryProvider).getAll();
  }

  Future<void> add({
    required DateTime occurredAt,
    String? text,
    String? audioPath,
  }) async {
    final repo = ref.read(diaryRepositoryProvider);
    await repo.add(occurredAt: occurredAt, text: text, audioPath: audioPath);
    state = await AsyncValue.guard(() => repo.getAll());
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    final repo = ref.read(diaryRepositoryProvider);
    await repo.update(entry);
    state = await AsyncValue.guard(() => repo.getAll());
  }

  Future<void> delete(int id) async {
    final repo = ref.read(diaryRepositoryProvider);
    await repo.delete(id);
    state = await AsyncValue.guard(() => repo.getAll());
  }
}

final diaryEntriesProvider =
    AsyncNotifierProvider<DiaryEntriesNotifier, List<DiaryEntry>>(
        DiaryEntriesNotifier.new);
