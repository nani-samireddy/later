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

## First milestone

The manual-entry milestone is tracked in [MILESTONE.md](MILESTONE.md).
Things support persistent editing and deletion. Money totals are grouped by currency,
exclude settled debts, and keep spending separate. Reminders preserve the selected
local date and time and are cancelled when removed, settled, or deleted. Attachments
are copied into private app storage, with image previews and external document opening.

Run both Android end-to-end checks on a connected emulator with a PDF viewer installed:

```sh
python3 tool/verify_android.py --device emulator-5554
```

This check creates a temporary item, edits it, reopens a copied image after deleting
its source, verifies native reminder registration and settlement cancellation,
restarts the app widget tree, and deletes the test records. The extended check also
verifies money validation/editing/settlement, actual notification delivery and tap
navigation, PDF opening, and missing-file feedback. The runner grants the test app
notification/exact-alarm permissions and performs the Android system UI steps.
Unit tests also cover
SQLite reopen persistence, migration, validation, currency totals, timezone conversion,
and rollback when an attachment cannot be copied.

Android notification and exact-alarm permissions control reminder delivery. The app
requests these permissions through the reminder flow. Document opening requires an
installed viewer for the selected file type.

## Adding an item

Choose **Thing** or **Money**, enter a title, and optionally add a description,
attachments, or a reminder. Money entries add only an amount and a choice of
**I spent money**, **Someone owes me**, or **I owe someone**. For debts, use the
person’s name as the title; for spending, use a purchase or merchant. Thing
descriptions are stored separately and can be edited from the item details.

The Android application ID and iOS bundle identifier are `com.nanisamireddy.later`.


## Feature tasks and verification

See [TASKS.md](TASKS.md) for the eleven feature tasks, acceptance checks, and platform limitations. Quick Add includes reviewed voice input and **Take photo**; recurring reminders, archive, repayment history, filters, and local backup are connected to their screens. Settings controls the default reminder time and optional local AI model.

```sh
flutter analyze
flutter test
python3 tool/verify_android.py --device emulator-5554
python3 tool/verify_camera_android.py
python3 tool/verify_backup_android.py
python3 tool/verify_cold_share_android.py # Requires the normal app installed.
flutter test -d emulator-5554 --no-pub --no-uninstall integration_test/payment_ocr_test.dart
```

The separate React landing site and branch-based GitHub Pages workflow are documented in [website/README.md](website/README.md).
