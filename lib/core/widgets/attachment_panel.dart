import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../attachments/attachment_repository.dart';
import '../attachments/attachment_opener.dart';
import '../attachments/stored_attachment.dart';

class AttachmentPanel extends StatefulWidget {
  final AppDatabase database;
  final AttachmentOwner owner;
  final int recordId;
  const AttachmentPanel({
    super.key,
    required this.database,
    required this.owner,
    required this.recordId,
  });
  @override
  State<AttachmentPanel> createState() => _AttachmentPanelState();
}

class _AttachmentPanelState extends State<AttachmentPanel> {
  late final repository = AttachmentRepository(widget.database);
  List<StoredAttachment> attachments = [];
  bool busy = false;
  bool loading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final loaded = await repository.all(widget.owner, widget.recordId);
      if (mounted) {
        setState(() {
          attachments = loaded;
          loading = false;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Could not load attachments.';
        });
      }
    }
  }

  Future<void> _add() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (result == null || !mounted) return;
      for (final file in result.files) {
        await repository.add(widget.owner, widget.recordId, file);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Could not copy one of the files. Select it again.',
        );
      }
    } finally {
      if (mounted) {
        final previousError = error;
        await _load();
        if (mounted) {
          setState(() {
            busy = false;
            error = previousError;
          });
        }
      }
    }
  }

  Future<void> _remove(StoredAttachment attachment) async {
    setState(() => busy = true);
    try {
      await repository.remove(widget.owner, attachment);
      await _load();
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Could not remove this attachment. Try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Attachments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            tooltip: 'Add attachment',
            onPressed: busy ? null : _add,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      if (loading || busy) const LinearProgressIndicator(),
      if (error != null)
        Row(
          children: [
            Expanded(child: Text(error!)),
            TextButton(
              onPressed: busy ? null : _load,
              child: const Text('Retry'),
            ),
          ],
        ),
      if (!loading && attachments.isEmpty)
        const Text('Add images, PDFs, receipts, or other documents.'),
      ...attachments.map(
        (attachment) => Card(
          elevation: 0,
          child: ListTile(
            onTap: busy ? null : () => openAttachment(context, attachment),
            leading: Icon(
              attachment.kind == 'image'
                  ? Icons.image_outlined
                  : Icons.description_outlined,
            ),
            title: Text(attachment.name),
            subtitle: const Text('Tap to open'),
            trailing: IconButton(
              tooltip: 'Remove attachment',
              onPressed: busy ? null : () => _remove(attachment),
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ),
    ],
  );
}
