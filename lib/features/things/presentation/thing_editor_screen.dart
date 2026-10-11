import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/widgets/note_body_editor.dart';
import '../../../core/widgets/reminder_picker.dart';
import '../domain/thing.dart';
import '../data/things_repository.dart';

class ThingEditorScreen extends StatefulWidget {
  final Thing entry;
  final ThingsRepository repository;
  const ThingEditorScreen({
    super.key,
    required this.entry,
    required this.repository,
  });
  @override
  State<ThingEditorScreen> createState() => _ThingEditorScreenState();
}

class _ThingEditorScreenState extends State<ThingEditorScreen>
    with WidgetsBindingObserver {
  late final title = TextEditingController(text: widget.entry.title);
  late final body = TextEditingController(text: widget.entry.description);
  late final category = TextEditingController(text: widget.entry.category);
  late DateTime? reminder = widget.entry.reminderDate;
  Timer? timer;
  Future<void> queue = Future.value();
  int revision = 0;
  int savedRevision = 0;
  bool closing = false;
  bool canLeave = false;
  String status = 'Saved';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void changed() {
    revision++;
    setState(() => status = 'Unsaved changes');
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 500), save);
  }

  Future<void> save() {
    timer?.cancel();
    final current = revision;
    final name = title.text.trim();
    final text = body.text;
    final group = category.text;
    final date = reminder;
    queue = queue.then((_) async {
      if (current <= savedRevision) return;
      if (name.isEmpty) {
        if (mounted) setState(() => status = 'Enter a title to save');
        return;
      }
      if (mounted) setState(() => status = 'Saving…');
      try {
        await widget.repository.edit(
          widget.entry.id,
          name,
          group,
          description: text,
          reminderDate: date,
        );
        savedRevision = current;
        if (mounted) {
          setState(
            () => status = revision == current ? 'Saved' : 'Unsaved changes',
          );
        }
      } catch (_) {
        if (mounted) setState(() => status = 'Could not save. Tap Retry.');
      }
    });
    return queue;
  }

  Future<void> finish() async {
    if (closing) return;
    setState(() => closing = true);
    await save();
    if (!mounted) return;
    if (savedRevision != revision) {
      setState(() => closing = false);
      return;
    }
    setState(() => canLeave = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(save());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    title.dispose();
    body.dispose();
    category.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: canLeave,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) unawaited(finish());
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Edit note'),
        actions: [
          TextButton(
            onPressed: closing ? null : finish,
            child: const Text('Done'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(status)),
                TextButton(
                  onPressed: closing ? null : save,
                  child: const Text('Retry'),
                ),
              ],
            ),
            TextField(
              controller: title,
              enabled: !closing,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (_) => changed(),
            ),
            const SizedBox(height: 16),
            NoteBodyEditor(
              controller: body,
              enabled: !closing,
              onChanged: (_) => changed(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: category,
              enabled: !closing,
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (_) => changed(),
            ),
            IgnorePointer(
              ignoring: closing,
              child: ReminderPicker(
                database: widget.repository.database,
                value: reminder,
                onChanged: (value) {
                  reminder = value;
                  changed();
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
