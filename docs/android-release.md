# Later Android releases

Package: `com.nanisamireddy.later`. CI builds artifacts only; Play uploading and publication are **not configured**. No service account is required for the manual closed-testing plan below.

## Checks and builds

`.github/workflows/android.yml` runs release-policy tests, locked dependency resolution, formatting, analysis and Flutter tests on PRs, main pushes and every `android-v*` tag push. The separate signed build job requires all checks to pass. PR checks receive no signing secrets. Actions use full commit pins, checkout does not persist credentials, and the workflow token has only contents-read permission. Flutter 3.47.7 is pinned to commit `abaf9c523780a608bd46686fd5e53740a07077f8`, matching the local toolchain; Ubuntu supplies Java 17 and the Android SDK. CI overrides the local 8 GB Gradle heap with a 4 GB heap, 1 GB metaspace and two workers to fit smaller hosted runners. Upgrade pins deliberately together with the lockfile/toolchain.

Create the GitHub environment `android-release`, restrict deployment branches/tags to release tags, and restrict creation/deletion/updates of `android-v*` tags using repository rulesets. Only trusted maintainers may create release tags; signed builds execute the tagged repository code with signing secrets. Protect main and require the checks job before merging. Do not use `pull_request_target` for app checks.

## Immutable tag/version policy

Pattern: `android-vMAJOR.MINOR.PATCH[-rc.N]+VERSION_CODE`.
Examples: `android-v1.0.0-rc.1+2`, `android-v1.0.0-rc.2+3`, `android-v1.0.0+4`, `android-v1.0.1-rc.1+5`.

The suffix is an explicit Android versionCode, not a CI run number. The script validates canonical semver, positive candidate numbers and codes up to 2,100,000,000. Both semantic version and code must advance beyond every existing matching tag. Stable follows all candidates of the same version. All tracks share one code sequence; consult Play's highest previously uploaded code (including discarded releases) before reserving the next code. Git history cannot detect uploads made outside this policy. Never delete/move tags, reuse codes or concurrently reserve releases. A rerun uses the same code and bytes may differ: do not upload a replacement with a consumed code. Once later tags exist, older tag reruns intentionally fail the monotonicity guard.

Before tagging, on a reviewed main commit, run `python3 scripts/release/version.py 'android-v1.0.0-rc.1+2'`. Tags do not need a pubspec edit: CI overrides build-name and build-number together. Keep pubspec suitable for development. No tags or pushes were performed as part of setup.

Artifacts contain the signed universal APK, signed AAB and SHA256SUMS, retained for 30 days. Download and archive the exact tested artifacts and source commit in a durable release archive. CI verifies AAB signing, APK signatures, 16 KB ZIP alignment and all packaged 64-bit ELF load-segment alignments. Runtime testing on 16 KB devices remains required. Use AAB for Play; APK is for direct device smoke testing. Play signs installed APKs with its app-signing key, so the upload-signed standalone APK may not update a Play-installed app.

## Upload signing

Private local files are in `~/.local/share/later-signing/` (directory 0700, files 0600): `upload-keystore.jks`, `key.properties` and public `upload-certificate.pem`. The generated RSA 3072 key uses alias `upload`, a random strong password and neutral certificate subject `CN=Later Upload Key`. It does not claim a publisher identity. Generation refuses an existing directory and never overwrites keys. Never regenerate merely to fix a build. Before first Play upload, confirm whether this package already has a registered upload certificate; if it does, use that existing key or arrange an authorized upload-key reset.

Gradle reads `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, or the matching `storeFile`, `storePassword`, `keyAlias`, `keyPassword` properties in ignored `android/key.properties`. Environment values override local properties. Release tasks fail if credentials/file are missing; debug builds need no release credentials. For local validation without copying secrets, run `python3 scripts/release/validate_local.py --directory "$HOME/.local/share/later-signing" --java-home "/Applications/Android Studio.app/Contents/jbr/Contents/Home" --build-name 1.0.0-rc.1 --build-number 2` after reserving appropriate versions; it passes credentials only via environment and verifies both outputs. Alternatively copy the private properties to ignored `android/key.properties`, use normal Flutter release commands with both version overrides, and remove the copied file afterward. Do not display the properties in logs or terminals.

Create these **environment secrets** in `android-release`:

| Secret | Value |
| --- | --- |
| ANDROID_UPLOAD_KEYSTORE_BASE64 | Base64 encoding of private JKS bytes |
| ANDROID_KEYSTORE_PASSWORD | storePassword from private properties |
| ANDROID_KEY_ALIAS | upload |
| ANDROID_KEY_PASSWORD | keyPassword from private properties |

Add them through GitHub's environment secrets UI or authenticated `gh secret set --env android-release` over stdin. Do not put secret values in shell arguments, history, issue text, workflow files or chat. For the keystore, `base64 < "$HOME/.local/share/later-signing/upload-keystore.jks" | gh secret set ANDROID_UPLOAD_KEYSTORE_BASE64 --env android-release` sends the encoding directly without displaying it. The explicit helper `python3 scripts/release/set_github_secrets.py --directory "$HOME/.local/share/later-signing" --repo OWNER/REPOSITORY` sends all four secrets through stdin after you authenticate with `gh`. This command writes to GitHub: run it only when ready to configure that repository. Never use `cat` or `echo` to inspect credentials. Secrets have not been added remotely by this task.

Keep encrypted offline backups of the keystore and properties in at least two independent locations, record the certificate fingerprint and alias, and verify recovery. Restrict access to release maintainers. Play App Signing holds the app-signing key and signs distributed APKs; this local upload key authenticates AAB uploads. An upload-key reset is distinct from changing the app-signing key. Review Play's existing signing configuration before enrollment; prefer Google's app-signing key generation for a new app. Do not upload the private keystore to Play or repository artifacts.

## Closed testing first

1. In Play Console verify developer account, create/confirm this package, enroll in Play App Signing, and register the upload certificate. Complete store listing, screenshots/icon, support contact, privacy-policy URL, Data safety, content rating, target audience, ads declaration and app-access instructions. Review permissions, exact alarms/notifications, microphone/camera/photo access and all third-party SDK data behavior against the actual app. Supply account-specific declarations and publisher details yourself.
2. Verify current target API and native library compatibility, including Android 16 behavior and 16 KB page size on applicable devices. The pinned Flutter toolchain targets API 36; compile SDK 37 is already configured. Check the built manifest and Play pre-launch report, not merely this configuration.
3. Create a closed track (for example `closed-beta`), add a tester email list or Google Group, manually upload the CI AAB, add release notes, resolve Console validation and submit for review. Share the opt-in URL with authorized testers once available; installation is through that link rather than search. No tester invitations are sent by this setup.
4. Week 1: `1.0.0-rc.1` feature freeze, migration/backup/restore, reminders across reboot/timezones, notification denial, sharing, voice/model downloads, money/things flows and offline smoke tests on representative devices. Gather feedback and pre-launch reports.
5. Week 2: ship rc.2 only when needed, with the next reserved code; retest fixes and upgrades from rc.1. Maintain opt-in participation and meaningful tester feedback. Release at most one planned candidate each week; critical fixes can accelerate this cadence.
6. Production readiness: no known data-loss/blocking bugs, successful upgrade and regression checks, completed store declarations, reviewed crash/ANR feedback and account production access. Promote the exact tested AAB when supported by Console (no new code/build needed), or build stable `1.0.0` with a new code and smoke-test that artifact before submission. Tags alone never publish.
7. After launch: weekly triage, roughly fortnightly patch releases, monthly feature releases when ready. Start a small staged production rollout and expand based on observed health. Stop rollout on regressions; ship a corrective higher version/code. Rebuilding old code under a new code requires validation and a new patch version. Android does not allow downgrade as rollback.

For **personal developer accounts created after 13 November 2023**, current Play policy requires at least 12 testers continuously opted in for at least 14 days before applying for production access. This is account-specific, not a universal rule for every developer or every release. Account eligibility and the start of the continuous opt-in period must be confirmed in Console. Fourteen days alone does not guarantee production approval; answer the testing/readiness questions accurately. Calendar dates begin after the closed test is available and testers opt in, not on key generation or tag creation.

## Sources (verified 10 October 2026)

- [Flutter Android build/sign/version guidance](https://docs.flutter.dev/deployment/android)
- [Android signing and Play App Signing](https://developer.android.com/studio/publish/app-signing)
- [Android version codes and upper bound](https://developer.android.com/studio/publish/versioning)
- [Play target API requirements: new apps/updates target API 36 from 31 August 2026](https://developer.android.com/google/play/requirements/target-sdk)
- [Closed testing setup](https://support.google.com/googleplay/android-developer/answer/9845334)
- [New personal account testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465)
- [GitHub Actions security and immutable action pins](https://docs.github.com/en/actions/reference/security/secure-use)

- [Native 16 KB page-size compatibility and verification](https://developer.android.com/guide/practices/page-sizes)

## Release dependency notes

The first optimized release exposed optional missing classes in the installed OCR and MediaPipe plugins. `android/app/proguard-rules.pro` suppresses only the exact optional types reported by R8: non-Latin recognizer options (the app selects Latin exclusively), and unused MediaPipe graph profiling/template protos. Add real model dependencies before enabling other OCR scripts; do not broaden these rules to hide arbitrary missing classes. Smoke-test OCR and model inference on release devices before uploading. The pinned Flutter build also warns that file_picker, flutter_gemma and large_file_handler still apply the legacy Kotlin Gradle plugin; review compatible updates before upgrading Flutter. Shrinking remains enabled.

## Local validation completed

On 10 October 2026, signed `1.0.0-rc.1+2` AAB (~263 MB) and universal APK (~369 MB) built successfully from the shared working checkout after the narrow R8 rules above. These are validation builds, not a published/tagged release. AAB signature verification passed. APK verification passed, its signer matched the generated upload certificate, and package/version/target metadata matched `com.nanisamireddy.later`, `1.0.0-rc.1`, code 2 and API 36. APK ZIP alignment and all 29 packaged 64-bit ELF libraries passed 16 KB alignment checks. Release tasks without signing credentials failed with the intended actionable message; the debug task graph succeeded without credentials. Release-policy tests, Python syntax, workflow YAML/job-gate/action-pin checks and diff whitespace checks passed. SHA256 sums are in ignored `build/app/outputs/release-SHA256SUMS`.

The local build used Android Studio's bundled JDK; hosted Java 17 execution still needs its first real Actions run after secrets/configuration are installed. Play validation, per-device download-size limits, release-device OCR/model smoke tests, Console declarations, tester opt-in and publication have not been performed. Preserve the user's existing working changes; review and commit through the normal project process before creating any release tag.
