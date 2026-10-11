# Later store assets

- `app-icon.png`: 512 × 512 PNG, exported from the supplied Later logo without changing its artwork.
- `feature-graphic.png`: 1024 × 500 RGB PNG. Editable source: `feature-graphic.svg`.
- `phone-01-overview.png`, `phone-02-things.png`, `phone-03-money.png`, `phone-04-reminders.png`: 1080 × 1920 RGB PNGs captured from the real Flutter UI on Android with isolated in-memory sample records.

Copies are available in `/Users/samireddynani/Downloads/Later-store-assets`.

To recapture screenshots with an Android emulator running:

```sh
flutter drive -d emulator-5554 --no-pub --keep-app-running --driver test_driver/store_screenshots_driver.dart --target integration_test/store_screenshots_test.dart
```

The capture uses an in-memory database and does not replace user records. Native captures may need an RGB PNG export before uploading. Launch the normal app after running the capture target. Store listing assets were staged in Play Console; Save as draft, Next, and submission were not clicked.
