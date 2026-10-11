# Continuous voice capture

Voice uses Gemini `gemini-3.5-transcribe-live`, with explicit per-screen consent.
One 16 kHz mono PCM16 microphone stream feeds a WebSocket. Sentence pauses do
not restart the microphone or socket. Interim hypotheses replace tentative text;
final segments append. Stop sends `audioStreamEnd`, waits up to three seconds for
final text, and retains the latest partial if no final arrives. Connection loss
retains the draft and requires an explicit resume, avoiding silently lost audio.
Automatic language detection is enabled. Sessions stop after five minutes.

## Deployed endpoint

Worker: https://later-voice-token.later-voice-token.workers.dev
Token endpoint: https://later-voice-token.later-voice-token.workers.dev/token
Health endpoint responds successfully. `GEMINI_API_KEY` is configured.
The tester-code gate has been removed from the app and Worker. Production token issuance and Gemini
WebSocket setup acknowledgment were verified on 11 October 2026. The GitHub
repository variable `VOICE_TOKEN_URL` is configured; the debug build with this
endpoint is installed on the Pixel 6a. A generated English speech sample produced eight interim updates and both
expected final sentences ("Remember to buy milk tomorrow. Call Alex on Monday.")
across a five-second silence on the same connection. This verifies the deployed
cloud path, not Pixel microphone or Indian-accent accuracy; those remain to be
verified.

## Cloudflare setup

Worker source: `services/voice-token`. It never receives audio or notes.

1. `cd services/voice-token && npm ci && npm test && npm run check`
2. `npx wrangler login`
3. `npx wrangler secret put GEMINI_API_KEY` (enter privately at the prompt)
5. `npm run deploy`
6. Build Flutter with `--dart-define=VOICE_TOKEN_URL=https://later-voice-token.YOUR-SUBDOMAIN.workers.dev/token`.

For GitHub release builds, set the repository variable `VOICE_TOKEN_URL` to the same HTTPS `/token` URL. The Android workflow includes this nonsecret URL in both artifacts.

API keys must never appear in Dart defines, app assets, source, or chat. The
nonsecret Worker URL may be embedded. The token endpoint accepts public requests
without a tester access code; microphone consent remains explicit.

Worker tokens are single-use, with one minute to connect and six minutes until
expiry, locked to the transcription model/configuration. Missing secrets fail
closed. Cloudflare rate limits are permissive and per location: 20 requests per
minute per IP, and three successful token requests per minute
across callers. These limits and the app timer are not a global
billing cap. Set provider quotas and monitor billed usage; budget alerts alone
are notifications. Free-tier and paid-tier Google data policies differ. The
website privacy policy now describes Google and Cloudflare processing.

## Validation

Run `flutter test test/gemini_speech_service_test.dart test/voice_capture_controller_test.dart test/voice_capture_dialog_test.dart`.
The socket test verifies real local WebSocket setup, interim replacement, final
retention, PCM byte boundaries, and continued microphone capture after sentence
finalization. It does not establish Google recognition accuracy.

After secrets/deployment, test on Pixel: long sentence, five-second pause and
second sentence; English/Indian accent, Telugu and mixed language; cancel during
connection; stop while speaking; backgrounding; Wi-Fi loss and explicit resume;
confirm microphone indicator turns off. Record live latency and errors before
claiming accuracy. Never log tokens, credentials, audio, or private transcripts.

The production Dart networking path was separately verified against the deployed
Worker and Gemini after correcting the socket URL scheme to `wss`. A regression
test now checks the production scheme and ephemeral-token encoding, since the
local socket tests inject their own connection and did not cover that URL.

Done stops capture and forwards its final transcript directly to editing,
without a second Use text step. The note title starts with the first 50 Unicode
characters of the transcript (preserving complete emoji); its body retains the
whole transcript. Both remain editable.
