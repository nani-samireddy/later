import '../../../core/widgets/home_widget_bridge.dart';
import '../../../core/reminders/reminder_preferences.dart';
import '../../../core/camera/image_picker_camera.dart';
import '../../capture/presentation/camera_entry_capture.dart';
import '../../things/presentation/archive_screen.dart';

import 'dart:async';

import '../../../core/notifications/notification_service.dart';
import '../../../core/notifications/reminder_coordinator.dart';
import '../../money/presentation/money_detail_screen.dart';
import '../../things/data/things_repository.dart';
import 'widgets/home_scaffold.dart';

import 'package:flutter/material.dart';
import 'package:later/core/database/app_database.dart' hide Thing;
import 'package:later/core/payments/payment_screenshot_parser.dart';
import 'package:later/core/payments/shared_payment_service.dart';
import 'package:later/features/capture/data/entry_capture_service.dart';
import 'package:later/features/capture/presentation/add_entry_sheet.dart';
import 'package:later/features/home/data/home_repository.dart';
import 'package:later/features/home/presentation/home_dashboard.dart';
import 'package:later/features/home/presentation/home_sections.dart';
import 'package:later/features/search/presentation/search_screen.dart';
import 'package:later/features/settings/presentation/settings_screen.dart';
import 'package:later/features/things/domain/thing.dart';
import 'package:later/features/things/presentation/thing_detail_screen.dart';

class LaterHome extends StatefulWidget {
  const LaterHome({super.key});
  @override
  State<LaterHome> createState() => _LaterHomeState();
}

class _LaterHomeState extends State<LaterHome> {
  StreamSubscription<String>? _notificationTaps;
  StreamSubscription<String>? _notificationWarnings;
  int selected = 0;
  bool _captureOpen = false;
  Completer<void>? _captureDone;
  late final PageController _pageController;
  List<Thing> entries = [];
  Map<String, ReminderPreferences> reminderPreferences = {};
  List<MoneyEntry> moneyEntries = [];
  String searchQuery = '';
  String currency = 'INR';
  String userName = '';
  final _homeWidget = HomeWidgetBridge();
  final AppDatabase _database = AppDatabase();
  late final HomeRepository _repository = HomeRepository(_database);
  late final EntryCaptureService _capture = EntryCaptureService(_database);
  final SharedPaymentService _sharedPayments = SharedPaymentService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _homeWidget.start((action) async {
        if (!mounted) return;
        if (action == 'add') await _showUnifiedAddSheet(context);
        if (action == 'upcoming') {
          setState(() => selected = 3);
          _pageController.jumpToPage(3);
        }
      }),
    );
    _notificationWarnings = NotificationService.warnings.stream.listen((
      message,
    ) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    });
    _notificationTaps = NotificationService.taps.stream.listen(
      _openNotification,
    );
    ReminderCoordinator(_database).syncAll().catchError((Object error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not restore reminders. Check notification permissions.',
            ),
          ),
        );
      }
    });
    final payload = NotificationService.initialPayload;
    NotificationService.initialPayload = null;
    if (payload != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openNotification(payload),
      );
    }
    _loadEntries();
    _loadMoney();
    _loadCurrency();
    _listenForSharedPaymentScreenshots();
    unawaited(_recoverCameraCapture());
  }

  @override
  void dispose() {
    _notificationTaps?.cancel();
    _notificationWarnings?.cancel();
    _homeWidget.dispose();
    _pageController.dispose();
    _sharedPayments.dispose();
    _database.close();
    super.dispose();
  }

  Future<void> _listenForSharedPaymentScreenshots() => _sharedPayments.start(
    (parsed) async {
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) {
        await _showUnifiedAddSheet(context, paymentScreenshot: parsed);
      }
    },
    isReviewOpen: () => _captureOpen,
    onFeedback: (message) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    },
  );

  Future<void> _recoverCameraCapture() async {
    try {
      final photos = await ImagePickerCamera().recoverLostPhotos();
      if (photos.isEmpty) return;
      await WidgetsBinding.instance.endOfFrame;
      if (_captureOpen) await _captureDone?.future;
      if (!mounted || _captureOpen) return;
      _captureOpen = true;
      _captureDone = Completer<void>();
      try {
        await captureCameraEntry(
          context,
          service: _capture,
          currency: currency,
          onThingsChanged: _loadEntries,
          recoveredPhotoPaths: photos,
        );
      } finally {
        _captureOpen = false;
        _captureDone?.complete();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not recover the interrupted photo. Take it again from Add.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _reloadAll() async {
    await Future.wait([_loadEntries(), _loadMoney(), _loadCurrency()]);
  }

  Future<void> _openArchive() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArchiveScreen(database: _database),
      ),
    );
    if (mounted) await _loadEntries();
  }

  Future<void> _completeThing(Thing entry) async {
    try {
      await ThingsRepository(_database).setCompleted(entry.id, true);
      await _loadEntries();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not complete this item. Try again.'),
          ),
        );
      }
    }
  }

  Widget _viewFor(int index) => index == 0
      ? HomeDashboard(
          currency: currency,
          onOpenMoney: _openMoney,
          entries: entries,
          reminderPreferences: reminderPreferences,
          moneyEntries: moneyEntries,
          query: searchQuery,
          onQueryChanged: (value) => setState(() => searchQuery = value),
          onSearchTap: () => _openSearch(context),
          onOpenUpcoming: () => _goToPage(3),
          onOpenThings: () => _goToPage(1),
          onOpenThing: _openThing,
          onSettingsTap: () => _goToPage(4),
          onOpenMoneySection: () => _goToPage(2),
          onCompleteThing: (entry) => unawaited(_completeThing(entry)),
        )
      : index == 4
      ? SettingsScreen(
          database: _database,
          onDataChanged: () => unawaited(_reloadAll()),
          onOpenArchive: () => unawaited(_openArchive()),
          currency: currency,
          onCurrencyChanged: (value) async {
            setState(() => currency = value);
            await _repository.saveCurrency(value);
          },
        )
      : HomeSectionPage(
          database: _database,
          currency: currency,
          index: index,
          entries: entries,
          reminderPreferences: reminderPreferences,
          moneyEntries: moneyEntries,
          onMoneyChanged: _loadMoney,
          onThingTap: _openThing,
          query: searchQuery,
          onQueryChanged: (value) => setState(() => searchQuery = value),
          onSearchTap: () => _openSearch(context),
        );

  Future<void> _openMoney(MoneyEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoneyDetailScreen(entry: entry, database: _database),
      ),
    );
    await _loadMoney();
  }

  Future<void> _openNotification(String payload) async {
    final parts = payload.split(':');
    final id = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (id == null || !mounted) return;
    if (parts[0] == 'thing') {
      final thing = await ThingsRepository(_database).find(id);
      if (mounted && thing != null) await _openThing(thing);
    } else if (parts[0] == 'money') {
      final records = await _database.allMoney();
      final matches = records.where((entry) => entry.id == id);
      if (mounted && matches.isNotEmpty) await _openMoney(matches.first);
    }
  }

  Future<void> _openThing(Thing entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThingDetailScreen(entry: entry, database: _database),
      ),
    );
    await _loadEntries();
  }

  Future<void> _openSearch(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          things: entries,
          moneyEntries: moneyEntries,
          database: _database,
          onThingTap: _openThing,
        ),
      ),
    );
    await _loadEntries();
    await _loadMoney();
  }

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
    final loaded = await _repository.loadMoney();
    if (mounted) {
      setState(() => moneyEntries = loaded);
      await _loadReminderPreferences();
      await _updateHomeWidget();
    }
  }

  Future<void> _loadReminderPreferences() async {
    final store = ReminderPreferencesStore(_database);
    final values = <String, ReminderPreferences>{};
    for (final thing in entries) {
      values['thing:${thing.id}'] = await store.read('thing', thing.id);
    }
    for (final money in moneyEntries) {
      values['money:${money.id}'] = await store.read('money', money.id);
    }
    if (mounted) setState(() => reminderPreferences = values);
  }

  Future<void> _updateHomeWidget() async {
    final upcoming = <(DateTime, String)>[
      for (final item in entries)
        if (item.isActive &&
            item.reminderDate != null &&
            item.reminderDate!.isAfter(DateTime.now()))
          (item.reminderDate!, item.title),
      for (final item in moneyEntries)
        if (!item.settled &&
            item.dueDate != null &&
            item.dueDate!.isAfter(DateTime.now()))
          (item.dueDate!, item.person),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    final next = upcoming.isEmpty
        ? 'No upcoming reminders'
        : '${upcoming.first.$2}\n${upcoming.first.$1.toLocal().toString().substring(0, 16)}';
    await _homeWidget.update(name: userName, upcoming: next);
  }

  Future<void> _loadCurrency() async {
    final saved = await _repository.loadCurrency() ?? 'INR';
    final savedName = await _database.setting('user_name') ?? '';
    if (mounted) {
      setState(() {
        currency = saved;
        userName = savedName;
      });
      await _updateHomeWidget();
    }
  }

  Future<void> _loadEntries() async {
    final loaded = await _repository.loadThings();
    if (mounted) {
      setState(() => entries = loaded);
      await _loadReminderPreferences();
      await _updateHomeWidget();
    }
  }

  @override
  Widget build(BuildContext context) => HomeScaffold(
    userName: userName,
    selected: selected,
    pageController: _pageController,
    onSelected: (value) => setState(() => selected = value),
    viewFor: _viewFor,
    onAdd: () => _showUnifiedAddSheet(context),
    onSearch: () => _openSearch(context),
  );

  Future<void> _showUnifiedAddSheet(
    BuildContext context, {
    PaymentScreenshotData? paymentScreenshot,
  }) async {
    if (_captureOpen || !mounted) return;
    _captureOpen = true;
    _captureDone = Completer<void>();
    try {
      await showAddEntrySheet(
        context,
        service: _capture,
        currency: currency,
        onThingsChanged: _loadEntries,
        onMoneyChanged: _loadMoney,
        paymentScreenshot: paymentScreenshot,
        onTakePhoto: () => captureCameraEntry(
          context,
          service: _capture,
          currency: currency,
          onThingsChanged: _loadEntries,
        ),
      );
    } finally {
      _captureOpen = false;
      _captureDone?.complete();
    }
  }
}
