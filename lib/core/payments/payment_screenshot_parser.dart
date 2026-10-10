import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../ai/local_entry_ai.dart';
import 'payment_screenshot_data.dart';
export 'payment_screenshot_data.dart';

class PaymentScreenshotParser {
  static Future<PaymentScreenshotData?> parse(String filePath) async {
    if (!await File(filePath).exists()) {
      throw const FileSystemException('Shared image is no longer available.');
    }
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    String text;
    try {
      text = (await recognizer.processImage(InputImage.fromFilePath(filePath)))
          .text
          .trim();
    } finally {
      await recognizer.close();
    }
    LocalEntryData? aiData;
    if (text.isNotEmpty) {
      try {
        aiData = await LocalEntryAi.extract(text);
      } catch (_) {
        /* OCR remains usable. */
      }
    }
    return fromText(text, filePath, aiData: aiData);
  }

  /// Pure OCR interpretation, also used by fixture tests. Multiple different
  /// currency amounts are intentionally left for manual review.
  static PaymentScreenshotData fromText(
    String text,
    String filePath, {
    LocalEntryData? aiData,
  }) {
    final matches = RegExp(
      r'(?:₹|rs\.?|inr)\s*([\d,]+(?:\.\d{1,2})?)|(?:amount|total|paid)\s*[:\-]?\s*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).allMatches(text);
    final amounts = matches
        .map((m) => (m.group(1) ?? m.group(2)!).replaceAll(',', ''))
        .where((v) => (double.tryParse(v) ?? 0) > 0)
        .toSet();
    final merchant = _merchant(text);
    return PaymentScreenshotData(
      text: text.trim(),
      amount: amounts.length == 1 ? amounts.single : '',
      merchant: merchant,
      attachmentPath: filePath,
      aiData: aiData,
      reviewMessage: text.trim().isEmpty
          ? 'No text found. Enter the details manually; the image is attached for review.'
          : amounts.length > 1
          ? 'Several amounts found. Choose the correct amount and payment type.'
          : 'Review the extracted details and choose the payment type. A payment does not establish who owes whom.',
    );
  }

  static String _merchant(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    for (var i = 0; i < lines.length; i++) {
      final match = RegExp(
        r'^(?:paid to|payment to|sent to|received from|to|from)\s*[:\-]?\s*(.*)$',
        caseSensitive: false,
      ).firstMatch(lines[i]);
      if (match != null) {
        final value = match.group(1)!.trim();
        if (value.isNotEmpty) return value;
        if (i + 1 < lines.length &&
            RegExp(r'[a-zA-Z]').hasMatch(lines[i + 1])) {
          return lines[i + 1];
        }
      }
    }
    return '';
  }
}
