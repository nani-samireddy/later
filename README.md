# Later

A Flutter app for keeping track of things, money, and upcoming reminders.

## Code structure

- `lib/main.dart`: platform and plugin initialization.
- `lib/app/`: app composition and theme selection.
- `lib/core/`: shared database, AI, notifications, payment intake, speech, utilities, and reusable widgets.
- `lib/features/<feature>/domain/`: feature models.
- `lib/features/<feature>/data/`: persistence and application services.
- `lib/features/<feature>/presentation/`: screens, dialogs, and feature widgets.

The home screen owns its database and coordinates navigation and refreshes. It delegates loading to `HomeRepository`, entry creation to `EntryCaptureService`, and shared payment intake to `SharedPaymentService`. Presentation files use explicit imports rather than sharing a library through `part` declarations. Database generated code remains a Drift `part` file.

Keep reusable UI in `core/widgets`; keep feature-specific UI beside its feature. Put persistence and plugin integration in repositories or services rather than expanding screens.

## Local development

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

The AI model `assets/models/qwen3_0.6b.litertlm` is optional. Place it in
`assets/models/` and rebuild to enable local AI extraction. Without it, entry
creation and payment OCR remain available using the existing parsing fallback.

Android builds use compile SDK 37.0. The project corrects the sharing plugin's
API 37 declaration to include minor API level 0, matching the published SDK.
