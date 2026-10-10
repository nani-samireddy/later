import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:later/core/payments/payment_screenshot_parser.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native OCR reads synthetic screenshot and blank image', (
    tester,
  ) async {
    final directory = await getTemporaryDirectory();
    Future<File> fixture(String name, String text) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawColor(Colors.white, BlendMode.src);
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: Colors.black, fontSize: 38),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 700);
      painter.paint(canvas, const Offset(40, 60));
      final picture = recorder.endRecording();
      final image = await picture.toImage(800, 900);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('${directory.path}/$name.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
      picture.dispose();
      painter.dispose();
      return file;
    }

    final paid = await fixture(
      'later_payment_paid',
      'Payment successful\nPaid to\nAsha Rao\nINR 1,250.50\nTransaction ID 123456789',
    );
    final blank = await fixture('later_payment_blank', '');
    try {
      final result = await PaymentScreenshotParser.parse(paid.path);
      expect(result!.amount, '1250.50');
      expect(result.merchant, 'Asha Rao');
      final empty = await PaymentScreenshotParser.parse(blank.path);
      expect(empty!.reviewMessage, contains('No text'));
    } finally {
      await paid.delete();
      await blank.delete();
    }
  });
}
