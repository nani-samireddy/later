import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

import '../../../core/speech/sherpa_speech_service.dart';
import '../../../core/payments/payment_screenshot_parser.dart';
import '../../../core/utils/date_format.dart';
import '../data/entry_capture_service.dart';

Future<void> showAddEntrySheet(
  BuildContext context, {
  required EntryCaptureService service,
  required String currency,
  required Future<void> Function() onThingsChanged,
  required Future<void> Function() onMoneyChanged,
  PaymentScreenshotData? paymentScreenshot,
}) {
  final aiData = paymentScreenshot?.aiData;
  final description = TextEditingController(
    text: aiData?.description.isNotEmpty == true
        ? aiData!.description
        : paymentScreenshot?.text,
  );
  final amount = TextEditingController(
    text: aiData?.amount.isNotEmpty == true
        ? aiData!.amount
        : paymentScreenshot?.amount,
  );
  final person = TextEditingController(
    text: aiData?.person.isNotEmpty == true
        ? aiData!.person
        : paymentScreenshot?.merchant,
  );
  final category = TextEditingController(text: 'General');
  var kind = aiData?.kind ?? 'thing';
  var listening = false;
  DateTime? reminderDate;
  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);
  final attachments = <PlatformFile>[];
  if (paymentScreenshot != null) {
    attachments.add(
      PlatformFile(
        name: path.basename(paymentScreenshot.attachmentPath),
        size: File(paymentScreenshot.attachmentPath).lengthSync(),
        path: paymentScreenshot.attachmentPath,
      ),
    );
    kind = 'spending';
  }
  final speech = SherpaSpeechService();
  void applySpeech(String value, void Function(void Function()) update) {
    description.text = value;
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(value);
    final lower = value.toLowerCase();
    if (match != null && kind == 'thing') {
      kind = lower.contains('spent') ? 'spending' : 'owedToMe';
    }
    if (match != null && kind != 'thing') {
      amount.text = match.group(1)!;
      final cleaned = value
          .replaceAll(RegExp(r'\d+(?:\.\d+)?'), '')
          .replaceAll(
            RegExp(
              r'rupees?|inr|spent|spending|owes?|owe|me|for',
              caseSensitive: false,
            ),
            '',
          )
          .trim();
      person.text = cleaned;
    }
    update(() {});
  }

  late Future<void> Function() startListening;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (sheetContext) => StatefulBuilder(
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
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'thing', label: Text('Thing')),
                  ButtonSegment(value: 'owedToMe', label: Text('Owed to me')),
                  ButtonSegment(value: 'iOwe', label: Text('I owe')),
                  ButtonSegment(value: 'spending', label: Text('Spending')),
                ],
                selected: {kind},
                onSelectionChanged: (value) =>
                    setSheetState(() => kind = value.first),
              ),
              const SizedBox(height: 14),
              if (kind != 'thing')
                TextField(
                  controller: person,
                  decoration: const InputDecoration(
                    labelText: 'Person or merchant',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
              if (kind != 'thing')
                TextField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '$currency ',
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                ),
              TextField(
                controller: description,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: kind == 'thing'
                      ? 'What do you want to remember?'
                      : 'Description or reason',
                  hintText: 'Type or speak here',
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
              ),
              if (kind == 'thing')
                TextField(
                  controller: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_none_rounded),
                title: Text(
                  reminderDate == null
                      ? 'Add reminder'
                      : 'Reminder: ${formatDate(reminderDate!)} at ${reminderTime.format(context)}',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    initialDate:
                        reminderDate ??
                        DateTime.now().add(const Duration(days: 1)),
                  );
                  if (date != null) {
                    setSheetState(() => reminderDate = date);
                  }
                  if (date != null) {
                    if (!sheetContext.mounted) return;
                    final time = await showTimePicker(
                      context: sheetContext,
                      initialTime: reminderTime,
                    );
                    if (time != null) {
                      setSheetState(() => reminderTime = time);
                    }
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.attach_file_rounded),
                title: Text(
                  attachments.isEmpty
                      ? 'Add documents or images'
                      : '${attachments.length} attachment(s) selected',
                ),
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.any,
                  );
                  if (result != null) {
                    setSheetState(() => attachments.addAll(result.files));
                  }
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  IconButton.filled(
                    tooltip: listening ? 'Stop listening' : 'Speak',
                    onPressed: () async {
                      if (listening) {
                        setSheetState(() => listening = false);
                        await speech.stop();
                        return;
                      }
                      setSheetState(() => listening = true);
                      startListening = () => speech.start((text) {
                        if (listening) applySpeech(text, setSheetState);
                      });
                      try {
                        await startListening();
                      } catch (error) {
                        setSheetState(() => listening = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('$error')));
                        }
                      }
                    },
                    icon: Icon(
                      listening ? Icons.stop_rounded : Icons.mic_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final text = description.text.trim();
                        if (text.isEmpty) return;
                        final saved = await service.save(
                          kind: kind,
                          description: text,
                          category: category.text,
                          amount: amount.text,
                          person: person.text,
                          currency: currency,
                          attachments: attachments,
                          reminderDate: reminderDate,
                          reminderTime: reminderTime,
                        );
                        if (!saved) return;
                        if (kind == 'thing') {
                          await onThingsChanged();
                        } else {
                          await onMoneyChanged();
                        }
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
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
    ),
  ).whenComplete(() async {
    listening = false;
    await speech.dispose();
    description.dispose();
    amount.dispose();
    person.dispose();
    category.dispose();
  });
}
