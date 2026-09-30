import 'dart:convert';

import 'package:flutter_gemma/flutter_gemma.dart';

class LocalEntryData {
  final String kind;
  final String person;
  final String amount;
  final String description;

  const LocalEntryData({
    required this.kind,
    required this.person,
    required this.amount,
    required this.description,
  });
}

class LocalEntryAi {
  static const modelAsset = 'assets/models/qwen3_0.6b.litertlm';
  static Future<dynamic>? _modelFuture;

  static Future<dynamic> _model() => _modelFuture ??= _installAndLoadModel();

  static Future<dynamic> _installAndLoadModel() async {
    await FlutterGemma.installModel(modelType: ModelType.qwen)
        .fromAsset(modelAsset)
        .install();
    return FlutterGemma.getActiveModel(maxTokens: 256);
  }

  static Future<LocalEntryData?> extract(String input) async {
    if (input.trim().isEmpty) return null;
    try {
      final model = await _model();
      final chat = await model.createChat();
      await chat.addQueryChunk(
        Message.text(
          text: '''Extract a Later app entry from this OCR or spoken text.
Return only valid JSON with exactly these string keys:
{"kind":"thing|owedToMe|owedByMe|spending","person":"","amount":"","description":""}
Rules: preserve names and amounts, use only digits and decimal point in amount, use spending for a payment or purchase, and use empty strings when unknown.
Input:
$input''',
          isUser: true,
        ),
      );
      final response = await chat.generateChatResponse();
      if (response is! TextResponse) return null;
      return _parse(response.token);
    } catch (_) {
      _modelFuture = null;
      return null;
    }
  }

  static Future<String?> normalize(String input) async {
    final result = await extract(input);
    if (result == null) return null;
    return result.description.isEmpty ? input.trim() : result.description;
  }

  static LocalEntryData? _parse(String value) {
    final start = value.indexOf('{');
    final end = value.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      final json = jsonDecode(value.substring(start, end + 1));
      if (json is! Map) return null;
      final kind = '${json['kind'] ?? ''}';
      const validKinds = {'thing', 'owedToMe', 'owedByMe', 'spending'};
      return LocalEntryData(
        kind: validKinds.contains(kind) ? kind : 'thing',
        person: '${json['person'] ?? ''}'.trim(),
        amount: _number('${json['amount'] ?? ''}'),
        description: '${json['description'] ?? ''}'.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  static String _number(String value) {
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(value);
    return match?.group(0) ?? '';
  }
}
