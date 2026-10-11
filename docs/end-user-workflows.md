# Later: end-user workflows

Reviewed against the app source on 11 October 2026. This is a definition of current user journeys, not a claim that every journey has passed physical-device testing. Android is the primary supported and tested path. IDs are stable so they can be used in acceptance tests and release checklists.

## Product and navigation

Later stores Things (notes, checklists and tasks) and Money (spending and debts), with optional attachments and reminders. There is no account/sign-in or automatic cloud sync. Ordinary records are local; optional live voice sends audio to Google after consent. Backup files are user-managed.

Mobile navigation: Overview, Things, Money, Upcoming; the profile icon opens Settings. Search is in the header. A filter button appears beside Search on applicable Things/Money views. The floating + expands inline to Photo, Voice, List, Text and Money; it does not dim or overlay the page. Back collapses an expanded quick-add menu before leaving. Wide layouts use a navigation rail.

| ID | User goal and entry point | Steps and outcome | Alternatives / recovery |
|---|---|---|---|
| W01 | Start using Later: first launch | Enter a name (up to 40 characters) → Get started → personalized home. Preferences are local. | Skip for now gives a generic greeting. Blank name requires entering a name or skipping. Failed load/save offers retry. Returning users bypass onboarding. |
| W02 | See the day: Overview | Open Overview → scan Things, money summaries and upcoming reminders → tap an entry or View all to continue in the relevant section. | Empty sections explain that there is nothing saved yet. Currency totals are kept separate, without exchange conversion. |
| W03 | Navigate or start capture | Select a tab or swipe pages → tap + → select Photo / Voice / List / Text / Money. | Tap + again or Back to collapse. A capture already in progress must finish before another capture is accepted. |

## Notes, tasks and lists

Text and List quick actions create a Thing using a full-screen editor. Checklist rows are content inside a note; they are not separate task records with independent reminders.

| ID | User goal and entry point | Steps and outcome | Alternatives / recovery |
|---|---|---|---|
| W04 | Capture a thought: + → Text | Enter title and body → optionally add attachments/reminder → edits autosave → Done or Back returns to the list. | Opening and closing a blank note creates no record. Nonempty body with no title saves as Untitled note. There is no discard button for an already autosaved note; delete the saved Thing to remove it. |
| W05 | Create a checklist: + → List | Enter note title → type rows → add another row with the list control or keyboard Next → tick completed rows → Done. | Checkbox mode can be switched within the editor. A list is one Thing; ticking every row does not automatically mark the whole Thing done. |
| W06 | Mix freeform text and checklists: editor | Use Checklist to switch presentation; edit body content with the provided controls. Text remains stored in the note body with checklist/format markers. | This is a lightweight note editor, not a fully general rich-text block canvas. Check the result after switching modes. |
| W07 | Organize checklist rows: editor | Drag a row to reorder → List item options → Indent / Outdent for nesting → delete a row using its remove control. | Nesting has three levels below the root. Moving a parent moves its descendants. Ticking a parent does not automatically tick its children. |
| W08 | Format a note: Formatting toolbar | Choose Bold / Italic / Underline / Heading for selected text or the insertion point. | Formatting is stored with portable text markers and rendered in the detail view. Undo/redo, note colours, drawing and pinning are not available. |
| W09 | Revisit/edit a Thing: Things or search → entry | Read title, category, status, body, checklist progress, reminder and attachments → Edit → change title/body/category/reminder → Done. | Edits autosave after a short debounce (500 ms). Done/Back flush outstanding changes; backgrounding also attempts a save. Failed save exposes Retry and prevents an ordinary editor exit from silently dropping changes. |
| W10 | Check items without opening editor: Thing detail | Tap a checkbox in the note body → checked state persists and progress on cards updates when lists refresh. | This updates note content, not the Thing's overall status. Failed status/content updates show feedback. |
| W11 | Finish or reopen a task: Thing detail | Mark done → Thing becomes completed and its reminder pauses. Reopen → active status returns and reminder policy is reconciled. | A past one-off reminder is not a new future reminder merely because the Thing is reopened. Choose a new future date if needed. |
| W12 | Put a Thing away/recover it: Thing detail / Settings → Archive | Archive → hidden from ordinary active Things. Open Archive → select entry → Unarchive to restore its previous status. | Archived reminders are paused. Archive is reversible; it is not deletion. Empty/error archive states offer guidance/retry. |
| W13 | Permanently delete a Thing: detail → Delete | Confirm deletion → record and associated attachment/reminder handling are removed → return to the previous list. | Cancel leaves the item intact. No trash or undo-deletion workflow exists; restore from a previously exported backup if available. |

## Live voice

| ID | User goal and entry point | Steps and outcome | Alternatives / recovery |
|---|---|---|---|
| W14 | Dictate a new note: + → Voice | Read cloud audio disclosure → allow Google audio processing → tap microphone → grant microphone permission if prompted → speak → live text updates → Done → note editor. Title starts with the first 50 user-perceived characters; body contains the full final transcript. | No tester access code is required. Done waits for the final result, then goes straight to editing; there is no Use text confirmation screen. An empty draft cannot continue using Done. |
| W15 | Pause/resume dictation: voice screen | Pause microphone → earlier text remains → optionally edit while stopped → Resume → new recognized text is appended to retained text. | Natural pauses between sentences keep the same microphone/socket session open. A manual pause ends capture; resume starts a new session. |
| W16 | Use voice in the add form: title's Speak action | Open voice from an existing Thing/Money form → dictate → Done returns to that form. First 50 characters fill title/person field; full transcript fills description. | For Money, still review type/person/amount and save manually. Dictation does not automatically parse or schedule a spoken reminder such as “tomorrow.” |
| W17 | Recover from voice failure | Permission denial, offline connection, provider error, request limit or microphone failure → draft remains → retry/resume, type manually, or cancel. | Capture stops after five minutes and on backgrounding/closing. User can continue in another session. Network loss is surfaced; the app does not silently record an offline backlog. Cancel/Back returns without forwarding text to the caller. Later does not save an audio recording. |

## Camera, sharing and suggested capture

| ID | User goal and entry point | Steps and outcome | Alternatives / recovery |
|---|---|---|---|
| W18 | Make a photo task: + → Photo | Open camera → take photo → return to Photo task review → enter title and optional description/reminder → Save task → new Thing with photo attachments. | Take more photos or remove one before saving. Camera cancellation returns to the review without adding a photo. Cancel review creates no task. Permission/copy/save failures keep a recoverable review. This path does not automatically OCR the photo into note text. |
| W19 | Recover interrupted camera capture: reopen app | If Android returns lost camera results after reclaiming the activity, Later offers the recovered photos in the capture review → review and save/cancel. | Requires actual recovered camera results; this is not arbitrary photo recovery from storage. If another capture is open, complete it first. |
| W20 | Import a payment screenshot: another app → Share → Later | Share exactly one image → OCR and optional local extraction → review prefilled add form with original image attached → explicitly confirm payment type → correct fields → Save. | Default is spending, not automatic debt creation. User can choose another Money type or Thing. Multiple images/non-image shares are rejected with guidance; duplicate deliveries are suppressed briefly. Failed reading falls back to manual entry/re-share. Opening review alone does not save a record. |
| W21 | Suggest structured details: add form → Suggest details | With a local AI model installed/ready, enter text → Suggest details → inspect proposed kind/person/amount/description → Use suggestion → edit fields → Save. | Keep my text rejects the suggestion. No suggestion leaves text intact. This control is conditional on model state and is in the add form, not the quick note editor. It does not auto-save or auto-create entries. |

## Money

| ID | User goal and entry point | Steps and outcome | Alternatives / recovery |
|---|---|---|---|
| W22 | Record spending: + → Money | Select I spent money → enter amount and title/person/merchant as appropriate, optional description and attachments → optionally set reminder → Save. Uses the default currency for new records. | Positive amounts with no more than two decimal places are required. Validation leaves the form open. Cancel before Save creates no entry. Existing currencies are not converted when defaults change. |
| W23 | Track someone owing you: + → Money | Choose Someone owes me → enter person and positive amount → optional reason, due reminder, recurrence and attachments → Save. | Record appears under owed-to-you balances. Confirm extracted screenshot fields rather than trusting OCR. |
| W24 | Track money you owe: + → Money | Choose I owe someone → enter person and positive amount → optional reason/due reminder/attachments → Save. | Record appears under your outstanding debt balances. No payment is sent; Later is a tracker. |
| W25 | Understand balances/history: Money | View owed-to-you and you-owe summaries, separated by currency → filter type → review monthly spending totals/history → tap entry. | Spending summaries are displayed in the applicable spending view. Settled/partial debt state affects outstanding balances. No bank connection, conversion or payment execution exists. |
| W26 | Edit a Money record: detail → Edit | Change person, amount, reason and reminder/due date → Save → refreshed details. | Validation rejects invalid amounts and reductions incompatible with already recorded repayments. Cancel leaves the existing record intact. Existing currency is retained. |
| W27 | Correct spending date: spending detail | Tap Spending date → choose date → date and spending-history grouping update. | Cancel keeps original date. This is distinct from setting a future reminder. |
| W28 | Record a partial repayment: open debt detail | Record partial repayment → enter positive amount → Save → payment history, repaid amount and remaining amount update. | Cannot exceed outstanding amount. A full repayment settles the debt. Invalid values keep the dialog open. |
| W29 | Correct/remove a repayment: debt payment history | Tap Correct repayment → adjust amount → Save; or Delete repayment → confirm → balances and settlement reconcile. | Cancel keeps history. A correction/deletion can reopen a debt that had been fully paid. |
| W30 | Settle/reopen a debt: debt detail | Mark as settled → outstanding balance becomes zero and reminder is disabled. Mark as open → confirm clearing repayments → debt reopens. | Reopening explicitly removes repayment history; it is not simply changing a visual label. Partial repayment is preferable when retaining a history of instalments. |
| W31 | Delete a Money record: detail → Delete | Confirm deletion → remove record and related repayment/attachment/reminder handling → list refreshes. | Cancel is safe. There is no individual-record recovery except an existing backup. |

## Reminders and upcoming work

| ID | User goal and entry point | Steps and outcome | Alternatives / recovery |
|---|---|---|---|
| W32 | Set/change a reminder: editor/form | Add reminder → select date → select time (9 AM initially, or saved default) → save/autosave the entry. Uses device-local time. | A past/nonfuture timestamp is rejected. Cancelling either picker preserves the old value. Date selection alone does not schedule a reminder. Android may ask for exact-alarm access. |
| W33 | Remove a reminder | Use Remove reminder / clear control in the applicable editor/form → save/autosave → reminder is cancelled/reconciled. | Removing a reminder from the add form also clears its repeat choice. Existing detail repeat controls require a reminder date. |
| W34 | Repeat a reminder | In supported add forms, choose Repeat reminder after setting a date; for saved records, use repeat controls in detail → Does not repeat / Daily / Weekly / Monthly. | Quick note editor sets the date; repeating can then be configured from detail. Monthly recurrence retains the original calendar-day anchor, adjusting short months. Completed/archived Things and settled Money pause delivery. |
| W35 | Delay/undo delay: detail reminder controls | Snooze 1 hour or Tomorrow at 9 AM → snoozed time appears. Undo snooze restores the recurrence policy. | Tomorrow at 9 AM is a fixed snooze shortcut, separate from the default new-reminder time. Controls are unavailable for inactive/settled records. Failures display retryable feedback. |
| W36 | Act on upcoming/overdue work: Upcoming | Review coming reminders and overdue entries → tap one → detail → complete/reopen, settle, reschedule or snooze. | Current eligibility follows record status and reminder policy. A completed/archived/settled record is not actionable upcoming work. |
| W37 | Open a reminder notification: notification tap | Tap a local notification → Later opens the linked Thing/Money detail, including cold-start handling. | If the record no longer exists, there is no matching detail to open. Snooze/completion controls are in the app; notification action buttons are not implemented. |
| W38 | Recover notification delivery: Settings | Check Notifications status → request permission or enable in device settings → optionally allow Exact reminder timing → resume app for status refresh. | Denial does not prevent saving entries. App warns when an entry is saved but scheduling fails. Without exact access, scheduling can use inexact timing. Startup reconciles saved reminders. |

## Search, filters and attachments

| ID | User goal and entry point | Steps and outcome | Alternatives / recovery |
|---|---|---|---|
| W39 | Find an entry: header → Search everything | Type a query → see matching Things and Money → tap result → detail → return to refreshed results. | Matching is case-insensitive substring search over supported record text; not semantic search or document-content search. Empty query shows eligible records; no matches displays an empty result state. |
| W40 | Narrow/order entries: filter beside Search or search screen | Open bottom sheet → choose Thing category/status, Money type/settlement, date range and sort as relevant → Apply filters. | Cancel/dismiss leaves applied filters unchanged. Reset resets the draft; Apply is still needed. Sort: newest, title, reminder/due date, or amount for Money. Date range excludes undated records; it uses reminder dates for Things and due/spending dates for Money. |
| W41 | Add an attachment: creation/editor/detail | Select one or more files using system picker → app copies supported selected files privately → save entry or attach to saved entry. | File picker cancellation makes no change. A failed copy shows feedback; successfully added files may remain. No broad photo-library permission is required. |
| W42 | Read/remove an attachment: detail | Tap attachment → supported preview/viewer opens; remove control deletes its association/file handling. | Missing/unopenable files show feedback. Cancelling picker/viewer does not delete files. Removing an attachment does not delete its parent entry. |

## Settings, backup and optional model

| ID | User goal and entry point | Steps and outcome | Alternatives / recovery |
|---|---|---|---|
| W43 | Change personal defaults: Settings | Your name → edit/save (blank allowed for generic greeting); Default currency → INR/USD/EUR; Default reminder time → choose time. | Name is local and included in backups. Currency/time changes apply to new records/new reminder selection, not retroactive conversion or rescheduling of all existing entries. |
| W44 | Export a backup: Settings → Backup & restore | Export backup → choose destination → save `.laterbackup` → success feedback. Includes records, settings, repayment history, reminder policies and private attachments. | Cancel makes no export. File failures show feedback. Backup is not encrypted; store securely. No automatic cloud backup is performed. |
| W45 | Restore/move to another device: Backup & restore → Import | Select backup → validate/preview creation time and record/file counts → Replace all data → local data replaced, attachments restored and reminders rebuilt → lists/settings refresh. | Cancel preview preserves data. Restore does not merge. Oversized (over 64 MB), invalid or incompatible input fails with feedback. Compatible older backups supply defaults for new fields. |
| W46 | Permanently reset Later: Settings → Clear all data | Read confirmation → optionally export first → Delete all data → records, payments, archived Things, attachments, reminders and preferences cleared. | Cancel keeps everything. Exported backups and downloaded models remain. Partial file-cleanup failure explicitly asks the user to retry. Preferences/onboarding state are cleared; onboarding is evaluated again when the app gate reloads. |
| W47 | Install/use optional local AI: Settings → Local AI model | Review model size/device requirements → Install model → progress → Test readiness → optional Suggest details becomes available in supported capture forms. | Qwen3 0.6B download is about 614 MB; requires adequate storage/memory. Cancel/retry installation, refresh status, or Remove model. Unsupported platforms disable installation. Installation/readiness UI does not by itself establish extraction accuracy. |
| W48 | Access Later from Android home screen | Add Later widget through the launcher → see greeting/next reminder → tap Add to open capture or upcoming region to open Upcoming. | Android widget only; iOS widget is not present. First use may ask user to open Later. Widget is a local snapshot; launcher placement, refresh over time and actions require physical-device verification. |

## Cross-cutting acceptance rules

- Nothing is automatically parsed into a financial transaction, date or recurrence merely because a user spoke it. The editor/form is the place to correct and confirm structured values.
- Quick note editors autosave; add-entry and photo/payment review forms save explicitly. Do not describe Cancel as discarding an already autosaved note.
- Parent Thing status and checklist-row completion are separate. Archive is reversible; deletion is permanent.
- Monetary summaries must remain separated by currency. Payment history must reconcile with outstanding debt.
- Permission denial must retain a manual path and should not prevent ordinary local record management.
- Capture cancellation must release microphone/camera resources and must not create a record. Draft text must survive recoverable voice errors within its screen.
- A successfully saved record and successfully scheduled notification are separate outcomes; scheduling warnings must remain visible.
- Restore is replacement, not merging. Exported backup data is private but unencrypted.
- Mobile, wider layouts, permission-denied, empty, loading, validation-error and storage/network-failure variants belong in the acceptance checklist for each relevant workflow.

## Gaps and verification boundaries found in the walkthrough

1. In-app Settings currently has no privacy-policy/terms entry. Website legal pages exist; a discoverable in-app privacy-policy link is a release gap.
2. No account, cloud sync, encrypted backup, trash, pinning, note colours, drawing, saved audio, or editor undo/redo workflows exist. These are possible future scope, not implied by the workflow definitions above.
3. Android image sharing is payment-screenshot oriented and accepts one image. Generic shared text/URLs, multiple shared images and an iOS share extension are not covered.
4. The note composer is simpler than the unified add form: category editing/repeat controls are reached later through saved-Thing editing/detail. Optional AI suggestion is not directly in the quick note editor.
5. Voice now works on the Pixel per user feedback. Synthetic speech, the production Dart connection and lifecycle tests passed; accents/mixed languages, prolonged noise, loss of network and duration limits still need a structured physical-device matrix.
6. Android widget launcher behavior, iOS support, real local-model extraction and optimized release-device behavior remain verification work.
7. This document is source-reviewed. Destructive restore/delete/clear flows were not executed on the user's live data during this review.

## Source traceability

| Workflows | Primary sources |
|---|---|
| W01–W03 | `lib/features/onboarding/presentation/onboarding_gate.dart`, `lib/features/home/presentation/home_screen.dart`, `widgets/home_scaffold.dart`, `lib/features/capture/presentation/quick_add_menu.dart` |
| W04–W13 | `lib/features/capture/presentation/note_composer_screen.dart`, `lib/core/widgets/note_body_editor.dart`, `lib/features/things/presentation/thing_editor_screen.dart`, `thing_detail_screen.dart`, `archive_screen.dart`, Things repository |
| W14–W17 | `lib/features/capture/presentation/voice_capture_dialog.dart`, `lib/core/speech/voice_capture_controller.dart`, `gemini_speech_service.dart`, `services/voice-token/worker.js` |
| W18–W21 | `lib/features/camera/presentation/camera_capture_dialog.dart`, capture controller, `lib/core/payments/shared_payment_service.dart`, screenshot parser, `lib/features/capture/presentation/add_entry_sheet.dart`, `entry_suggestion_review.dart` |
| W22–W31 | Money detail/edit screens, Money repository, capture validation and add form, money summary/spending-history widgets |
| W32–W38 | `lib/core/widgets/reminder_picker.dart`, `entry_reminder_controls.dart`, `recurrence_picker.dart`, reminder coordinator/preferences, notification service, Upcoming widgets |
| W39–W42 | Search screen/filter sheet/controls/domain filters; attachment panel, repository, opener and store |
| W43–W48 | Settings/onboarding preferences, backup screen/service, clear-data service, local-AI screen/service/runtime, home-widget bridge and native `LaterWidgetProvider.kt` |
