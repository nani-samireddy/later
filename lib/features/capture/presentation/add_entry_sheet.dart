import '../../../core/widgets/note_body_editor.dart';

import 'dart:async';

import '../../../core/ai/local_ai_service.dart';
import 'entry_suggestion_review.dart';
import 'voice_capture_dialog.dart';
import '../../../core/widgets/recurrence_picker.dart';
import '../../../core/reminders/recurrence.dart';
import 'widgets/money_type_picker.dart';
import '../../../core/widgets/reminder_picker.dart';
import '../domain/entry_validation.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

import '../../../core/payments/payment_screenshot_parser.dart';
import '../data/entry_capture_service.dart';

Future<void> showAddEntrySheet(
  BuildContext context, {
  required EntryCaptureService service,
  required String currency,
  required Future<void> Function() onThingsChanged,
  required Future<void> Function() onMoneyChanged,
  PaymentScreenshotData? paymentScreenshot,
  Future<bool> Function()? onTakePhoto,
}) {
  final aiData = paymentScreenshot?.aiData;
  final title = TextEditingController(
    text: paymentScreenshot == null
        ? ''
        : paymentScreenshot.merchant.isNotEmpty
        ? paymentScreenshot.merchant
        : aiData?.description,
  );
  var paymentTypeConfirmed = paymentScreenshot == null;
  final description = TextEditingController(
    text: aiData?.description.isNotEmpty == true
        ? aiData!.description
        : paymentScreenshot?.text,
  );
  final amount = TextEditingController(text: paymentScreenshot?.amount);
  final category = TextEditingController(text: 'General');
  var kind = aiData?.kind ?? 'thing';
  var voiceOpen = false;
  var suggesting = false;
  unawaited(LocalAiService.instance.refresh());
  var recurrence = ReminderRecurrence.none;
  var saving = false;
  String? validationError;
  DateTime? reminderDate;
  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);
  final attachments = <PlatformFile>[];
  if (paymentScreenshot != null) {
    attachments.add(
      PlatformFile(
        name: path.basename(paymentScreenshot.attachmentPath),
        size: File(paymentScreenshot.attachmentPath).existsSync()
            ? File(paymentScreenshot.attachmentPath).lengthSync()
            : 0,
        path: paymentScreenshot.attachmentPath,
      ),
    );
    kind = 'spending';
  }
  ModalRoute<dynamic>? sheetRoute;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (sheetContext) {
      sheetRoute = ModalRoute.of(sheetContext);
      return StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            4,
            24,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add to Later',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                if (paymentScreenshot != null)
                  Text(paymentScreenshot.reviewMessage),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'thing',
                      icon: Icon(Icons.bookmark_outline),
                      label: Text('Thing'),
                    ),
                    ButtonSegment(
                      value: 'money',
                      icon: Icon(Icons.payments_outlined),
                      label: Text('Money'),
                    ),
                  ],
                  selected: {kind == 'thing' ? 'thing' : 'money'},
                  onSelectionChanged: saving
                      ? null
                      : (value) => setSheetState(() {
                          kind = value.first == 'thing' ? 'thing' : 'spending';
                          paymentTypeConfirmed = value.first == 'thing';
                          validationError = null;
                        }),
                ),
                const SizedBox(height: 16),
                if (kind != 'thing') ...[
                  MoneyTypePicker(
                    value: kind,
                    enabled: !saving,
                    onChanged: (value) => setSheetState(() {
                      kind = value;
                      if (value != 'spending' &&
                          aiData?.person.isNotEmpty == true) {
                        title.text = aiData!.person;
                      }
                      paymentTypeConfirmed = true;
                    }),
                  ),
                  if (paymentScreenshot != null)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('I have checked the payment type'),
                      value: paymentTypeConfirmed,
                      onChanged: saving
                          ? null
                          : (value) => setSheetState(
                              () => paymentTypeConfirmed = value ?? false,
                            ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amount,
                    enabled: !saving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '$currency ',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: title,
                  enabled: !saving,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: kind == 'thing'
                        ? 'What do you want to remember?'
                        : kind == 'spending'
                        ? 'e.g. Groceries or coffee'
                        : 'Who is this with?',
                    suffixIcon: IconButton(
                      tooltip: 'Speak',
                      onPressed: saving || voiceOpen
                          ? null
                          : () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setSheetState(() => voiceOpen = true);
                              try {
                                await showVoiceCaptureDialog(
                                  context,
                                  initialText: title.text,
                                  onApply: (text) {
                                    if (context.mounted) {
                                      setSheetState(() => title.text = text);
                                    }
                                  },
                                );
                              } finally {
                                if (context.mounted) {
                                  setSheetState(() => voiceOpen = false);
                                }
                              }
                            },
                      icon: const Icon(Icons.mic_none_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (kind == 'thing')
                  NoteBodyEditor(controller: description, enabled: !saving)
                else
                  TextField(
                    controller: description,
                    enabled: !saving,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                  ),
                AnimatedBuilder(
                  animation: LocalAiService.instance,
                  builder: (context, _) =>
                      {
                        LocalAiStatus.ready,
                        LocalAiStatus.installed,
                        LocalAiStatus.extracting,
                      }.contains(LocalAiService.instance.status)
                      ? TextButton.icon(
                          icon: const Icon(Icons.auto_awesome_outlined),
                          label: Text(
                            suggesting
                                ? 'Reading your text…'
                                : 'Suggest details',
                          ),
                          onPressed:
                              saving ||
                                  suggesting ||
                                  LocalAiService.instance.working
                              ? null
                              : () async {
                                  setSheetState(() => suggesting = true);
                                  try {
                                    final result = await LocalAiService.instance
                                        .extract(
                                          '${title.text}\n${description.text}',
                                        );
                                    if (!context.mounted) return;
                                    if (result == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'No suggestion available. Your text is unchanged.',
                                              ),
                                            ),
                                          );
                                      return;
                                    }
                                    if (await reviewEntrySuggestion(
                                          context,
                                          result,
                                          currency,
                                        ) &&
                                        context.mounted) {
                                      setSheetState(() {
                                        kind = result.kind;
                                        if (result.person.isNotEmpty) {
                                          title.text = result.person;
                                        } else if (kind == 'thing' &&
                                            result.description.isNotEmpty) {
                                          title.text = result.description;
                                        }
                                        amount.text = result.amount;
                                        description.text = result.description;
                                        paymentTypeConfirmed = true;
                                      });
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setSheetState(() => suggesting = false);
                                    }
                                  }
                                },
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                ReminderPicker(
                  database: service.database,
                  showHelp: false,
                  enabled: !saving,
                  value: reminderDate == null
                      ? null
                      : DateTime(
                          reminderDate!.year,
                          reminderDate!.month,
                          reminderDate!.day,
                          reminderTime.hour,
                          reminderTime.minute,
                        ),
                  onChanged: (date) => setSheetState(() {
                    reminderDate = date;
                    if (date == null) recurrence = ReminderRecurrence.none;
                    if (date != null) {
                      reminderTime = TimeOfDay.fromDateTime(date);
                    }
                  }),
                ),
                if (reminderDate != null)
                  RecurrencePicker(
                    value: recurrence,
                    enabled: !saving,
                    onChanged: (value) =>
                        setSheetState(() => recurrence = value),
                  ),
                if (onTakePhoto != null && paymentScreenshot == null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: const Text('Take photo'),
                    subtitle: const Text('Create a thing from a photo'),
                    enabled: !saving,
                    onTap: saving
                        ? null
                        : () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            final saved = await onTakePhoto();
                            if (saved && sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.attach_file_rounded),
                  title: Text(
                    attachments.isEmpty
                        ? 'Add attachment'
                        : '${attachments.length} attachment(s) selected',
                  ),
                  onTap: saving
                      ? null
                      : () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          final result = await FilePicker.platform.pickFiles(
                            allowMultiple: true,
                            type: FileType.any,
                          );
                          if (result != null && context.mounted) {
                            setSheetState(
                              () => attachments.addAll(result.files),
                            );
                          }
                        },
                ),
                if (attachments.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: attachments
                        .map(
                          (file) => InputChip(
                            label: Text(
                              file.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onDeleted: saving
                                ? null
                                : () => setSheetState(
                                    () => attachments.remove(file),
                                  ),
                          ),
                        )
                        .toList(),
                  ),
                if (validationError != null)
                  Text(
                    validationError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: saving
                            ? null
                            : () async {
                                final error = !paymentTypeConfirmed
                                    ? 'Check the payment type before saving.'
                                    : title.text.trim().isEmpty
                                    ? 'Enter a title for your item.'
                                    : validateEntry(
                                        kind: kind,
                                        description: title.text,
                                        person: title.text,
                                        amount: amount.text,
                                      );
                                setSheetState(() => validationError = error);
                                if (error != null) return;
                                setSheetState(() => saving = true);
                                try {
                                  final saved = await service.save(
                                    kind: kind,
                                    title: title.text,
                                    description: description.text,
                                    category: category.text,
                                    amount: amount.text,
                                    person: title.text,
                                    currency: currency,
                                    attachments: attachments,
                                    reminderDate: reminderDate,
                                    recurrence: recurrence,
                                    reminderTime: reminderTime,
                                  );
                                  if (!saved) return;
                                  if (kind == 'thing') {
                                    await onThingsChanged();
                                  } else {
                                    await onMoneyChanged();
                                  }
                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                } catch (_) {
                                  if (sheetContext.mounted) {
                                    setSheetState(
                                      () => validationError = 'Could not save this entry. Try again.',
                                    );
                                  }
                                } finally {
                                  if (sheetContext.mounted) {
                                    setSheetState(() => saving = false);
                                  }
                                }
                              },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Create entry'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).whenComplete(() async {
    await sheetRoute?.completed;
    description.dispose();
    amount.dispose();
    title.dispose();
    category.dispose();
  });
}
