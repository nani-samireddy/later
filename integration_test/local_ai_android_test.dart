// Opt-in device test: stage the SHA256-verified pinned artifact at
// /data/local/tmp/Qwen3-0.6B.litertlm, then run:
// flutter test -d emulator-5554 --dart-define=LATER_AI_NATIVE=true integration_test/local_ai_android_test.dart
// Exercises only AI APIs, creates no database entries, and removes its own
// temporary installation metadata and copied test model. Never run concurrently with native QA.
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:later/core/ai/local_ai_runtime.dart';
import 'package:later/core/ai/local_ai_service.dart';

void main() {
  const enabled = bool.fromEnvironment('LATER_AI_NATIVE');
  if (enabled) IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'pinned Qwen3 Android CPU model executes readiness and debt extraction',
    (tester) async {
      await FlutterGemma.initialize(maxDownloadRetries: 1);
      final wasInstalled = await FlutterGemma.isModelInstalled(
        LocalAiModel.filename,
      );
      final service = LocalAiService(
        inferenceTimeout: const Duration(seconds: 90),
      );
      File? copiedModel;
      try {
        if (!wasInstalled) {
          final documents = await getApplicationDocumentsDirectory();
          final target = File('${documents.path}/${LocalAiModel.filename}');
          if (await target.exists()) {
            throw StateError(
              'An unregistered model already exists; refusing to replace it.',
            );
          }
          copiedModel = await File('/data/local/tmp/${LocalAiModel.filename}')
              .copy(target.path);
          expect(await copiedModel.length(), LocalAiModel.bytes);
          await FlutterGemma.installModel(modelType: ModelType.qwen)
              .fromFile(copiedModel.path)
              .install();
        }
        await service.verify();
        expect(
          service.status,
          LocalAiStatus.ready,
          reason: '${service.message}; ${service.lastError}',
        );
        for (final sample in [
          ('I owe Ravi 500 rupees for a loan.', 'iOwe'),
          ('Ravi owes me 500 rupees for a loan.', 'owedToMe'),
          ('I spent 500 rupees on groceries.', 'spending'),
          ('Remember to buy milk tomorrow.', 'thing'),
        ]) {
          final result = await service.extract(sample.$1);
          expect(
            result,
            isNotNull,
            reason: '${service.message}; ${service.lastError}',
          );
          expect(result!.kind, sample.$2);
          if (sample.$2 != 'thing') expect(result.amount, '500');
        }
      } finally {
        service.dispose();
        if (!wasInstalled &&
            await FlutterGemma.isModelInstalled(LocalAiModel.filename)) {
          await FlutterGemma.uninstallModel(LocalAiModel.filename);
        }
        if (copiedModel != null && await copiedModel.exists()) {
          await copiedModel.delete();
        }
      }
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 8)),
  );
}
