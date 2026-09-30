import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../ai/local_entry_ai.dart';

class PaymentScreenshotData {
  final String text;
  final String amount;
  final String merchant;
  final String attachmentPath;
  final LocalEntryData? aiData;

  const PaymentScreenshotData({
    required this.text,
    required this.amount,
    required this.merchant,
    required this.attachmentPath,
    this.aiData,
  });
}

class PaymentScreenshotParser {
  static Future<PaymentScreenshotData?> parse(String filePath) async {
    if (!File(filePath).existsSync()) return null;
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(filePath),
      );
      final text = result.text.trim();
      if (text.isEmpty) return null;
      final aiData = await LocalEntryAi.extract(text);
      return PaymentScreenshotData(
        text: text,
        amount: _amount(text),
        merchant: _merchant(text),
        attachmentPath: filePath,
        aiData: aiData,
      );
    } finally {
      await recognizer.close();
    }
  }

  static String _amount(String text) {
    final match = RegExp(
      r'(?:₹|rs\.?|inr)\s*([\d,]+(?:\.\d{1,2})?)|(?:amount|total|paid)\s*[:\-]?\s*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(text);
    return (match?.group(1) ?? match?.group(2) ?? '').replaceAll(',', '');
  }

  static String _merchant(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);
    for (final line in lines.take(8)) {
      final lower = line.toLowerCase();
      if (lower.contains('upi') ||
          lower.contains('transaction') ||
          lower.contains('reference') ||
          lower.contains('successful') ||
          lower.contains('paid') ||
          lower.contains('amount')) {
        continue;
      }
      if (RegExp(r'[a-zA-Z]').hasMatch(line)) return line;
    }
    return '';
  }
}
