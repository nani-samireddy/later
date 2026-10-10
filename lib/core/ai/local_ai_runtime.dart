import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

/// The original INT8 export used by flutter_gemma 0.12.6's own example.
/// Newer INT4 exports need newer LiteRT-LM runtimes and are deliberately excluded.
class LocalAiModel {
  static const filename = 'Qwen3-0.6B.litertlm';
  static const revision = 'a3c5d805ae362dff7f580bc25f2dfb9a5a7eaa76';
  static const bytes = 614236160;
  static const url =
      'https://huggingface.co/litert-community/Qwen3-0.6B/resolve/$revision/$filename';
  static const license = 'Apache 2.0';
}

abstract interface class LocalAiRuntime {
  bool get supported;
  Future<bool> isInstalled();
  Future<void> remove();
  Future<void> install(CancelToken cancellation, void Function(int) progress);
  Future<String> generate(String prompt, CancelToken cancellation);
}

class GemmaLocalAiRuntime implements LocalAiRuntime {
  // iOS 0.12.6 uses MediaPipe, not LiteRT-LM. Web needs separate JS setup.
  @override
  bool get supported =>
      !kIsWeb &&
      {
        TargetPlatform.android,
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      }.contains(defaultTargetPlatform);

  @override
  Future<bool> isInstalled() =>
      FlutterGemma.isModelInstalled(LocalAiModel.filename);

  @override
  Future<void> remove() async {
    if (await isInstalled()) {
      await FlutterGemma.uninstallModel(LocalAiModel.filename);
    }
  }

  @override
  Future<void> install(
    CancelToken cancellation,
    void Function(int) progress,
  ) async {
    await FlutterGemma.installModel(modelType: ModelType.qwen)
        .fromNetwork(LocalAiModel.url, foreground: false)
        .withCancelToken(cancellation)
        .withProgress(progress)
        .install();
  }

  @override
  Future<String> generate(String prompt, CancelToken cancellation) async {
    InferenceModel? model;
    InferenceChat? chat;
    StreamSubscription<void>? cancellationListener;
    try {
      cancellation.throwIfCancelled();
      // Idempotent install restores active model metadata after an app restart.
      // The caller first checks isInstalled: extraction never starts a download.
      await install(cancellation, (_) {});
      model = await FlutterGemma.getActiveModel(
        maxTokens: 2048,
        preferredBackend: PreferredBackend.cpu,
      );
      cancellation.throwIfCancelled();
      chat = await model.createChat(
        temperature: 0,
        topK: 1,
        modelType: ModelType.qwen,
        isThinking: false,
      );
      final session = chat.session;
      cancellationListener = cancellation.whenCancelled.asStream().listen((_) {
        unawaited(session.stopGeneration().catchError((Object _) {}));
      });
      if (await session.sizeInTokens(prompt) > 1536) {
        throw const FormatException('Input exceeds context budget');
      }
      await chat.addQueryChunk(Message.text(text: prompt, isUser: true));
      cancellation.throwIfCancelled();
      final output = StringBuffer();
      await for (final response in chat.generateChatResponseAsync()) {
        cancellation.throwIfCancelled();
        if (response is! TextResponse) {
          throw const FormatException('Non-text output');
        }
        output.write(response.token);
        if (output.length > 4096) {
          await session.stopGeneration();
          throw const FormatException('Output too long');
        }
      }
      return output.toString();
    } finally {
      await cancellationListener?.cancel();
      // Keep the service lock until native cleanup actually settles. The service
      // already bounds the caller wait even if cleanup hangs.
      try {
        await model?.close();
      } catch (_) {}
    }
  }
}
