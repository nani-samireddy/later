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
  int selected = 0;
  late final PageController _pageController;
  List<Thing> entries = [];
  List<MoneyEntry> moneyEntries = [];
  String searchQuery = '';
  String currency = 'INR';
  final AppDatabase _database = AppDatabase();
  late final HomeRepository _repository = HomeRepository(_database);
  late final EntryCaptureService _capture = EntryCaptureService(_database);
  final SharedPaymentService _sharedPayments = SharedPaymentService();

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
    _sharedPayments.dispose();
    _database.close();
    super.dispose();
  }

  Future<void> _listenForSharedPaymentScreenshots() =>
      _sharedPayments.start((parsed) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showUnifiedAddSheet(context, paymentScreenshot: parsed);
        });
      });

  Widget _viewFor(int index) => index == 0
      ? HomeDashboard(
          entries: entries,
          moneyEntries: moneyEntries,
          query: searchQuery,
          onQueryChanged: (value) => setState(() => searchQuery = value),
          onSearchTap: () => _openSearch(context),
          onOpenUpcoming: () => _goToPage(3),
          onOpenThings: () => _goToPage(1),
          onOpenThing: (entry) => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ThingDetailScreen(entry: entry)),
          ),
          onSettingsTap: () => _goToPage(4),
        )
      : index == 4
      ? SettingsScreen(
          currency: currency,
          onCurrencyChanged: (value) async {
            setState(() => currency = value);
            await _repository.saveCurrency(value);
          },
        )
      : HomeSectionPage(
          database: _database,
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
        database: _database,
        onThingTap: (thing) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ThingDetailScreen(entry: thing)),
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
    final loaded = await _repository.loadMoney();
    if (mounted) setState(() => moneyEntries = loaded);
  }

  Future<void> _loadCurrency() async {
    final saved = await _repository.loadCurrency();
    if (mounted && saved != null) setState(() => currency = saved);
  }

  Future<void> _loadEntries() async {
    final loaded = await _repository.loadThings();
    if (mounted) setState(() => entries = loaded);
  }

  @override
  Widget build(BuildContext context) => HomeScaffold(
    selected: selected,
    pageController: _pageController,
    onSelected: (value) => setState(() => selected = value),
    viewFor: _viewFor,
    onAdd: () => _showUnifiedAddSheet(context),
  );

  Future<void> _showUnifiedAddSheet(
    BuildContext context, {
    PaymentScreenshotData? paymentScreenshot,
  }) => showAddEntrySheet(
    context,
    service: _capture,
    currency: currency,
    onThingsChanged: _loadEntries,
    onMoneyChanged: _loadMoney,
    paymentScreenshot: paymentScreenshot,
  );
}
