import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart' hide Thing;
import '../../money/presentation/money_detail_screen.dart';
import '../../things/domain/thing.dart';

class SearchScreen extends StatefulWidget {
  final List<Thing> things;
  final List<MoneyEntry> moneyEntries;
  final AppDatabase database;
  final ValueChanged<Thing> onThingTap;
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
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool matches(String value) =>
      controller.text.trim().isEmpty ||
      value.toLowerCase().contains(controller.text.trim().toLowerCase());
  @override
  Widget build(BuildContext context) {
    final things = widget.things
        .where((item) => matches('${item.title} ${item.category}'))
        .toList();
    final money = widget.moneyEntries
        .where(
          (item) => matches('${item.person} ${item.reason} ${item.amount}'),
        )
        .toList();
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
          if (things.isNotEmpty) ...[
            const _Heading('Things'),
            ...things.map(
              (item) => ListTile(
                onTap: () => widget.onThingTap(item),
                leading: Icon(item.icon),
                title: Text(item.title),
                subtitle: Text(item.category),
              ),
            ),
          ],
          if (money.isNotEmpty) ...[
            const _Heading('Money'),
            ...money.map(
              (item) => ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MoneyDetailScreen(
                      entry: item,
                      database: widget.database,
                    ),
                  ),
                ),
                leading: Icon(
                  item.owedToMe
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                ),
                title: Text(item.person),
                subtitle: Text(item.reason),
                trailing: Text(
                  '${item.currency} ${item.amount.toStringAsFixed(0)}',
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

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}
