part of 'home_screen.dart';

/* ignore_for_file: non_const_argument_for_const_parameter */

typedef ThingRecord = Thing;

class _ThingRecordListTile extends StatelessWidget {
  final ThingRecord entry;
  const _ThingRecordListTile({required this.entry});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _ThingRecordDetailPage(entry: entry)),
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

class _ThingRecordDetailPage extends StatefulWidget {
  final ThingRecord entry;
  const _ThingRecordDetailPage({required this.entry});
  @override
  State<_ThingRecordDetailPage> createState() => __ThingRecordDetailPageState();
}

class __ThingRecordDetailPageState extends State<_ThingRecordDetailPage> {
  late String title;
  late String category;

  @override
  void initState() {
    super.initState();
    title = widget.entry.title;
    category = widget.entry.category;
  }

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
      actions: [
        IconButton(
          onPressed: () => _showEditDialog(context),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
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
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category,
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

  Future<void> _showEditDialog(BuildContext context) async {
    final title = TextEditingController(text: widget.entry.title);
    final category = TextEditingController(text: widget.entry.category);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isEmpty) return;
              this.title = title.text.trim();
              this.category = category.text.trim().isEmpty
                  ? 'General'
                  : category.text.trim();
              setState(() {});
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _AttachmentSection extends StatelessWidget {
  final ThingRecord entry;
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
  final List<ThingRecord> entries;
  final List<MoneyEntry> moneyEntries;
  const _UpcomingList({required this.entries, required this.moneyEntries});
  @override
  Widget build(BuildContext context) {
    final reminders = [
      ...entries
          .where((entry) => entry.reminderDate != null)
          .map(
            (entry) => _UpcomingItem(
              date: entry.reminderDate!,
              title: entry.title,
              subtitle: entry.category,
              icon: Icons.notifications_none_rounded,
            ),
          ),
      ...moneyEntries
          .where((entry) => entry.dueDate != null && !entry.settled)
          .map(
            (entry) => _UpcomingItem(
              date: entry.dueDate!,
              title:
                  '${entry.person} · ${entry.currency} ${entry.amount.toStringAsFixed(0)}',
              subtitle: entry.owedToMe ? 'Money owed to you' : 'Money you owe',
              icon: Icons.account_balance_wallet_rounded,
            ),
          ),
    ]..sort((a, b) => a.date.compareTo(b.date));
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
            (item) => _ReminderCard(
              icon: item.icon,
              color: const Color(0xFFE5ECF8),
              title: item.title,
              subtitle: '${_formatDate(item.date)} · ${item.subtitle}',
            ),
          )
          .toList(),
    );
  }
}

class _UpcomingItem {
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  const _UpcomingItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
