# First milestone: dependable manual entry

Tasks are completed in order; each includes targeted verification.

- [x] 1. Reliable records: persistent thing edits and deletion, record identity, saved icons/attachments, refresh after changes, honest empty states.
- [x] 2. Money tracking: settlement-aware totals grouped by currency, separate spending, finite positive amounts, edit/delete refresh.
- [x] 3. Reminders: thing and money scheduling, local timezone and exact chosen time, cancellation/rescheduling, past dates, navigation from cards/notifications.
- [x] 4. Durable attachments: private file copies, persisted metadata, opening/removal, missing-file feedback, cleanup on record deletion.
- [x] Static analysis and regression tests: `flutter analyze` clean; all 19 tests pass.
- [x] Android debug build.
- [x] Emulator end-to-end verification: record create/edit/delete, image opening after source deletion, fresh app widget-tree/database restart, native reminder registration and settlement cancellation.
- [x] Full Android process restart: saved record survives force-stop/relaunch, opens normally, and can be deleted.
- [x] Extended Android verification: invalid money input, money editing/settlement/deletion, actual scheduled notification delivery, notification-tap navigation, private PDF opening in Android's viewer, missing-file feedback, and attachment/notification cleanup.


## Verification scope

Automated coverage includes persisted SQLite edits and reopen, child-row deletion,
attachment copies surviving source deletion and database reopen, schema migration,
failed-copy rollback, currency-separated totals, validation, reminder scheduling and
cancellation, local timezone conversion, and graceful native notification errors/timeouts. Plugin startup waits are bounded so manual entry can start when a plugin stalls.

Verified on 2026-10-10 using Android 16 / API 36, `emulator-5554`.
`integration_test/milestone_test.dart` covers the main persistence workflow.
`integration_test/native_verification_test.dart` covers money UI, delivered
notifications, and document viewing. The PDF page was also visually checked in
Android's PDF viewer after its original source file had been deleted.

Run both checks, including Android notification taps and returning from the PDF
viewer, with:

```sh
python3 tool/verify_android.py --device emulator-5554
```

The runner grants notification and exact-alarm permission to the test app on
Android versions that require them. It expects a PDF viewer installed on the
device. Test-created records, attachments, and notifications are cleaned up.

Verification covers the Android emulator. Physical devices and iOS are outside
this milestone's verified platform scope.
