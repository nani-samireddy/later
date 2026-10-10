import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/camera/camera_capture_controller.dart';
import 'package:later/features/camera/presentation/camera_capture_dialog.dart';

class ReviewCamera implements PhotoCamera {
  ReviewCamera(this.path);
  final String path;
  bool captured = false;
  @override
  Future<String?> takePhoto() async {
    if (captured) return null;
    captured = true;
    return path;
  }
}

void main() {
  testWidgets(
    'photo requires explicit title and save; failed save preserves review',
    (tester) async {
      late Directory root;
      late CameraCaptureController controller;
      await tester.runAsync(() async {
        root = await Directory.systemTemp.createTemp('camera-review-');
        final source = File('${root.path}/photo.png');
        await source.writeAsBytes(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a9XcAAAAASUVORK5CYII=',
          ),
        );
        controller = CameraCaptureController(
          camera: ReviewCamera(source.path),
          temporaryDirectory: () async => root,
        );
        await controller.capture();
      });
      var saves = 0;
      CameraTaskDraft? reviewed;
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CameraCaptureDialog(
                controller: controller,
                captureOnOpen: false,
                onSave: (draft) async {
                  saves++;
                  reviewed = draft;
                  return false;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(controller.photos, hasLength(1));
        expect(saves, 0);
        await tester.tap(find.text('Save task'));
        await tester.pump();
        expect(saves, 0);
        expect(
          find.text('Add a title and at least one photo.'),
          findsOneWidget,
        );
        await tester.enterText(find.byType(TextField).first, 'Remember this');
        await tester.tap(find.text('Save task'));
        await tester.pumpAndSettle();
        expect(saves, 1);
        expect(reviewed!.title, 'Remember this');
        expect(reviewed!.attachments, hasLength(1));
        expect(controller.photos, hasLength(1));
        expect(
          find.text('Could not save this task. Review it and try again.'),
          findsOneWidget,
        );
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() async {
          await controller.close();
          controller.dispose();
          await root.delete(recursive: true);
        });
      }
    },
  );
}
