import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../core/backup/backup_service.dart';
import '../../core/database/app_database.dart';

/// Settings can push this screen and refresh their state via onChanged.
class BackupScreen extends StatefulWidget {
  final AppDatabase database;
  final VoidCallback onChanged;
  const BackupScreen({
    super.key,
    required this.database,
    required this.onChanged,
  });
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  late final BackupService service = BackupService(widget.database);
  bool busy = false;
  String? feedback;

  Future<void> run(Future<void> Function() work) async {
    setState(() {
      busy = true;
      feedback = null;
    });
    try {
      await work();
    } on BackupException catch (error) {
      if (mounted) setState(() => feedback = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => feedback = 'Could not access the selected file. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> export() => run(() async {
    final bytes = await service.export();
    final destination = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Later backup',
      fileName:
          'later-${DateTime.now().toIso8601String().substring(0, 10)}.laterbackup',
      type: FileType.custom,
      allowedExtensions: ['laterbackup'],
      bytes: bytes,
    );
    if (destination == null) return;
    // Mobile pickers write supplied bytes; desktop pickers return a path.
    if (!Platform.isAndroid && !Platform.isIOS) {
      final temporary = await Directory(p.dirname(destination))
          .createTemp('.laterbackup-');
      final pending = File(p.join(temporary.path, 'backup.partial'));
      try {
        await pending.writeAsBytes(bytes, flush: true);
        await pending.rename(destination);
      } finally {
        if (await temporary.exists()) await temporary.delete(recursive: true);
      }
    }
    if (mounted) {
      setState(
        () => feedback = 'Backup saved. Store it securely: it contains your private records and attachments.',
      );
    }
  });

  Future<void> import() => run(() async {
    final selected = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Later backup',
      type: FileType.any,
    );
    if (selected == null) return;
    final file = selected.files.single;
    if (file.size > BackupService.maxArchiveBytes) {
      throw const BackupException(
        'Backup is too large to import (maximum 64 MB).',
      );
    }
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final preview = await service.preview(bytes);
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace all local data?'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Backup created ${preview.createdAt.toLocal()}'),
              const SizedBox(height: 12),
              ...preview.counts.entries.map(
                (entry) => Text('${_tableLabel(entry.key)}: ${entry.value}'),
              ),
              Text('Attachment files: ${preview.attachmentCount}'),
              const SizedBox(height: 12),
              const Text(
                'This replaces every current record, setting, repayment and reminder with the backup. It does not merge data. Saved attachments are restored privately and reminders are rebuilt. Export your current data first if you want to keep it.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace all data'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await service.restore(preview);
    widget.onChanged();
    if (mounted) {
      setState(
        () => feedback = result.warning ?? 'Restore complete. All local data was replaced and reminders were rebuilt.',
      );
    }
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Local backup')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Save settings, records, repayment history, reminders and private attachments in one .laterbackup file. Keep a copy somewhere safe.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Backups are not encrypted. Anyone with the file can read its contents. Restore accepts compatible older backups (new fields use defaults) and replaces all current data after confirmation.',
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: busy ? null : export,
          icon: const Icon(Icons.download),
          label: const Text('Export backup'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: busy ? null : import,
          icon: const Icon(Icons.upload),
          label: const Text('Import backup'),
        ),
        if (busy)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (feedback != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Semantics(liveRegion: true, child: Text(feedback!)),
          ),
      ],
    ),
  );
}

String _tableLabel(String name) => switch (name) {
  'things' => 'Things',
  'attachments' => 'Thing attachments',
  'money_entries' => 'Money records',
  'money_attachments' => 'Money attachments',
  'money_payments' => 'Repayments',
  'app_settings' => 'Settings and reminder policies',
  _ => name.replaceAll('_', ' '),
};
