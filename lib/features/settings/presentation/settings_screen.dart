import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_service.dart';
import '../../backup/backup_screen.dart';
import '../../ai/presentation/local_ai_screen.dart';
import '../data/clear_data_service.dart';
import '../data/notification_preferences.dart';
import '../data/settings_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final String currency;
  final ValueChanged<String> onCurrencyChanged;
  final AppDatabase? database;
  final VoidCallback? onDataChanged;
  final VoidCallback? onOpenArchive;
  final VoidCallback? onOpenModels;
  const SettingsScreen({
    super.key,
    required this.currency,
    required this.onCurrencyChanged,
    this.database,
    this.onDataChanged,
    this.onOpenArchive,
    this.onOpenModels,
  });
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  final notifications = NotificationPreferences();
  TimeOfDay time = SettingsPreferences.defaultReminderTime;
  String permission = 'Checking…';
  String userName = '';
  bool? exact;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  Future<void> refresh() async {
    final db = widget.database;
    final saved = db == null
        ? time
        : await SettingsPreferences(db).reminderTime();
    final savedName = await db?.setting('user_name') ?? '';
    String status;
    bool? exactStatus;
    try {
      final enabled = await notifications.enabled();
      status = enabled == null
          ? 'Unavailable on this platform'
          : enabled
          ? 'Enabled'
          : 'Disabled · enable in device Settings if denied';
      exactStatus = await notifications.exactEnabled();
    } catch (_) {
      status = 'Unable to check permissions';
    }
    if (mounted) {
      setState(() {
        userName = savedName;
        time = saved;
        permission = status;
        exact = exactStatus;
      });
    }
  }

  Future<void> run(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
      await refresh();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is ClearDataFileCleanupException
                  ? 'Records and reminders cleared. Attached files could not be removed; retry Clear all data.'
                  : 'Could not finish. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all Later data?'),
        content: const Text(
          'Permanently delete all entries, repayments, archived items, attached files, reminders and preferences. Export a backup first. Exported backups and downloaded AI models are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete all data'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await run(() async {
      try {
        await ClearDataService(widget.database!).clear();
      } finally {
        // Refresh even when file cleanup fails after the database was cleared.
        widget.onDataChanged?.call();
      }
      widget.onCurrencyChanged('INR');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All Later data cleared.')),
        );
      }
    });
  }

  Future<void> editName() async {
    final controller = TextEditingController(text: userName);
    final route = DialogRoute<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Leave blank for “Hey there”',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    final saved = await Navigator.of(context).push(route);
    await route.completed;
    controller.dispose();
    if (saved != null && mounted) {
      await run(() => widget.database!.saveSetting('user_name', saved));
      widget.onDataChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      ListTile(
        title: const Text('Your name'),
        subtitle: Text(userName.isEmpty ? 'Not set' : userName),
        trailing: const Icon(Icons.edit_outlined),
        enabled: !busy && widget.database != null,
        onTap: editName,
      ),
      ListTile(
        title: const Text('Default currency'),
        subtitle: const Text('Used for new money entries'),
        trailing: DropdownButton<String>(
          value: widget.currency,
          items: const [
            DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
            DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
            DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
          ],
          onChanged: busy
              ? null
              : (value) {
                  if (value != null) widget.onCurrencyChanged(value);
                },
        ),
      ),
      ListTile(
        title: const Text('Default reminder time'),
        subtitle: Text(time.format(context)),
        enabled: !busy && widget.database != null,
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (picked != null && mounted) {
            await run(
              () =>
                  SettingsPreferences(widget.database!)
                      .saveReminderTime(picked),
            );
          }
        },
      ),
      ListTile(
        title: const Text('Notifications'),
        subtitle: Text(permission),
        trailing: IconButton(
          tooltip: 'Request notification permission',
          icon: const Icon(Icons.notifications_outlined),
          onPressed: busy ? null : () => run(notifications.request),
        ),
      ),
      if (notifications.supportsExactTiming)
        ListTile(
          title: const Text('Exact reminder timing'),
          subtitle: Text(
            exact == true
                ? 'Enabled'
                : 'Allow Android alarms for precise timing',
          ),
          onTap: busy
              ? null
              : () => run(NotificationService.requestExactTiming),
        ),
      ListTile(
        title: const Text('Local AI model'),
        trailing: const Icon(Icons.chevron_right),
        onTap: busy
            ? null
            : () {
                if (widget.onOpenModels != null) {
                  widget.onOpenModels!();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LocalAiScreen(),
                    ),
                  );
                }
              },
      ),
      const Divider(),
      if (widget.database != null)
        ListTile(
          title: const Text('Backup & restore'),
          trailing: const Icon(Icons.chevron_right),
          onTap: busy
              ? null
              : () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BackupScreen(
                        database: widget.database!,
                        onChanged: () {
                          widget.onDataChanged?.call();
                          refresh();
                        },
                      ),
                    ),
                  );
                  await refresh();
                },
        ),
      if (widget.onOpenArchive != null)
        ListTile(
          title: const Text('Archive'),
          trailing: const Icon(Icons.chevron_right),
          onTap: busy ? null : widget.onOpenArchive,
        ),
      if (widget.database != null)
        ListTile(
          title: Text(
            'Clear all data',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          enabled: !busy,
          onTap: clear,
        ),
      if (busy) const LinearProgressIndicator(),
    ],
  );
}
