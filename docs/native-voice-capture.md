# Legacy Android speech adapter

The default voice flow has moved to Gemini streaming. See [gemini-live-voice.md](gemini-live-voice.md). This document describes the retained native adapter for comparison and tests; it is not the current default.

# Android native voice capture

Android voice capture uses `android.speech.SpeechRecognizer` through `later/speech`.
Other platforms retain the existing local Sherpa implementation.

## Behavior

- On-device recognition is the default. Android 12+ must expose an on-device recognizer and the selected language must be supported/installed.
- On Android 13+, “Check language packs” queries the installed, pending and downloadable languages reported by the recognition provider. “Download selected language” explicitly requests an Android-managed model download. Scheduled/requested is not installed; users recheck readiness before retrying. Unsupported providers and older Android versions show an actionable fallback. Pack requests do not record microphone audio.
- English (India), English (US), Telugu and Hindi are selectable requests, not guarantees that a device has each language pack. Change language while paused, then resume.
- “Allow online recognition” explicitly selects Android’s default speech service, which may send microphone audio to the provider. It is off for each new capture; there is no silent fallback.
- Partial hypotheses replace the current utterance. Final utterances are appended once. Pause/resume retains earlier text and manual edits.
- Natural utterance completion starts the next foreground dictation turn after a short delay. Two consecutive silence/no-match turns pause capture with an actionable message. This is short note dictation, not indefinite accessibility captioning.
- Stop waits up to two seconds for final results. If no final arrives, the last partial is retained. Cancellation, backgrounding, activity teardown and route dismissal release recognition resources.
- The microphone is owned by Android’s recognition service. No Sherpa speech model download is needed on Android. Later stores reviewed text, not an audio recording.

## Verification

Automated bridge/controller/UI tests cover partial replacement, final retention, stale callback rejection, permission cancellation and denial, explicit online selection, manual review and route/background cleanup. A debug APK must compile the Kotlin bridge. Automated tests do not establish speech accuracy.

On a physical device, check live partials and final text for the chosen language, pauses between sentences, stop/resume, noise, network-off on-device mode, an unavailable language, online mode only after explicit opt-in, backgrounding and microphone release. Confirm no duplicate sentences after a pause. Record latency and transcription errors before claiming accuracy improvements.
