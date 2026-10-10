import 'local_ai_service.dart';
import 'local_entry_data.dart';
export 'local_entry_data.dart';

/// Compatibility facade. A null result means capture should retain its reliable
/// OCR/manual fallback; callers must review extracted fields before saving.
class LocalEntryAi {
  static Future<LocalEntryData?> extract(String input) =>
      LocalAiService.instance.extract(input);

  static Future<String?> normalize(String input) async {
    final result = await extract(input);
    if (result == null) return null;
    return result.description.isEmpty ? input.trim() : result.description;
  }
}
