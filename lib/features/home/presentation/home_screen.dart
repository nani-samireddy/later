import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' show Value;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/database/app_database.dart' hide Thing;
import '../../../core/speech/sherpa_speech_service.dart';
import '../../../core/payments/payment_screenshot_parser.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/ai/local_entry_ai.dart';
import '../../things/domain/thing.dart';
import '../../money/presentation/money_detail_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../settings/presentation/settings_screen.dart';

part 'home_dashboard.dart';
part 'home_sections.dart';
part 'home_things.dart';
part 'home_shared_widgets.dart';

final appDatabase = AppDatabase();

void main() => runApp(const LaterApp());

class LaterApp extends StatelessWidget {
  const LaterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Later',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F8F5),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF34725F)),
      fontFamily: 'Arial',
    ),
    home: const LaterHome(),
  );
}

class LaterHome extends StatefulWidget {
  const LaterHome({super.key});
  @override
  State<LaterHome> createState() => _LaterHomeState();
}

class _LaterHomeState extends State<LaterHome> {
  int selected = 0;
  late final PageController _pageController;
  List<ThingRecord> entries = [];
  List<MoneyEntry> moneyEntries = [];
  String searchQuery = '';
  String currency = 'INR';
  StreamSubscription<List<SharedMediaFile>>? _sharedMediaSubscription;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadEntries();
    _loadMoney();
    _loadCurrency();
    _listenForSharedPaymentScreenshots();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sharedMediaSubscription?.cancel();
    super.dispose();
  }

  Future<void> _listenForSharedPaymentScreenshots() async {
    _sharedMediaSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(_handleSharedMedia);
    final initial = await ReceiveSharingIntent.instance.getInitialMedia();
    await _handleSharedMedia(initial);
    await ReceiveSharingIntent.instance.reset();
  }

  Future<void> _handleSharedMedia(List<SharedMediaFile> files) async {
    final file = files.firstWhere(
      (item) => item.type == SharedMediaType.image && item.path.isNotEmpty,
      orElse: () => SharedMediaFile(path: '', type: SharedMediaType.text),
    );
    if (file.path.isEmpty || !mounted) return;
    final parsed = await PaymentScreenshotParser.parse(file.path);
    if (!mounted || parsed == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showUnifiedAddSheet(context, paymentScreenshot: parsed);
      }
    });
  }

  Widget _viewFor(int index) => index == 0
      ? _Dashboard(
          entries: entries,
          moneyEntries: moneyEntries,
          query: searchQuery,
          onQueryChanged: (value) => setState(() => searchQuery = value),
          onSearchTap: () => _openSearch(context),
          onOpenUpcoming: () => _goToPage(3),
          onOpenThings: () => _goToPage(1),
          onOpenThing: (entry) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _ThingRecordDetailPage(entry: entry),
            ),
          ),
          onSettingsTap: () => _goToPage(4),
        )
      : index == 4
      ? SettingsScreen(
          currency: currency,
          onCurrencyChanged: (value) async {
            setState(() => currency = value);
            await appDatabase.saveSetting('currency', value);
          },
        )
      : _SectionPage(
          index: index,
          entries: entries,
          moneyEntries: moneyEntries,
          onMoneyChanged: _loadMoney,
          query: searchQuery,
          onQueryChanged: (value) => setState(() => searchQuery = value),
          onSearchTap: () => _openSearch(context),
        );

  void _openSearch(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SearchScreen(
        things: entries,
        moneyEntries: moneyEntries,
        database: appDatabase,
        onThingTap: (thing) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ThingRecordDetailPage(entry: thing),
          ),
        ),
      ),
    ),
  );

  void _goToPage(int page) {
    setState(() => selected = page);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _loadMoney() async {
    final loaded = await appDatabase.allMoney();
    for (final entry in loaded) {
      if (entry.dueDate != null && !entry.settled) {
        await NotificationService.schedule(
          id: entry.id,
          title: 'Money reminder',
          body: entry.owedToMe
              ? '${entry.person} owes you ${entry.currency} ${entry.amount.toStringAsFixed(0)}'
              : 'You owe ${entry.person} ${entry.currency} ${entry.amount.toStringAsFixed(0)}',
          date: entry.dueDate!,
        );
      }
    }
    if (!mounted) return;
    setState(() => moneyEntries = loaded);
  }

  Future<void> _loadCurrency() async {
    final saved = await appDatabase.setting('currency');
    if (mounted && saved != null) setState(() => currency = saved);
  }

  Future<void> _loadEntries() async {
    final stored = await appDatabase.allThings();
    final loaded = stored
        .map(
          (thing) => ThingRecord(
            title: thing.title,
            category: thing.category,
            icon: Icons.bookmark_outline_rounded,
            reminderDate: thing.reminderDate,
          ),
        )
        .toList();
    if (!mounted) return;
    setState(() {
      entries = loaded.isEmpty ? _seedEntries() : loaded;
    });
  }

  List<ThingRecord> _seedEntries() => [
    ThingRecord(
      title: 'LG Refrigerator',
      category: 'Appliance',
      icon: Icons.kitchen_outlined,
      reminderDate: DateTime(2026, 9, 18),
    ),
    const ThingRecord(
      title: 'Electricity Bill',
      category: 'Document',
      icon: Icons.receipt_long_outlined,
    ),
    const ThingRecord(
      title: 'Bosch Drill',
      category: 'Tool',
      icon: Icons.handyman_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 700;
          if (mobile) {
            return PageView.builder(
              controller: _pageController,
              onPageChanged: (value) => setState(() => selected = value),
              itemCount: 5,
              itemBuilder: (_, index) => _viewFor(index),
            );
          }
          return Row(
            children: [
              NavigationRail(
                selectedIndex: selected,
                onDestinationSelected: (value) =>
                    setState(() => selected = value),
                backgroundColor: Colors.white,
                extended: MediaQuery.sizeOf(context).width > 900,
                leading: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDEDE4),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.bookmark_rounded,
                          color: Color(0xFF34725F),
                        ),
                      ),
                      if (MediaQuery.sizeOf(context).width > 900) ...[
                        const SizedBox(width: 10),
                        const Text(
                          'Later',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2_rounded),
                    label: Text('Things'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                    label: Text('Money'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month_rounded),
                    label: Text('Upcoming'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: Text('Settings'),
                  ),
                ],
              ),
              Expanded(child: _viewFor(selected)),
            ],
          );
        },
      ),
    ),
    bottomNavigationBar: MediaQuery.sizeOf(context).width < 700
        ? NavigationBar(
            selectedIndex: selected < 4 ? selected : 0,
            onDestinationSelected: (value) {
              setState(() => selected = value);
              _pageController.animateToPage(
                value,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
              );
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_rounded),
                label: 'Things',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Money',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'Upcoming',
              ),
            ],
          )
        : null,
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showUnifiedAddSheet(context),
      backgroundColor: const Color(0xFF34725F),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
    ),
  );

  void _showUnifiedAddSheet(
    BuildContext context, {
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

    showModalBottomSheet<void>(
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
                        : 'Reminder: ${_formatDate(reminderDate!)} at ${reminderTime.format(context)}',
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
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('$error')));
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
                          if (kind == 'thing') {
                            final thingId = await appDatabase.addThing(
                              ThingsCompanion.insert(
                                title: text,
                                category: category.text.trim().isEmpty
                                    ? 'General'
                                    : category.text.trim(),
                                iconCodePoint:
                                    Icons.bookmark_outline_rounded.codePoint,
                                reminderDate: Value(
                                  reminderDate == null
                                      ? null
                                      : DateTime(
                                          reminderDate!.year,
                                          reminderDate!.month,
                                          reminderDate!.day,
                                          reminderTime.hour,
                                          reminderTime.minute,
                                        ),
                                ),
                              ),
                            );
                            for (final file in attachments) {
                              await appDatabase.addAttachment(
                                AttachmentsCompanion.insert(
                                  thingId: thingId,
                                  name: file.path ?? file.name,
                                ),
                              );
                            }
                            await _loadEntries();
                          } else {
                            final parsedAmount = double.tryParse(
                              amount.text.trim(),
                            );
                            if (parsedAmount == null || parsedAmount <= 0) {
                              return;
                            }
                            final moneyId = await appDatabase.addMoney(
                              MoneyEntriesCompanion.insert(
                                person: person.text.trim().isEmpty
                                    ? 'Unknown'
                                    : person.text.trim(),
                                amount: parsedAmount,
                                currency: currency,
                                reason: Value(text),
                                owedToMe: kind == 'owedToMe',
                                kind: Value(
                                  kind == 'spending' ? 'spending' : 'debt',
                                ),
                                dueDate: Value(
                                  reminderDate == null
                                      ? null
                                      : DateTime(
                                          reminderDate!.year,
                                          reminderDate!.month,
                                          reminderDate!.day,
                                          reminderTime.hour,
                                          reminderTime.minute,
                                        ),
                                ),
                              ),
                            );
                            for (final file in attachments) {
                              await appDatabase.addMoneyAttachment(
                                MoneyAttachmentsCompanion.insert(
                                  moneyId: moneyId,
                                  name: file.name,
                                  path: file.path ?? file.name,
                                  kind: file.extension?.toLowerCase() == 'pdf'
                                      ? 'document'
                                      : 'image',
                                ),
                              );
                            }
                            await _loadMoney();
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
    ).whenComplete(speech.dispose);
  }

  void showAddSheetLegacy(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What do you want to remember?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _CaptureOption(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Money',
                color: Color(0xFFE2F1E7),
                onTap: () {
                  Navigator.pop(context);
                  _showMoneyDialog(context);
                },
              ),
              _CaptureOption(
                icon: Icons.mic_none_rounded,
                label: 'Speak',
                color: Color(0xFFE4F1EB),
                onTap: () {
                  Navigator.pop(context);
                  _showSpeakDialog(context);
                },
              ),
              _CaptureOption(
                icon: Icons.document_scanner_outlined,
                label: 'Scan',
                color: Color(0xFFFFEEDC),
              ),
              _CaptureOption(
                icon: Icons.edit_outlined,
                label: 'Type',
                color: Color(0xFFE9E7F7),
                onTap: () {
                  Navigator.pop(context);
                  _showTypeDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );

  void _showTypeDialog(BuildContext context) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController(text: 'General');
    DateTime? reminderDate;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add something'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'What do you want to remember?',
                  hintText: 'e.g. Passport',
                ),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_none_rounded),
                title: Text(
                  reminderDate == null
                      ? 'Add reminder'
                      : 'Reminder: ${_formatDate(reminderDate!)}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                  );
                  if (picked != null) {
                    setDialogState(() => reminderDate = picked);
                  }
                },
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                setState(
                  () => entries.insert(
                    0,
                    ThingRecord(
                      title: title,
                      category: categoryController.text.trim().isEmpty
                          ? 'General'
                          : categoryController.text.trim(),
                      icon: Icons.bookmark_outline_rounded,
                      reminderDate: reminderDate,
                      attachments: <String>[],
                    ),
                  ),
                );
                await appDatabase.addThing(
                  ThingsCompanion.insert(
                    title: title,
                    category: categoryController.text.trim().isEmpty
                        ? 'General'
                        : categoryController.text.trim(),
                    iconCodePoint: Icons.bookmark_outline_rounded.codePoint,
                    reminderDate: Value(reminderDate),
                  ),
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                await _loadMoney();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeakDialog(BuildContext context) {
    final speech = SpeechToText();
    final transcript = TextEditingController();
    var listening = false;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Speak an entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: transcript,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Example: Ravi owes me 800 rupees for dinner',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  if (listening) {
                    await speech.stop();
                    setDialogState(() => listening = false);
                    return;
                  }
                  final available = await speech.initialize();
                  if (!available) return;
                  setDialogState(() => listening = true);
                  await speech.listen(
                    onResult: (result) {
                      transcript.text = result.recognizedWords;
                      if (result.finalResult) {
                        setDialogState(() => listening = false);
                      }
                    },
                  );
                },
                icon: Icon(listening ? Icons.stop_rounded : Icons.mic_rounded),
                label: Text(listening ? 'Stop listening' : 'Start listening'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final text = transcript.text.trim();
                if (text.isEmpty) return;
                final normalized = await LocalEntryAi.normalize(text);
                await _saveSpokenEntry(normalized ?? text);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Create entry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSpokenEntry(String text) async {
    final amountMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    final amount = amountMatch == null
        ? null
        : double.tryParse(amountMatch.group(1)!);
    if (amount != null) {
      final lower = text.toLowerCase();
      final spending = lower.contains('spent') || lower.contains('spending');
      final owedToMe = lower.contains('owes me') || lower.contains('owe me');
      final person = text
          .replaceAll(RegExp(r'\d+(?:\.\d+)?'), '')
          .replaceAll(
            RegExp(
              r'rupees?|inr|spent|spending|owes?|owe|me|for',
              caseSensitive: false,
            ),
            '',
          )
          .trim();
      await appDatabase.addMoney(
        MoneyEntriesCompanion.insert(
          person: person.isEmpty ? (spending ? 'Spending' : 'Unknown') : person,
          amount: amount,
          currency: currency,
          reason: Value(text),
          owedToMe: owedToMe,
          kind: Value(spending ? 'spending' : 'debt'),
        ),
      );
      if (mounted) await _loadMoney();
      return;
    }
    await appDatabase.addThing(
      ThingsCompanion.insert(
        title: text,
        category: 'General',
        iconCodePoint: Icons.bookmark_outline_rounded.codePoint,
      ),
    );
    await _loadEntries();
  }

  void _showMoneyDialog(BuildContext context) {
    final personController = TextEditingController();
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    var owedToMe = true;
    var moneyKind = 'owedToMe';
    DateTime? dueDate;
    TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add money item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'owedToMe', label: Text('Owed to me')),
                    ButtonSegment(value: 'iOwe', label: Text('I owe')),
                    ButtonSegment(value: 'spending', label: Text('Spending')),
                  ],
                  selected: {moneyKind},
                  onSelectionChanged: (value) => setDialogState(() {
                    moneyKind = value.first;
                    owedToMe = moneyKind == 'owedToMe';
                  }),
                ),
                TextField(
                  controller: personController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Person'),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                  ),
                ),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Reason'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_none_rounded),
                  title: Text(
                    dueDate == null
                        ? 'Add reminder'
                        : 'Reminder: ${_formatDate(dueDate!)}',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      initialDate:
                          dueDate ??
                          DateTime.now().add(const Duration(days: 7)),
                    );
                    if (picked != null) setDialogState(() => dueDate = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_rounded),
                  title: Text('Time: ${reminderTime.format(context)}'),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: reminderTime,
                    );
                    if (picked != null) {
                      setDialogState(() => reminderTime = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final person = personController.text.trim();
                final amount = double.tryParse(amountController.text.trim());
                if (person.isEmpty || amount == null || amount <= 0) return;
                final moneyId = await appDatabase.addMoney(
                  MoneyEntriesCompanion.insert(
                    person: person,
                    amount: amount,
                    currency: currency,
                    reason: Value(reasonController.text.trim()),
                    owedToMe: owedToMe,
                    kind: Value(moneyKind == 'spending' ? 'spending' : 'debt'),
                    dueDate: Value(
                      dueDate == null
                          ? null
                          : DateTime(
                              dueDate!.year,
                              dueDate!.month,
                              dueDate!.day,
                              reminderTime.hour,
                              reminderTime.minute,
                            ),
                    ),
                  ),
                );
                if (dueDate != null) {
                  await NotificationService.schedule(
                    id: moneyId,
                    title: 'Money reminder',
                    body: owedToMe
                        ? '$person owes you $currency ${amount.toStringAsFixed(0)}'
                        : 'You owe $person $currency ${amount.toStringAsFixed(0)}',
                    date: dueDate!,
                  );
                }
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
