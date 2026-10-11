import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/widgets/note_body_editor.dart';
import '../../../core/widgets/reminder_picker.dart';
import '../../../core/attachments/attachment_repository.dart';
import '../../../core/attachments/stored_attachment.dart';
import '../../things/data/things_repository.dart';
import '../data/entry_capture_service.dart';

class NoteComposerScreen extends StatefulWidget {
  final EntryCaptureService service;
  final Future<void> Function() onChanged;
  final bool checklist;
  final String initialText;
  const NoteComposerScreen({
    super.key,
    required this.service,
    required this.onChanged,
    this.checklist = false,
    this.initialText = '',
  });
  @override
  State<NoteComposerScreen> createState() => _NoteComposerScreenState();
}

class _NoteComposerScreenState extends State<NoteComposerScreen>
    with WidgetsBindingObserver {
  late final title = TextEditingController(
    text: widget.initialText.characters.take(50).toString(),
  );
  late final body = TextEditingController(
    text: widget.checklist ? '- [ ] ' : widget.initialText,
  );
  late final repository = ThingsRepository(
    widget.service.database,
    scheduler: widget.service.scheduler,
    store: widget.service.store,
  );
  final editorKey = GlobalKey<NoteBodyEditorState>();
  Timer? timer;
  Future<void> queue = Future.value();
  int? id;
  int revision = 0;
  int savedRevision = 0;
  DateTime? reminder;
  bool closing = false;
  bool canLeave = false;
  String status = '';
  List<PlatformFile> pendingFiles = [];
  int attachmentCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialText.isNotEmpty) changed();
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
    final text = body.text;
    final name = title.text.trim();
    final date = reminder;
    final files = [...pendingFiles];
    queue = queue.then((_) async {
      if (current <= savedRevision) return;
      if (id == null && name.isEmpty && text.trim().isEmpty && files.isEmpty) {
        savedRevision = current;
        return;
      }
      if (mounted) setState(() => status = 'Saving…');
      try {
        final label = name.isEmpty ? 'Untitled note' : name;
        id ??= await widget.service.database.addThing(
          db.ThingsCompanion.insert(
            title: label,
            category: 'General',
            iconCodePoint: Icons.bookmark_outline_rounded.codePoint,
          ),
        );
        await repository.edit(
          id!,
          label,
          'General',
          description: text,
          reminderDate: date,
        );
        final attachments = AttachmentRepository(
          widget.service.database,
          store: widget.service.store,
        );
        for (final file in files) {
          if (!pendingFiles.contains(file)) continue;
          await attachments.add(AttachmentOwner.thing, id!, file);
          pendingFiles.remove(file);
          attachmentCount++;
        }
        savedRevision = current;
        await widget.onChanged();
        if (mounted) {
          setState(
            () => status = current == revision ? 'Saved' : 'Unsaved changes',
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
      if (mounted) Navigator.pop(context);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: canLeave,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) unawaited(finish());
    },
    child: Scaffold(
      appBar: AppBar(
        actions: [
          if (status.contains('Could not'))
            TextButton(onPressed: save, child: const Text('Retry')),
          TextButton(
            onPressed: closing ? null : finish,
            child: const Text('Done'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: title,
              enabled: !closing,
              onChanged: (_) => changed(),
              style: Theme.of(context).textTheme.headlineMedium,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),
            NoteBodyEditor(
              key: editorKey,
              hideControls: true,
              controller: body,
              compact: true,
              enabled: !closing,
              onChanged: (_) => changed(),
            ),
            if (attachmentCount + pendingFiles.length > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  '${attachmentCount + pendingFiles.length} attachments',
                ),
              ),
            if (reminder != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text('Reminder: $reminder'),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Checklist',
                onPressed: closing
                    ? null
                    : () => editorKey.currentState?.toggleChecklist(),
                icon: const Icon(Icons.checklist),
              ),
              PopupMenuButton<String>(
                tooltip: 'Formatting',
                enabled: !closing,
                icon: const Icon(Icons.text_format),
                itemBuilder: (_) => [
                  for (final label in [
                    'Bold',
                    'Italic',
                    'Underline',
                    'Heading',
                  ])
                    PopupMenuItem(value: label, child: Text(label)),
                ],
                onSelected: (format) =>
                    editorKey.currentState?.applyFormat(format),
              ),
              IconButton(
                tooltip: 'Add attachment',
                onPressed: closing
                    ? null
                    : () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: true,
                        );
                        if (result != null && mounted) {
                          pendingFiles.addAll(result.files);
                          changed();
                        }
                      },
                icon: const Icon(Icons.add_box_outlined),
              ),
              IconButton(
                tooltip: 'Reminder',
                onPressed: closing
                    ? null
                    : () async {
                        final value = await pickReminder(
                          context,
                          reminder,
                          database: widget.service.database,
                        );
                        if (value != null && mounted) {
                          reminder = value;
                          changed();
                        }
                      },
                icon: const Icon(Icons.notifications_none),
              ),
              PopupMenuButton<String>(
                tooltip: 'Note options',
                enabled: !closing,
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Remove reminder'),
                  ),
                ],
                onSelected: (_) {
                  reminder = null;
                  changed();
                },
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
