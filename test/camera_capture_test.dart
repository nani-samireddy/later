import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/core/attachments/attachment_store.dart';
import 'package:later/features/capture/data/entry_capture_service.dart';
import 'package:later/features/things/data/things_repository.dart';

import 'support/fake_reminders.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/camera/camera_capture_controller.dart';

class FakeCamera implements PhotoCamera {
  Future<String?> Function() capture = () async => null;
  @override
  Future<String?> takePhoto() => capture();
}

void main() {
  late Directory root;
  late FakeCamera native;
  late CameraCaptureController controller;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('camera-test-');
    native = FakeCamera();
    controller = CameraCaptureController(
      camera: native,
      temporaryDirectory: () async => root,
    );
  });
  tearDown(() async {
    await controller.close();
    controller.dispose();
    await root.delete(recursive: true);
  });
  test('camera cancellation is empty and denial permits retry', () async {
    await controller.capture();
    expect(controller.photos, isEmpty);
    expect(controller.error, isNull);
    native.capture = () async =>
        throw const CameraCaptureException('Camera access is blocked.');
    await controller.capture();
    expect(controller.error, contains('blocked'));
    expect(controller.busy, isFalse);
    native.capture = () async => null;
    await controller.capture();
    expect(controller.error, isNull);
  });
  test(
    'multiple captures are private staged copies; removal and cancel clean up',
    () async {
      Future<String?> capture() async {
        final file = File('${root.path}/native.jpg');
        await file.writeAsBytes([1, 2, 3]);
        return file.path;
      }

      native.capture = capture;
      await controller.capture();
      await controller.capture();
      expect(controller.photos, hasLength(2));
      expect(await File('${root.path}/native.jpg').exists(), isFalse);
      final paths = controller.photos.map((p) => p.path!).toList();
      expect(await File(paths.first).readAsBytes(), [1, 2, 3]);
      await controller.remove(0);
      expect(await File(paths.first).exists(), isFalse);
      await controller.close();
      expect(await File(paths.last).exists(), isFalse);
    },
  );
  test(
    'closing during native capture removes late result without adding it',
    () async {
      final result = Completer<String?>();
      native.capture = () => result.future;
      final capture = controller.capture();
      final closing = controller.close();
      final source = File('${root.path}/late.jpg');
      await source.writeAsBytes([4]);
      result.complete(source.path);
      await capture;
      await closing;
      expect(controller.photos, isEmpty);
      expect(await source.exists(), isFalse);
    },
  );
  test('saved capture survives staging cleanup and reopening, then task deletion removes copy', () async {
    final source = File('${root.path}/capture.jpg');
    await source.writeAsBytes([1, 2, 3]);
    native.capture = () async => source.path;
    await controller.capture();
    final store = AttachmentStore(
      directory: () async => Directory('${root.path}/private'),
    );
    final dbFile = File('${root.path}/db.sqlite');
    var db = AppDatabase.withExecutor(NativeDatabase(dbFile));
    final scheduler = FakeReminders();
    try {
      expect(
        await EntryCaptureService(db, scheduler: scheduler, store: store).save(
          title: 'Photo task',
          kind: 'thing',
          description: 'Reviewed description',
          category: 'General',
          amount: '',
          person: '',
          currency: 'INR',
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
          attachments: controller.photos,
        ),
        isTrue,
      );
      final row = (await db.allThings()).single;
      expect(row.status, 'active');
      expect(row.description, 'Reviewed description');
      final saved = (await db.attachmentsFor(row.id)).single.path;
      await controller.close();
      await db.close();
      db = AppDatabase.withExecutor(NativeDatabase(dbFile));
      expect(await File(saved).readAsBytes(), [1, 2, 3]);
      expect((await db.attachmentsFor(row.id)).single.path, saved);
      await ThingsRepository(
        db,
        scheduler: scheduler,
        store: store,
      ).delete(row.id);
      expect(await File(saved).exists(), isFalse);
    } finally {
      await db.close();
    }
  });
  test('recovery stages all photos without opening camera and cancel deletes cache', () async {
    var nativeCalls = 0;
    native.capture = () async {
      nativeCalls++;
      return null;
    };
    final paths = <String>[];
    for (var i = 0; i < 2; i++) {
      final file = File('${root.path}/recovered_$i.jpg');
      await file.writeAsBytes([i]);
      paths.add(file.path);
    }
    await controller.recover(paths);
    expect(nativeCalls, 0);
    expect(controller.photos, hasLength(2));
    for (final path in paths) {
      expect(await File(path).exists(), isFalse);
    }
    final staged = controller.photos.map((photo) => photo.path!).toList();
    await controller.close();
    for (final path in staged) {
      expect(await File(path).exists(), isFalse);
    }
  });
}
