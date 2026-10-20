class DiaryEntry {
  DiaryEntry({
    required this.occurredAt,
    this.id,
    this.text,
    this.audioPath,
  }) {
    if (text == null && audioPath == null) {
      throw ArgumentError(
        'DiaryEntry requires at least one of text or audioPath',
      );
    }
  }

  final int? id;
  final DateTime occurredAt;
  final String? text;
  final String? audioPath;
}
