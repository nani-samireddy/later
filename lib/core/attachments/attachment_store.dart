import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'stored_attachment.dart';

class AttachmentStore {
  final Future<Directory> Function() directory;
  AttachmentStore({Future<Directory> Function()? directory})
    : directory =
          directory ??
          (() async => Directory(
            path.join(
              (await getApplicationSupportDirectory()).path,
              'attachments',
            ),
          ));
  Future<bool> owns(String filePath) async =>
      filePath.isNotEmpty &&
      path.isWithin(
        (await directory()).absolute.path,
        File(filePath).absolute.path,
      );
  Future<StoredAttachment> importFile(
    AttachmentOwner owner,
    int recordId,
    PlatformFile file,
  ) async {
    if (recordId <= 0) throw ArgumentError('An existing record is required');
    final root = await directory();
    final folder = Directory(path.join(root.path, owner.name, '$recordId'));
    await folder.create(recursive: true);
    final name = path.basename(file.name.replaceAll('\\', '/'));
    final target = File(
      path.join(
        folder.path,
        '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}_$name',
      ),
    );
    try {
      if (file.bytes != null) {
        await target.writeAsBytes(file.bytes!, flush: true);
      } else if (file.path != null && await File(file.path!).exists()) {
        await File(file.path!).copy(target.path);
      } else {
        throw const FileSystemException(
          'The selected file is no longer available. Select it again.',
        );
      }
      final extension = path.extension(name).toLowerCase();
      final kind =
          {'.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp'}.contains(extension)
          ? 'image'
          : 'document';
      return StoredAttachment(id: 0, name: name, path: target.path, kind: kind);
    } catch (_) {
      if (await target.exists()) await target.delete();
      rethrow;
    }
  }

  Future<void> remove(String filePath) async {
    if (!await owns(filePath)) return;
    final file = File(filePath);
    if (await file.exists()) await file.delete();
  }

  Future<void> removeRecord(AttachmentOwner owner, int id) async {
    final folder = Directory(
      path.join((await directory()).path, owner.name, '$id'),
    );
    if (await folder.exists()) await folder.delete(recursive: true);
  }
}
