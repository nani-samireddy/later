import '../../home/data/home_repository.dart';
import 'widgets/search_heading.dart';
import 'widgets/entry_filter_sheet.dart';
import '../domain/entry_filters.dart';

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart' hide Thing;
import '../../money/presentation/money_detail_screen.dart';
import '../../things/domain/thing.dart';

class SearchScreen extends StatefulWidget {
  final List<Thing> things;
  final List<MoneyEntry> moneyEntries;
  final AppDatabase database;
  final Future<void> Function(Thing) onThingTap;
  const SearchScreen({
    super.key,
    required this.things,
    required this.moneyEntries,
    required this.database,
    required this.onThingTap,
  });
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  EntryFilters filters = const EntryFilters();
  final controller = TextEditingController();
  late List<Thing> _things = widget.things;
  late List<MoneyEntry> _money = widget.moneyEntries;
  Future<void> _openFilters() async {
    FocusScope.of(context).unfocus();
    final selected = await showEntryFilterSheet(
      context,
      filters: filters,
      categories: (_things.map((e) => e.category).toSet().toList()..sort()),
    );
    if (selected != null && mounted) setState(() => filters = selected);
  }

  Future<void> _reload() async {
    final repository = HomeRepository(widget.database);
    final things = await repository.loadThings();
    final money = await repository.loadMoney();
    if (mounted) {
      setState(() {
        _things = things;
        _money = money;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = EntryFilters(
      query: controller.text,
      category: filters.category,
      status: filters.status,
      moneyType: filters.moneyType,
      settled: filters.settled,
      start: filters.start,
      end: filters.end,
      sort: filters.sort,
    );
    final things = current.things(_things);
    final money = current.money(_money);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Search everything',
            border: InputBorder.none,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _openFilters,
              icon: const Icon(Icons.filter_list_rounded),
              label: Text(
                filters.category != null ||
                        filters.status != null ||
                        filters.moneyType != MoneyType.all ||
                        filters.settled != null ||
                        filters.start != null ||
                        filters.end != null ||
                        filters.sort != EntrySort.newest
                    ? 'Filter · active'
                    : 'Filter',
              ),
            ),
          ),
          if (things.isNotEmpty) ...[
            const SearchHeading('Things'),
            ...things.map(
              (item) => ListTile(
                onTap: () async {
                  await widget.onThingTap(item);
                  await _reload();
                },
                leading: Icon(item.icon),
                title: Text(item.title),
                subtitle: Text('${item.category} · ${item.status.label}'),
              ),
            ),
          ],
          if (money.isNotEmpty) ...[
            const SearchHeading('Money'),
            ...money.map(
              (item) => ListTile(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MoneyDetailScreen(
                        entry: item,
                        database: widget.database,
                      ),
                    ),
                  );
                  await _reload();
                },
                leading: Icon(
                  item.owedToMe
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                ),
                title: Text(item.person),
                subtitle: Text(item.reason),
                trailing: Text(
                  '${item.currency} ${item.amount.toStringAsFixed(2)}',
                ),
              ),
            ),
          ],
          if (things.isEmpty && money.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: Text('No matching items found')),
            ),
        ],
      ),
    );
  }
}
