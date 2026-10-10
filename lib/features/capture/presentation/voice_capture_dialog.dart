import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/speech/sherpa_speech_service.dart';
import '../../../core/speech/voice_capture_controller.dart';

/// Applies only explicitly reviewed text. Does not parse money or save entries.
/// The caller can place the returned text in its editable title field.
Future<void> showVoiceCaptureDialog(
  BuildContext context, {
  required ValueChanged<String> onApply,
  String initialText = '',
  SpeechSession Function()? sessionFactory,
}) async {
  final controller = VoiceCaptureController(
    session: sessionFactory?.call(),
    initialText: initialText,
  );
  final text = await showDialog<String>(
    context: context,
    builder: (_) => VoiceCaptureDialog(controller: controller),
  );
  if (text != null && text.trim().isNotEmpty) onApply(text.trim());
}

class VoiceCaptureDialog extends StatefulWidget {
  const VoiceCaptureDialog({super.key, required this.controller});

  /// The dialog owns and disposes this controller.
  final VoiceCaptureController controller;
  @override
  State<VoiceCaptureDialog> createState() => _VoiceCaptureDialogState();
}

class _VoiceCaptureDialogState extends State<VoiceCaptureDialog>
    with WidgetsBindingObserver {
  late final TextEditingController _text;
  bool _closing = false;
  VoiceCaptureController get voice => widget.controller;
  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: voice.text);
    voice.addListener(_update);
    WidgetsBinding.instance.addObserver(this);
  }

  void _update() {
    if (!mounted) return;
    if (_text.text != voice.text) {
      _text.value = TextEditingValue(
        text: voice.text,
        selection: TextSelection.collapsed(offset: voice.text.length),
      );
    }
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.inactive &&
            voice.phase == VoiceCapturePhase.listening) ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(voice.stop());
    }
  }

  Future<void> _close([String? result]) async {
    if (_closing) return;
    setState(() {
      _closing = true;
    });
    try {
      await voice.close();
    } catch (_) {
      /* All resources were released in finally blocks. */
    }
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    voice.removeListener(_update);
    voice.dispose();
    _text.dispose();
    super.dispose();
  }

  String get _status => switch (voice.phase) {
    VoiceCapturePhase.ready => 'Ready to record',
    VoiceCapturePhase.requestingPermission =>
      'Checking microphone and preparing voice…',
    VoiceCapturePhase.downloading => 'Downloading English voice model…',
    VoiceCapturePhase.listening =>
      voice.heardSound
          ? 'Listening — microphone sound detected'
          : 'Listening — speak into your microphone',
    VoiceCapturePhase.stopping => 'Stopping voice capture…',
    VoiceCapturePhase.review =>
      voice.text.trim().isEmpty
          ? 'No speech captured. Try again or type below.'
          : 'Review and edit your words',
    VoiceCapturePhase.error => 'Voice capture needs attention',
  };

  @override
  Widget build(BuildContext context) {
    final progress = voice.progress;
    return PopScope(
      canPop: !_closing,
      child: AlertDialog(
        title: const Text('Voice capture'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'English, on-device recognition. First use downloads a 44 MB model. Your audio stays on this device.',
                ),
                const SizedBox(height: 16),
                Semantics(liveRegion: true, child: Text(_status)),
                if (voice.phase == VoiceCapturePhase.downloading) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress?.fraction),
                  if (progress != null)
                    Text(
                      '${(progress.fraction * 100).round()}% · ${(progress.receivedBytes / 1000000).toStringAsFixed(1)} / ${(progress.totalBytes / 1000000).toStringAsFixed(1)} MB',
                    ),
                ],
                if (voice.phase == VoiceCapturePhase.listening) ...[
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Microphone input level',
                    child: LinearProgressIndicator(value: voice.level),
                  ),
                  if (!voice.heardSound)
                    const Text(
                      'If this stays quiet, check microphone access and your input device.',
                    ),
                ],
                if (voice.error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    voice.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _text,
                  readOnly: voice.active || _closing,
                  minLines: 3,
                  maxLines: 6,
                  onChanged: voice.edit,
                  decoration: const InputDecoration(
                    labelText: 'Text to use',
                    hintText: 'Speak or type your entry',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check names, amounts and dates before using this text. You will still review and save the entry yourself.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (voice.active)
            OutlinedButton.icon(
              onPressed: _closing || voice.phase == VoiceCapturePhase.stopping
                  ? null
                  : voice.stop,
              icon: const Icon(Icons.stop),
              label: Text(
                voice.phase == VoiceCapturePhase.listening
                    ? 'Stop and review'
                    : 'Cancel preparation',
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _closing ? null : voice.start,
              icon: const Icon(Icons.mic),
              label: Text(
                voice.phase == VoiceCapturePhase.error
                    ? 'Retry voice capture'
                    : voice.text.isEmpty
                    ? 'Start listening'
                    : 'Record again',
              ),
            ),

          TextButton(
            onPressed: _closing ? null : () => _close(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: !_closing && voice.canApply
                ? () => _close(voice.text.trim())
                : null,
            child: const Text('Use text'),
          ),
        ],
      ),
    );
  }
}
