import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';

final appDatabase = AppDatabase();

void main() => runApp(const LaterApp());

class LaterApp extends StatelessWidget {
  const LaterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Later',
    theme: buildAppTheme(),
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
  String currency = 'INR';
  List<_Entry> entries = [];
  List<_MoneyRecord> money = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _loadMoney();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final value = await appDatabase.setting('currency') ?? 'INR';
    if (mounted) setState(() => currency = value);
  }

  Future<void> _loadMoney() async {
    final stored = await appDatabase.allMoney();
    if (mounted)
      setState(
        () => money = stored
            .map(
              (item) => _MoneyRecord(
                person: item.person,
                amount: item.amount,
                currency: item.currency,
                reason: item.reason,
                owedToMe: item.owedToMe,
                dueDate: item.dueDate,
                settled: item.settled,
              ),
            )
            .toList(),
      );
  }

  Future<void> _setCurrency(String value) async {
    await appDatabase.saveSetting('currency', value);
    if (mounted) setState(() => currency = value);
  }

  Future<void> _loadEntries() async {
    final stored = await appDatabase.allThings();
    final loaded = stored
        .map(
          (thing) => _Entry(
            title: thing.title,
            category: thing.category,
            icon: _iconFromJson(thing.iconCodePoint),
            reminderDate: thing.reminderDate,
          ),
        )
        .toList();
    if (!mounted) return;
    setState(() {
      entries = loaded.isEmpty ? _seedEntries() : loaded;
    });
  }

  List<_Entry> _seedEntries() => [
    _Entry(
      title: 'LG Refrigerator',
      category: 'Appliance',
      icon: Icons.kitchen_outlined,
      reminderDate: DateTime(2026, 9, 18),
    ),
    const _Entry(
      title: 'Electricity Bill',
      category: 'Document',
      icon: Icons.receipt_long_outlined,
    ),
    const _Entry(
      title: 'Bosch Drill',
      category: 'Tool',
      icon: Icons.handyman_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Row(
        children: [
          NavigationRail(
            selectedIndex: selected,
            onDestinationSelected: (value) => setState(() => selected = value),
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
          Expanded(
            child: selected == 0
                ? _Dashboard(entries: entries)
                : selected == 4
                ? _SettingsPage(
                    currency: currency,
                    onCurrencyChanged: _setCurrency,
                  )
                : _SectionPage(
                    index: selected,
                    entries: entries,
                    currency: currency,
                    money: money,
                  ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showAddSheet(context),
      backgroundColor: const Color(0xFF34725F),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
    ),
  );

  void _showAddSheet(BuildContext context) => showModalBottomSheet<void>(
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
                icon: Icons.mic_none_rounded,
                label: 'Speak',
                color: Color(0xFFE4F1EB),
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
              _CaptureOption(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Money',
                color: Color(0xFFE5ECF8),
                onTap: () {
                  Navigator.pop(context);
                  _showMoneyDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );

  void _showMoneyDialog(BuildContext context) {
    final person = TextEditingController();
    final amount = TextEditingController();
    final reason = TextEditingController();
    bool owedToMe = true;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add money'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: person,
                decoration: const InputDecoration(labelText: 'Person'),
              ),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount ($currency)'),
              ),
              TextField(
                controller: reason,
                decoration: const InputDecoration(labelText: 'Reason'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(owedToMe ? 'They owe me' : 'I owe them'),
                value: owedToMe,
                onChanged: (value) => setDialogState(() => owedToMe = value),
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
                final value = double.tryParse(amount.text);
                if (person.text.trim().isEmpty || value == null) return;
                await appDatabase.addMoney(
                  MoneyEntriesCompanion.insert(
                    person: person.text.trim(),
                    amount: value,
                    currency: currency,
                    reason: Value(reason.text.trim()),
                    owedToMe: owedToMe,
                  ),
                );
                await _loadMoney();
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
                    _Entry(
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

class _Dashboard extends StatelessWidget {
  final List<_Entry> entries;
  const _Dashboard({required this.entries});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(34, 30, 34, 110),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'What should you know\nright now?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search_rounded, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Owed to you',
                    value: '₹12,400',
                    icon: Icons.arrow_downward_rounded,
                    tint: Color(0xFFE2F1E7),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _SummaryCard(
                    title: 'You owe',
                    value: '₹6,200',
                    icon: Icons.arrow_upward_rounded,
                    tint: Color(0xFFFFEBDD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const _SectionHeader(title: 'Coming up', action: 'View all'),
            const SizedBox(height: 12),
            const _ReminderCard(
              icon: Icons.account_balance_wallet_rounded,
              color: Color(0xFFE2F1E7),
              title: 'Ravi owes you ₹800',
              subtitle: 'Tomorrow · Money',
            ),
            const _ReminderCard(
              icon: Icons.shield_outlined,
              color: Color(0xFFFFEBDD),
              title: 'Bike insurance expires',
              subtitle: 'In 5 days · Document',
            ),
            const _ReminderCard(
              icon: Icons.water_drop_outlined,
              color: Color(0xFFE5ECF8),
              title: 'RO filter replacement',
              subtitle: '18 Sep · Maintenance',
            ),
            const SizedBox(height: 26),
            const _SectionHeader(title: 'Recently added', action: 'See all'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...entries
                    .take(4)
                    .map(
                      (entry) => _RecentCard(
                        icon: entry.icon,
                        title: entry.title,
                        detail: entry.category,
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionPage extends StatelessWidget {
  final int index;
  final List<_Entry> entries;
  final String currency;
  final List<_MoneyRecord> money;
  const _SectionPage({
    required this.index,
    required this.entries,
    required this.currency,
    required this.money,
  });
  @override
  Widget build(BuildContext context) {
    final title = ['Home', 'Things', 'Money', 'Upcoming'][index];
    final copy = index == 1
        ? 'Everything you want to find again.'
        : index == 2
        ? 'Keep track of what matters, simply.'
        : 'One timeline for everything with a date.';
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(copy, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 30),
          if (index == 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Pill(label: 'Appliances', icon: Icons.kitchen_outlined),
                    _Pill(label: 'Documents', icon: Icons.description_outlined),
                    _Pill(label: 'Medicines', icon: Icons.medication_outlined),
                    _Pill(label: 'Tools', icon: Icons.handyman_outlined),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '${entries.length} items',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...entries.map((entry) => _EntryListTile(entry: entry)),
              ],
            )
          else if (index == 2)
            _MoneyList(records: money, currency: currency)
          else if (index == 3)
            _UpcomingList(entries: entries)
          else
            const _EmptyState(
              icon: Icons.event_available_outlined,
              title: 'Your timeline is clear',
              body: 'Dates from your entries will appear here.',
            ),
        ],
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  final String currency;
  final ValueChanged<String> onCurrencyChanged;
  const _SettingsPage({
    required this.currency,
    required this.onCurrencyChanged,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(36),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Set your preferences once.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Default currency',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text('Used for new money entries'),
                ],
              ),
              DropdownButton<String>(
                value: currency,
                items: const [
                  DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
                  DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
                  DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
                ],
                onChanged: (value) {
                  if (value != null) onCurrencyChanged(value);
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MoneyRecord {
  final String person, currency, reason;
  final double amount;
  final bool owedToMe, settled;
  final DateTime? dueDate;
  const _MoneyRecord({
    required this.person,
    required this.amount,
    required this.currency,
    required this.reason,
    required this.owedToMe,
    this.dueDate,
    required this.settled,
  });
}

class _MoneyList extends StatelessWidget {
  final List<_MoneyRecord> records;
  final String currency;
  const _MoneyList({required this.records, required this.currency});
  @override
  Widget build(BuildContext context) {
    if (records.isEmpty)
      return _EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Money is ready for $currency',
        body: 'Tap Add → Money to record an IOU.',
      );
    final owed = records
        .where((item) => item.owedToMe && !item.settled)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final owing = records
        .where((item) => !item.owedToMe && !item.settled)
        .fold<double>(0, (sum, item) => sum + item.amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Owed to you',
                value: '$currency ${owed.toStringAsFixed(0)}',
                icon: Icons.arrow_downward_rounded,
                tint: const Color(0xFFE2F1E7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'You owe',
                value: '$currency ${owing.toStringAsFixed(0)}',
                icon: Icons.arrow_upward_rounded,
                tint: const Color(0xFFFFEBDD),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...records.map(
          (item) => Card(
            elevation: 0,
            color: Colors.white,
            child: ListTile(
              leading: Icon(
                item.owedToMe
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: item.owedToMe
                    ? const Color(0xFF34725F)
                    : Colors.deepOrange,
              ),
              title: Text(
                item.person,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                item.reason.isEmpty
                    ? (item.owedToMe ? 'Owes you' : 'You owe')
                    : item.reason,
              ),
              trailing: Text(
                '$currency ${item.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Entry {
  final String title;
  final String category;
  final IconData icon;
  final DateTime? reminderDate;
  final List<String> attachments;
  const _Entry({
    required this.title,
    required this.category,
    required this.icon,
    this.reminderDate,
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'icon': icon.codePoint,
    'reminderDate': reminderDate?.toIso8601String(),
    'attachments': attachments,
  };

  factory _Entry.fromJson(Map<String, dynamic> json) => _Entry(
    title: json['title'] as String? ?? 'Untitled',
    category: json['category'] as String? ?? 'General',
    icon: _iconFromJson(json['icon'] as int?),
    reminderDate: json['reminderDate'] == null
        ? null
        : DateTime.tryParse(json['reminderDate'] as String),
    attachments: List<String>.from(json['attachments'] as List? ?? const []),
  );
}

IconData _iconFromJson(int? codePoint) =>
    IconData(codePoint ?? 0xe88a, fontFamily: 'MaterialIcons');

class _EntryListTile extends StatelessWidget {
  final _Entry entry;
  const _EntryListTile({required this.entry});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _EntryDetailPage(entry: entry)),
      ),
      leading: Icon(entry.icon, color: const Color(0xFF34725F)),
      title: Text(
        entry.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(entry.category),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _EntryDetailPage extends StatefulWidget {
  final _Entry entry;
  const _EntryDetailPage({required this.entry});
  @override
  State<_EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<_EntryDetailPage> {
  Future<void> _addAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result == null) return;
    setState(
      () => widget.entry.attachments.addAll(
        result.files.map((file) => file.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Thing'),
      backgroundColor: Colors.transparent,
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE4F1EB),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.entry.icon, size: 42, color: const Color(0xFF34725F)),
              const SizedBox(height: 22),
              Text(
                widget.entry.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.entry.category,
                style: const TextStyle(
                  color: Color(0xFF34725F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _DetailSection(
          title: 'Record',
          rows: {
            'Added': 'Today',
            'Location': 'Not added yet',
            'Notes': 'No notes yet',
            if (widget.entry.reminderDate != null)
              'Reminder': _formatDate(widget.entry.reminderDate!),
          },
        ),
        const SizedBox(height: 16),
        _AttachmentSection(
          entry: widget.entry,
          onAdd: _addAttachment,
          onRemove: (name) =>
              setState(() => widget.entry.attachments.remove(name)),
        ),
        const SizedBox(height: 16),
        const _DetailSection(
          title: 'History',
          rows: {'Today': 'Entry created'},
        ),
      ],
    ),
  );
}

class _AttachmentSection extends StatelessWidget {
  final _Entry entry;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  const _AttachmentSection({
    required this.entry,
    required this.onAdd,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attachments',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(
                Icons.attach_file_rounded,
                color: Color(0xFF34725F),
              ),
            ),
          ],
        ),
        if (entry.attachments.isEmpty)
          const Text('Add images, PDFs, receipts, or other documents.'),
        ...entry.attachments.map(
          (name) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.insert_drive_file_outlined,
              color: Color(0xFF34725F),
            ),
            title: Text(name),
            trailing: IconButton(
              onPressed: () => onRemove(name),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ),
      ],
    ),
  );
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Map<String, String> rows;
  const _DetailSection({required this.title, required this.rows});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...rows.entries.map(
          (row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(row.key, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  row.value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _UpcomingList extends StatelessWidget {
  final List<_Entry> entries;
  const _UpcomingList({required this.entries});
  @override
  Widget build(BuildContext context) {
    final reminders = entries
        .where((entry) => entry.reminderDate != null)
        .toList();
    if (reminders.isEmpty) {
      return const _EmptyState(
        icon: Icons.event_available_outlined,
        title: 'Your timeline is clear',
        body: 'Dates from your entries will appear here.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reminders
          .map(
            (entry) => _ReminderCard(
              icon: Icons.notifications_none_rounded,
              color: const Color(0xFFE5ECF8),
              title: entry.title,
              subtitle:
                  '${_formatDate(entry.reminderDate!)} · ${entry.category}',
            ),
          )
          .toList(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color tint;
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: const Color(0xFF34725F)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ReminderCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _ReminderCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF34725F)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _RecentCard extends StatelessWidget {
  final IconData icon;
  final String title, detail;
  const _RecentCard({
    required this.icon,
    required this.title,
    required this.detail,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: 190,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF34725F)),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(detail, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title, action;
  const _SectionHeader({required this.title, required this.action});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      Text(
        action,
        style: const TextStyle(
          color: Color(0xFF34725F),
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _CaptureOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _CaptureOption({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF34725F), size: 27),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Pill({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 18, color: const Color(0xFF34725F)),
    label: Text(label),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    backgroundColor: Colors.white,
    side: BorderSide.none,
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Icon(icon, size: 42, color: const Color(0xFF34725F)),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(body, textAlign: TextAlign.center),
      ],
    ),
  );
}
