import 'package:daylog/domain/diary_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiaryEntry', () {
    final occurredAt = DateTime(2026, 10, 20, 9, 30);

    test('allows text-only entries', () {
      final entry = DiaryEntry(occurredAt: occurredAt, text: 'Hello');
      expect(entry.text, 'Hello');
      expect(entry.audioPath, isNull);
    });

    test('allows audio-only entries', () {
      final entry = DiaryEntry(occurredAt: occurredAt, audioPath: '/tmp/a.m4a');
      expect(entry.audioPath, '/tmp/a.m4a');
      expect(entry.text, isNull);
    });

    test('allows both text and audio', () {
      final entry = DiaryEntry(occurredAt: occurredAt, text: 'Hi', audioPath: '/tmp/a.m4a');
      expect(entry.text, 'Hi');
      expect(entry.audioPath, '/tmp/a.m4a');
    });

    test('throws ArgumentError when neither text nor audio is provided', () {
      expect(
        () => DiaryEntry(occurredAt: occurredAt),
        throwsArgumentError,
      );
    });
  });
}
