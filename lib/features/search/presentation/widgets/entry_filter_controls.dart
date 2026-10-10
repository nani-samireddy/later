import 'package:flutter/material.dart';

import '../../../things/domain/thing.dart';
import '../../domain/entry_filters.dart';

class EntryFilterControls extends StatefulWidget {
  final List<String> categories;
  final bool showThings;
  final bool showMoney;
  final ThingStatus? initialStatus;
  final EntryFilters? initialFilters;
  final ValueChanged<EntryFilters> onChanged;
  const EntryFilterControls({
    super.key,
    required this.categories,
    required this.onChanged,
    this.showThings = true,
    this.showMoney = true,
    this.initialStatus,
    this.initialFilters,
  });
  @override
  State<EntryFilterControls> createState() => _EntryFilterControlsState();
}

class _EntryFilterControlsState extends State<EntryFilterControls> {
  late String? category = widget.initialFilters?.category;
  late ThingStatus? status =
      widget.initialFilters?.status ?? widget.initialStatus;
  late MoneyType type = widget.initialFilters?.moneyType ?? MoneyType.all;
  late bool? settled = widget.initialFilters?.settled;
  late EntrySort sort = widget.initialFilters?.sort ?? EntrySort.newest;
  late DateTimeRange? range =
      widget.initialFilters?.start != null && widget.initialFilters?.end != null
      ? DateTimeRange(
          start: widget.initialFilters!.start!,
          end: widget.initialFilters!.end!,
        )
      : null;
  void emit() => widget.onChanged(
    EntryFilters(
      category: category,
      status: status,
      moneyType: type,
      settled: settled,
      sort: sort,
      start: range?.start,
      end: range?.end,
    ),
  );
  Widget menu<T>(
    String label,
    T value,
    Map<T, String> options,
    ValueChanged<T> changed,
  ) => PopupMenuButton<T>(
    tooltip: label,
    initialValue: value,
    onSelected: (v) {
      setState(() => changed(v));
      emit();
    },
    itemBuilder: (_) => options.entries
        .map(
          (e) => CheckedPopupMenuItem<T>(
            value: e.key,
            checked: e.key == value,
            child: Text(e.value),
          ),
        )
        .toList(),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text('$label: ${options[value]} ▾'),
    ),
  );
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 4,
    runSpacing: 4,
    children: [
      if (widget.showThings)
        menu<String>('Category', category ?? '', {
          '': 'All',
          for (final c in widget.categories) c: c,
        }, (v) => category = v.isEmpty ? null : v),
      if (widget.showThings)
        menu<String>('Status', status?.name ?? '', {
          '': 'All',
          for (final s in ThingStatus.values) s.name: s.label,
        }, (v) => status = v.isEmpty ? null : ThingStatus.values.byName(v)),
      if (widget.showMoney)
        menu<MoneyType>('Type', type, {
          MoneyType.all: 'All',
          MoneyType.owedToMe: 'Owed to me',
          MoneyType.iOwe: 'I owe',
          MoneyType.spending: 'Spending',
        }, (v) => type = v),
      if (widget.showMoney)
        menu<String>('Settlement', settled?.toString() ?? '', {
          '': 'All',
          'false': 'Unsettled',
          'true': 'Settled',
        }, (v) => settled = v.isEmpty ? null : v == 'true'),
      menu<EntrySort>('Sort', sort, {
        EntrySort.newest: 'Newest',
        EntrySort.title: 'Title',
        EntrySort.date: 'Reminder / due date',
        if (widget.showMoney) EntrySort.amount: 'Amount (high to low)',
      }, (v) => sort = v),
      TextButton.icon(
        icon: const Icon(Icons.date_range_outlined),
        label: Text(
          range == null
              ? (widget.showMoney ? 'Due / spending dates' : 'Reminder dates')
              : '${range!.start.month}/${range!.start.day}/${range!.start.year} – ${range!.end.month}/${range!.end.day}/${range!.end.year}',
        ),
        onPressed: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(1900),
            lastDate: DateTime(2200),
            initialDateRange: range,
          );
          if (picked != null && mounted) {
            setState(() => range = picked);
            emit();
          }
        },
      ),
      TextButton(
        onPressed: () {
          setState(() {
            category = null;
            status = widget.initialStatus;
            type = MoneyType.all;
            settled = null;
            sort = EntrySort.newest;
            range = null;
          });
          emit();
        },
        child: const Text('Reset filters'),
      ),
    ],
  );
}
