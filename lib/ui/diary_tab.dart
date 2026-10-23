import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/day.dart';
import '../domain/diary_entry.dart';
import '../providers/diary_providers.dart';
import '../providers/selected_day_provider.dart';
import 'format.dart';
import 'theme/app_spacing.dart';
import 'widgets/app_card.dart';
import 'widgets/app_empty_state.dart';
import 'widgets/app_section_label.dart';

class DiaryTab extends ConsumerWidget {
  const DiaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final entriesAsync = ref.watch(diaryEntriesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.xs,
          ),
          child: AppSectionLabel(
            'Entries',
            trailing: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add entry',
              onPressed: () => _addEntry(context, ref),
            ),
          ),
        ),
        Expanded(
          child: entriesAsync.when(
            data: (entries) => _buildList(context, ref, day, entries),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    List<DiaryEntry> entries,
  ) {
    final forDay = entries.where((e) => isSameDay(e.occurredAt, day)).toList()
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

    if (forDay.isEmpty) {
      return const AppEmptyState(
        icon: Icons.menu_book_outlined,
        message: 'No entries for this day',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      itemCount: forDay.length,
      itemBuilder: (context, index) {
        final entry = forDay[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _EntryCard(
            entry: entry,
            onTap: () => _editEntry(context, ref, entry),
            onDelete: () =>
                ref.read(diaryEntriesProvider.notifier).delete(entry.id!),
          ),
        );
      },
    );
  }

  Future<void> _addEntry(BuildContext context, WidgetRef ref) async {
    final form = await showDialog<_EntryForm>(
      context: context,
      builder: (_) => const _EntryDialog(),
    );
    if (form == null) return;

    await ref
        .read(diaryEntriesProvider.notifier)
        .add(occurredAt: form.occurredAt, text: form.text);
  }

  Future<void> _editEntry(
    BuildContext context,
    WidgetRef ref,
    DiaryEntry entry,
  ) async {
    final form = await showDialog<_EntryForm>(
      context: context,
      builder: (_) => _EntryDialog(initial: entry),
    );
    if (form == null) return;

    await ref
        .read(diaryEntriesProvider.notifier)
        .updateEntry(
          DiaryEntry(
            id: entry.id,
            occurredAt: form.occurredAt,
            text: form.text,
            audioPath: entry.audioPath,
          ),
        );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final DiaryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xxs,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              formatTime(entry.occurredAt),
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text(entry.text ?? '', style: textTheme.bodyLarge),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Delete entry',
            color: scheme.onSurfaceVariant,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _EntryForm {
  const _EntryForm({required this.text, required this.occurredAt});

  final String text;
  final DateTime occurredAt;
}

class _EntryDialog extends StatefulWidget {
  const _EntryDialog({this.initial});

  final DiaryEntry? initial;

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  late final TextEditingController _controller;
  late DateTime _occurredAt;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial?.text ?? '');
    _occurredAt = widget.initial?.occurredAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time == null) return;

    setState(() {
      _occurredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Text is required');
      return;
    }
    Navigator.of(context).pop(_EntryForm(text: text, occurredAt: _occurredAt));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'New entry' : 'Edit entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Text', errorText: _error),
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Time'),
            subtitle: Text(
              '${formatDate(_occurredAt)} ${formatTime(_occurredAt)}',
            ),
            onTap: _pickDateTime,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
