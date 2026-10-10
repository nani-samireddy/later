import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:later/core/payments/payment_screenshot_parser.dart';
import 'package:later/core/payments/shared_payment_service.dart';

void main() {
  test('OCR fixtures retain reliable amount and counterparty', () {
    final text = File('test/fixtures/payments/paid.txt').readAsStringSync();
    final result = PaymentScreenshotParser.fromText(text, '/shared.png');
    expect(result.amount, '1250.50');
    expect(result.merchant, 'Asha Rao');
    expect(result.attachmentPath, '/shared.png');
  });
  test('different amounts are uncertain, repeated amount is reliable', () {
    final result = PaymentScreenshotParser.fromText(
      File('test/fixtures/payments/ambiguous.txt').readAsStringSync(),
      '/x',
    );
    expect(result.amount, isEmpty);
    expect(result.reviewMessage, contains('Several amounts'));
    expect(
      PaymentScreenshotParser.fromText('₹100\nTotal ₹100', '/x').amount,
      '100',
    );
  });
  test('no text still opens editable attachment review', () {
    final result = PaymentScreenshotParser.fromText('', '/blank.png');
    expect(result.text, isEmpty);
    expect(result.reviewMessage, contains('No text'));
  });
  test('transaction IDs and branding do not become amounts or people', () {
    final result = PaymentScreenshotParser.fromText(
      'Google Pay\nTransaction ID 123456789\nPayment successful',
      '/x',
    );
    expect(result.amount, isEmpty);
    expect(result.merchant, isEmpty);
  });
  test(
    'duplicate and overlapping shares cannot open concurrent review',
    () async {
      final gate = Completer<void>();
      var parses = 0;
      var reviews = 0;
      final feedback = <String>[];
      final service = SharedPaymentService(
        parse: (path) async {
          parses++;
          return PaymentScreenshotParser.fromText('₹100', path);
        },
      );
      List<SharedMediaFile> image(String path) => [
        SharedMediaFile(path: path, type: SharedMediaType.image),
      ];
      Future<void> review(PaymentScreenshotData data) async {
        reviews++;
        await gate.future;
      }

      final first = service.handle(image('/a'), review);
      await Future<void>.delayed(Duration.zero);
      await service.handle(image('/a'), review);
      await service.handle(image('/b'), review, onFeedback: feedback.add);
      expect(parses, 1);
      expect(reviews, 1);
      expect(feedback.single, contains('Finish'));
      gate.complete();
      await first;
      await service.dispose();
    },
  );
  test('OCR errors and manual review overlap produce feedback', () async {
    final feedback = <String>[];
    final service = SharedPaymentService(
      parse: (_) async => throw StateError('OCR'),
    );
    final files = [SharedMediaFile(path: '/a', type: SharedMediaType.image)];
    await service.handle(
      files,
      (_) {},
      onFeedback: feedback.add,
      isReviewOpen: () => true,
    );
    expect(feedback.removeLast(), contains('Finish'));
    await service.handle(files, (_) {}, onFeedback: feedback.add);
    expect(feedback.single, contains('Could not read'));
    await service.dispose();
  });
}
