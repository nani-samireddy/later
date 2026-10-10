import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import '../database/app_database.dart';
import 'attachment_store.dart';
import 'stored_attachment.dart';

class AttachmentRepository {
  final AppDatabase database;
  final AttachmentStore store;
  AttachmentRepository(this.database, {AttachmentStore? store})
    : store = store ?? AttachmentStore();
  Future<List<StoredAttachment>> all(AttachmentOwner owner, int id) async {
    final List<StoredAttachment> loaded;
    if (owner == AttachmentOwner.thing) {
      loaded = (await database.attachmentsFor(id))
          .map(
            (a) => StoredAttachment(
              id: a.id,
              name: path.basename(a.name),
              path: a.path.isEmpty ? a.name : a.path,
              kind: a.kind,
            ),
          )
          .toList();
    } else {
      loaded = (await database.moneyAttachmentsFor(id))
          .map(
            (a) => StoredAttachment(
              id: a.id,
              name: a.name,
              path: a.path,
              kind: a.kind,
            ),
          )
          .toList();
    }
    final result = <StoredAttachment>[];
    for (final attachment in loaded) {
      if (attachment.path.isNotEmpty &&
          !await store.owns(attachment.path) &&
          await File(attachment.path).exists()) {
        final copy = await store.importFile(
          owner,
          id,
          PlatformFile(
            name: attachment.name,
            size: await File(attachment.path).length(),
            path: attachment.path,
          ),
        );
        try {
          if (owner == AttachmentOwner.thing) {
            await (database.update(
              database.attachments,
            )..where((a) => a.id.equals(attachment.id))).write(
              AttachmentsCompanion(
                name: Value(copy.name),
                path: Value(copy.path),
                kind: Value(copy.kind),
              ),
            );
          } else {
            await (database.update(
              database.moneyAttachments,
            )..where((a) => a.id.equals(attachment.id))).write(
              MoneyAttachmentsCompanion(
                name: Value(copy.name),
                path: Value(copy.path),
                kind: Value(copy.kind),
              ),
            );
          }
          result.add(
            StoredAttachment(
              id: attachment.id,
              name: copy.name,
              path: copy.path,
              kind: copy.kind,
            ),
          );
        } catch (_) {
          await store.remove(copy.path);
          rethrow;
        }
      } else {
        result.add(attachment);
      }
    }
    return result;
  }

  Future<StoredAttachment> add(
    AttachmentOwner owner,
    int id,
    PlatformFile file,
  ) async {
    final copy = await store.importFile(owner, id, file);
    try {
      final int attachmentId;
      if (owner == AttachmentOwner.thing) {
        attachmentId = await database.addAttachment(
          AttachmentsCompanion.insert(
            thingId: id,
            name: copy.name,
            path: Value(copy.path),
            kind: Value(copy.kind),
          ),
        );
      } else {
        attachmentId = await database.addMoneyAttachment(
          MoneyAttachmentsCompanion.insert(
            moneyId: id,
            name: copy.name,
            path: copy.path,
            kind: copy.kind,
          ),
        );
      }
      return StoredAttachment(
        id: attachmentId,
        name: copy.name,
        path: copy.path,
        kind: copy.kind,
      );
    } catch (_) {
      await store.remove(copy.path);
      rethrow;
    }
  }

  Future<void> remove(
    AttachmentOwner owner,
    StoredAttachment attachment,
  ) async {
    if (owner == AttachmentOwner.thing) {
      await database.deleteThingAttachment(attachment.id);
    } else {
      await database.deleteMoneyAttachment(attachment.id);
    }
    await store.remove(attachment.path);
  }
}
