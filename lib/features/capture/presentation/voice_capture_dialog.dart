import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/speech/sherpa_speech_service.dart';
import '../../../core/speech/voice_capture_controller.dart';

/// Done returns the final transcript to the caller for editing.
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
  final text = await Navigator.of(context).push<String>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => VoiceCaptureDialog(controller: controller),
    ),
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
  bool _finishing = false;
  bool _checkingPack = false;
  String? _packStatus;
  VoiceCaptureController get voice => widget.controller;
  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: voice.text);
    voice.addListener(_update);
    WidgetsBinding.instance.addObserver(this);
    if (voice.cloudSession == null) unawaited(voice.start());
  }

  Future<void> _checkPack({bool download = false}) async {
    final native = voice.nativeSession;
    if (native == null || voice.active || _checkingPack || _closing) return;
    setState(() => _checkingPack = true);
    try {
      final result = await native.languageSupport(download: download);
      if (!mounted) return;
      String status;
      if (result['status'] == 'checked') {
        final installed = List<String>.from(result['installed'] as List? ?? []);
        final pending = List<String>.from(result['pending'] as List? ?? []);
        final supported = List<String>.from(result['supported'] as List? ?? []);
        bool contains(List<String> values) => values.any(
          (value) =>
              value.toLowerCase().replaceAll('_', '-') ==
              native.language.toLowerCase(),
        );
        status = contains(installed)
            ? 'Language pack ready. Tap the microphone to retry.'
            : contains(pending)
            ? 'Download pending. Check again when it finishes.'
            : contains(supported)
            ? 'This language pack is available to download.'
            : 'This language is not reported as supported on-device.';
        if (installed.isNotEmpty) {
          status += ' Installed: ${installed.join(', ')}.';
        }
      } else {
        status = switch (result['status']) {
          'installed' =>
            'Language pack installed. Tap the microphone to retry.',
          'scheduled' || 'requested' => 'Download requested from Android. Check packs again to confirm it is ready.',
          _ =>
            result['message'] as String? ??
                'Language pack status is unavailable.',
        };
      }
      setState(() => _packStatus = status);
    } catch (_) {
      if (mounted) {
        setState(
          () => _packStatus = 'Could not check Android speech packs. Choose another language or allow online recognition.',
        );
      }
    } finally {
      if (mounted) setState(() => _checkingPack = false);
    }
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

  Future<void> _done() async {
    if (_finishing || _closing) return;
    setState(() => _finishing = true);
    await voice.stop();
    if (!mounted || _closing) return;
    final text = voice.text.trim();
    if (text.isNotEmpty) {
      await _close(text);
    } else {
      setState(() => _finishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final preparing =
        voice.phase == VoiceCapturePhase.requestingPermission ||
        voice.phase == VoiceCapturePhase.downloading ||
        voice.phase == VoiceCapturePhase.stopping;
    final listening = voice.phase == VoiceCapturePhase.listening;
    final progress = voice.progress;
    final minimumHeight =
        (voice.nativeSession != null || voice.cloudSession != null) &&
            !voice.active
        ? 900.0
        : 620.0;
    return PopScope(
      canPop: !_closing,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.surface, colors.surface, colors.primaryContainer],
              stops: const [0, .75, 1],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: SizedBox(
                  height: constraints.maxHeight < minimumHeight
                      ? minimumHeight
                      : constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.graphic_eq, color: colors.primary),
                            const SizedBox(width: 10),
                            Text(
                              'Voice capture',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(width: 10),
                            Chip(
                              label: Text(
                                listening
                                    ? 'Live'
                                    : voice.cloudSession != null
                                    ? 'Gemini Live'
                                    : voice.nativeSession?.allowOnline == true
                                    ? 'System service'
                                    : 'On device',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (voice.cloudSession != null) ...[
                          const Text(
                            'Live transcription · Audio is sent to Google. Internet required. Sessions last up to 5 minutes.',
                            textAlign: TextAlign.center,
                          ),
                          if (!voice.active) ...[
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Allow Google to process my audio for this capture',
                              ),
                              value: voice.cloudSession!.consent,
                              onChanged: _closing
                                  ? null
                                  : (value) => setState(
                                      () => voice.cloudSession!.consent =
                                          value ?? false,
                                    ),
                            ),
                          ],
                        ] else if (voice.nativeSession != null) ...[
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            children: [
                              DropdownButton<String>(
                                isExpanded: true,
                                value: voice.nativeSession!.language,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'en-IN',
                                    child: Text('English (India)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'en-US',
                                    child: Text('English (US)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'te-IN',
                                    child: Text('Telugu'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'hi-IN',
                                    child: Text('Hindi'),
                                  ),
                                ],
                                onChanged:
                                    voice.active || _closing || _checkingPack
                                    ? null
                                    : (value) {
                                        setState(() => _packStatus = null);
                                        voice.configureNative(language: value);
                                      },
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Flexible(
                                    child: Text('Allow online recognition'),
                                  ),
                                  Switch(
                                    value: voice.nativeSession!.allowOnline,
                                    onChanged:
                                        voice.active ||
                                            _closing ||
                                            _checkingPack
                                        ? null
                                        : (value) => voice.configureNative(
                                            allowOnline: value,
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            voice.nativeSession!.allowOnline
                                ? 'Android’s speech service may send audio online.'
                                : 'On-device recognition · Language pack required',
                            textAlign: TextAlign.center,
                          ),
                        ] else
                          const Text(
                            'English · Audio stays on this device',
                            textAlign: TextAlign.center,
                          ),
                        if (voice.nativeSession != null &&
                            !voice.active &&
                            !voice.nativeSession!.allowOnline) ...[
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              TextButton(
                                onPressed: _checkingPack
                                    ? null
                                    : () => _checkPack(),
                                child: const Text('Check language packs'),
                              ),
                              TextButton(
                                onPressed: _checkingPack
                                    ? null
                                    : () => _checkPack(download: true),
                                child: const Text('Download selected language'),
                              ),
                            ],
                          ),
                          if (_checkingPack) const LinearProgressIndicator(),
                          if (_packStatus != null)
                            Text(_packStatus!, textAlign: TextAlign.center),
                        ],
                        const SizedBox(height: 24),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 680),
                              child: TextField(
                                controller: _text,
                                readOnly: voice.active || _closing,
                                expands: true,
                                minLines: null,
                                maxLines: null,
                                textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  height: 1.5,
                                  color: colors.onSurface,
                                ),
                                onChanged: voice.edit,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: listening
                                      ? 'Start talking.\nYour words will appear here.'
                                      : 'Speak or type your entry',
                                  hintStyle: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 28,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          liveRegion: true,
                          child: Text(_status, textAlign: TextAlign.center),
                        ),
                        if (preparing) ...[
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: voice.phase == VoiceCapturePhase.downloading
                                ? progress?.fraction
                                : null,
                          ),
                          if (voice.phase == VoiceCapturePhase.downloading) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'First use downloads a 44 MB model. After that, voice works offline.',
                              textAlign: TextAlign.center,
                            ),
                            if (progress != null)
                              Text('${(progress.fraction * 100).round()}%'),
                          ],
                        ],
                        if (listening) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 120,
                            child: Semantics(
                              label: 'Microphone input level',
                              child: LinearProgressIndicator(
                                value: voice.level,
                              ),
                            ),
                          ),
                        ],
                        if (voice.error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            voice.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.error),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          'Tap Done to continue editing your note.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton.filledTonal(
                              tooltip: listening
                                  ? 'Pause microphone'
                                  : preparing
                                  ? 'Cancel preparation'
                                  : voice.phase == VoiceCapturePhase.error
                                  ? 'Retry voice capture'
                                  : 'Resume microphone',
                              iconSize: 30,
                              padding: const EdgeInsets.all(16),
                              onPressed:
                                  _closing ||
                                      _checkingPack ||
                                      voice.phase == VoiceCapturePhase.stopping
                                  ? null
                                  : voice.active
                                  ? voice.stop
                                  : () {
                                      unawaited(voice.start());
                                    },
                              icon: Icon(
                                listening
                                    ? Icons.mic
                                    : preparing
                                    ? Icons.stop
                                    : Icons.mic_off_outlined,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 22,
                                ),
                              ),
                              onPressed:
                                  _closing ||
                                      _finishing ||
                                      preparing ||
                                      voice.text.trim().isEmpty
                                  ? null
                                  : _done,
                              child: const Text('Done'),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              tooltip: 'Cancel',
                              padding: const EdgeInsets.all(16),
                              iconSize: 30,
                              onPressed: _closing ? null : () => _close(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
