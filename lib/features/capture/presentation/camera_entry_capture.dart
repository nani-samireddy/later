import 'package:flutter/material.dart';

import '../../camera/presentation/camera_capture_dialog.dart';
import '../../settings/data/settings_preferences.dart';
import '../data/entry_capture_service.dart';

Future<bool> captureCameraEntry(
  BuildContext context, {
  required EntryCaptureService service,
  required String currency,
  required Future<void> Function() onThingsChanged,
  List<String> recoveredPhotoPaths = const [],
}) async {
  final defaultTime = await SettingsPreferences(service.database)
      .reminderTime();
  if (!context.mounted) return false;
  return showCameraCaptureDialog(
    context,
    database: service.database,
    recoveredPhotoPaths: recoveredPhotoPaths,
    onSave: (draft) async {
      final saved = await service.save(
        title: draft.title,
        kind: 'thing',
        description: draft.description,
        category: 'General',
        amount: '',
        person: '',
        currency: currency,
        attachments: draft.attachments,
        reminderDate: draft.reminder,
        reminderTime: draft.reminder == null
            ? defaultTime
            : TimeOfDay.fromDateTime(draft.reminder!),
      );
      if (saved) {
        try {
          await onThingsChanged();
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task saved. Reopen Things to refresh the list.'),
              ),
            );
          }
        }
      }
      return saved;
    },
  );
}
