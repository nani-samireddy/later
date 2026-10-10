import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart' hide Thing;
import '../../../core/widgets/empty_state.dart';
import '../data/things_repository.dart';
import '../domain/thing.dart';
import 'thing_detail_screen.dart';
import 'widgets/thing_list_tile.dart';

class ArchiveScreen extends StatefulWidget {
  final AppDatabase database;
  const ArchiveScreen({super.key, required this.database});
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late Future<List<Thing>> entries = _load();
  Future<List<Thing>> _load() async => (await ThingsRepository(
    widget.database,
  ).all()).where((entry) => entry.status == ThingStatus.archived).toList();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Archive')),
    body: FutureBuilder<List<Thing>>(
      future: entries,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: () => setState(() => entries = _load()),
              child: const Text('Could not load archive. Retry'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data!;
        if (records.isEmpty) {
          return const EmptyState(
            icon: Icons.archive_outlined,
            title: 'Your archive is empty',
            body: 'Archived things stay here until you need them again.',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: records
              .map(
                (entry) => ThingListTile(
                  entry: entry,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ThingDetailScreen(
                          entry: entry,
                          database: widget.database,
                        ),
                      ),
                    );
                    if (mounted) setState(() => entries = _load());
                  },
                ),
              )
              .toList(),
        );
      },
    ),
  );
}
