import '../../../core/widgets/note_body_editor.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/camera/camera_capture_controller.dart';
import '../../../core/camera/image_picker_camera.dart';
import '../../../core/widgets/reminder_picker.dart';

/// onSave must await EntryCaptureService.save(kind: 'thing', ...) and return
/// true only after attachments have durable private copies. False keeps review
/// open. Throw only for failures known not to have committed the entry.
Future<bool> showCameraCaptureDialog(
  BuildContext context, {
  required Future<bool> Function(CameraTaskDraft draft) onSave,
  PhotoCamera? camera,
  AppDatabase? database,
  List<String> recoveredPhotoPaths = const [],
}) async {
  final controller = CameraCaptureController(
    camera: camera ?? ImagePickerCamera(),
  );
  try {
    if (recoveredPhotoPaths.isNotEmpty) {
      await controller.recover(recoveredPhotoPaths);
      if (!context.mounted) return false;
    }
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => CameraCaptureDialog(
            controller: controller,
            onSave: onSave,
            database: database,
            captureOnOpen: recoveredPhotoPaths.isEmpty,
          ),
        ) ??
        false;
  } finally {
    await controller.close();
    controller.dispose();
  }
}

class CameraCaptureDialog extends StatefulWidget {
  const CameraCaptureDialog({
    super.key,
    required this.controller,
    required this.onSave,
    this.database,
    this.captureOnOpen = true,
  });
  final AppDatabase? database;
  final bool captureOnOpen;
  final CameraCaptureController controller;
  final Future<bool> Function(CameraTaskDraft) onSave;
  @override
  State<CameraCaptureDialog> createState() => _CameraCaptureDialogState();
}

class _CameraCaptureDialogState extends State<CameraCaptureDialog> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime? _reminder;
  bool _saving = false;
  String? _error;
  CameraCaptureController get camera => widget.controller;
  bool get _busy => _saving || camera.busy;
  @override
  void initState() {
    super.initState();
    camera.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.captureOnOpen) unawaited(camera.capture());
    });
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    camera.removeListener(_update);
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    if (_title.text.trim().isEmpty || camera.photos.isEmpty) {
      setState(() => _error = 'Add a title and at least one photo.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await widget.onSave(
        CameraTaskDraft(
          title: _title.text.trim(),
          description: _description.text.trim(),
          attachments: camera.photos,
          reminder: _reminder,
        ),
      );
      if (!mounted) return;
      if (saved) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(
        () => _error = 'Could not save this task. Review it and try again.',
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not save this task. Your photos are still here; try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const Text('Photo task'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Take a photo, review it, then save your task.'),
              const SizedBox(height: 12),
              if (camera.busy) const LinearProgressIndicator(),
              if (camera.error != null || _error != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error ?? camera.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              for (var i = 0; i < camera.photos.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          label: 'Photo ${i + 1}',
                          child: Image.file(
                            File(camera.photos[i].path!),
                            height: 160,
                            fit: BoxFit.contain,
                            errorBuilder: (_, error, stack) =>
                                const Text('Photo preview unavailable'),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove photo ${i + 1}',
                        onPressed: _busy ? null : () => camera.remove(i),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _busy ? null : camera.capture,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(
                  camera.photos.isEmpty ? 'Take photo' : 'Add another photo',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                enabled: !_busy,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'What do you want to remember?',
                ),
              ),
              NoteBodyEditor(
                controller: _description,
                enabled: !_busy,
                compact: true,
              ),
              ReminderPicker(
                database: widget.database,
                value: _reminder,
                enabled: !_busy,
                showHelp: false,
                onChanged: (value) => setState(() => _reminder = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(_saving ? 'Saving…' : 'Save task'),
        ),
      ],
    ),
  );
}
