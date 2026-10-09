import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/ai/local_entry_ai.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Missing optional model leaves extraction available to fallbacks',
    () async {
      expect(await LocalEntryAi.extract('Paid INR 500 to Ravi'), isNull);
      expect(await LocalEntryAi.extract('Paid INR 600 to Priya'), isNull);
      expect(await LocalEntryAi.normalize('remember this'), isNull);
    },
  );
}
