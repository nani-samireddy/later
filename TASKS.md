# Feature completion tasks

Core manual entry is complete. Preserve the simple Thing/Money Add form.
Each of the eleven tasks has its own Codex chat; implementation is coordinated to avoid conflicting
schema edits and competing emulator sessions. A task is complete only after its
acceptance checks pass; hardware/runtime limitations are recorded explicitly.

## 1. Completion and archive — implemented; targeted checks passed
- Persist active/completed/archived state with a compatible migration.
- Mark done/reopen and archive/unarchive from item details.
- Provide status/history views and refresh lists after transitions.
- Cancel reminders for inactive things; restore valid reminders when reopened.
- Verify state survives reopen, attachments/descriptions remain, and upcoming respects status.

## 2. Recurring and overdue reminders — implemented; combined regression checks passed
- Persist daily/weekly/monthly recurrence and snooze changes.
- Add compact recurrence controls, snooze actions, and overdue sections.
- Preserve local time and 9 AM initial default; handle monthly boundaries.
- Reschedule across edits/relaunch and cancel on completion/settlement/deletion.
- Verify calculations and native delivery/navigation without duplicate notifications.

## 3. Search filters and sorting — implemented; combined regression checks passed
- Include descriptions in search.
- Filter things by category/status and money by type/settlement/date.
- Add useful sorting and combined-filter empty states.
- Verify results, refresh after edits, and navigation.

## 4. Partial repayments and spending history — implemented; combined regression checks passed
- Persist repayment events and calculate remaining debt balances.
- Add/update/delete repayments; reject invalid/overpaid amounts.
- Integrate settlement, totals and reminder behavior.
- Show spending by month with currency-separated summaries.
- Verify migrations, corrections, totals and history persistence.

## 5. Local backup and restore — implemented; combined regression checks passed
- Export a versioned archive with records/settings/reminders/repayments/attachments.
- Validate versions, paths and attachment integrity before import.
- Preview and confirm replacement; restore atomically with rollback on failure.
- Rebuild notifications and refresh views.
- Verify round-trip, corrupt archives, missing files and preservation on failed import.
- Cloud sync requires a separate account/backend design and is outside this task.

## 6. Settings and data management — implemented; combined regression checks passed
- Persist reminder default time (initially 9 AM) and apply it to new entries.
- Show notification permission status and meaningful platform controls.
- Connect archive and backup/restore management.
- If provided, clear-data must explicitly confirm and clean files/notifications.
- Verify persisted preferences, permission handling and data-management refresh.

## 7. Voice capture — implemented; combined regression checks passed
- Add model download progress, cancellation/retry and safe partial-file handling.
- Show microphone permissions and clear listening/stop/error states.
- Review/edit transcript before saving; keep the simple entry flow.
- Verify download/permission/lifecycle failures and real speech when hardware permits.

## 8. Payment screenshot capture — implemented; combined regression checks passed
- Test warm/cold Android image sharing and OCR with representative fixtures.
- Prefill title/description/amount with editable review and uncertain-result feedback.
- Handle no text, parsing failure, duplicate and overlapping intake.
- Copy attachments privately only when saving.
- Verify real share intents and record/attachment cleanup; record iOS coverage separately.

## 9. Local AI extraction — implemented; combined regression checks passed
- Verify model/runtime compatibility and provide install/readiness controls.
- Bound loading/inference; validate output and normalize entry kinds.
- Support download progress, cancellation/retry and graceful fallback.
- Connect editable capture review and settings management.
- Verify malformed output, fallback and actual model execution where feasible.

## 10. Camera quick capture — implemented; combined regression checks passed
- Add a compact Take photo option to Quick Add.
- Handle camera availability, permissions, cancellation and retry.
- Preview captured photos and create a Thing with an editable title and optional details/reminder.
- Save durable private copies; clean canceled captures and files on record deletion.
- Verify actual emulator capture, canceled/denied flows and attachment persistence.

## 11. Landing site and GitHub Pages — implemented; build and browser checks passed
- Build an isolated responsive React website with Framer Motion and reduced-motion support.
- Add hero, real features, polished app visuals and Coming soon download sections.
- Create separate factual privacy-policy and terms pages.
- Add branch-based gh-pages build/deploy workflow with correct repository base path.
- Verify production build, legal navigation and desktop/mobile layouts.
- Record required GitHub Pages repository settings; do not publish elsewhere.

## Package identity
- Android application/namespace and iOS bundle IDs: com.nanisamireddy.later.
- Android build/install and milestone end-to-end check passed with the new package. iOS compilation needs Xcode.

## Final integration verification
- Run static analysis, meaningful regression tests and Android end-to-end checks.
- Verify new flows visually and clean all temporary QA data.
- Record physical-device and iOS gaps separately from feature implementation status.

## Verification evidence — 10 October 2026
- `flutter analyze`: no issues.
- `flutter test`: 109 passed, one native speech test skipped in the ordinary suite.
- Covered status persistence, combined search filters, repayment correction/settlement, migration, backup validation/rollback, saved reminder defaults, recurrence boundaries, notification adapters, capture review, download cancellation and cleanup, strict AI parsing and fallback.
- Voice native decoder separately recognized the publisher's WAV; model checksums matched. Physical microphone and permission-dialog testing remains pending.
- Android local AI loaded the verified Qwen3 model and generated tokens, but did not complete readiness within 90 seconds. Completed native extraction remains unverified; manual/OCR fallback is available. iOS/web AI is disabled for this runtime.
- iOS screenshot sharing still requires a Share Extension/App Groups target. Xcode is unavailable on this machine.
- Monthly repeats schedule 13 upcoming occurrences and refresh on app launch. iOS notification limits and physical-device delivery need verification.
- Backup archives are local, unencrypted, and limited to 64 MB compressed. Android native export/import pickers and canceled restore preview passed; existing records stayed unchanged. Android may append `.gz` to the archive filename.
- Six Android integration tests passed: milestone persistence, notification navigation/PDF viewing, camera save/cancellation/private-file cleanup, native OCR, warm screenshot sharing/unreadable input handling, and backup export/import preview cancellation. Drivers preserve existing data and remove their own QA records/files.
- Cold-start screenshot sharing also passed in the normal installed app: native OCR populated Asha Rao / 1250.50, payment confirmation stayed unchecked, and review was canceled without saving. The normal app is running on the emulator.
- Reference UI restyle: top tabs, compact Things cards with completion controls, pastel balance cards, and shared filter sheets. 320/411 px navigation and layout checks passed; the updated normal app was visually inspected on Android.

- Website: locked install, production build/type-check, 1280/768/390/320 px browser checks, direct legal routes/reloads, capture-tab keyboard controls, reduced motion, workflow syntax and local branch-publication simulation passed. Configure GitHub Pages to `gh-pages` / root after pushing; live deployment/API acceptance remains unverified. See `website/VERIFICATION.md`.
