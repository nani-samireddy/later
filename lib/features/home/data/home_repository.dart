import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart' hide Thing;
import '../../../core/notifications/notification_service.dart';
import '../../things/domain/thing.dart';

class HomeRepository {
  final AppDatabase database;
  HomeRepository(this.database);
  Future<List<MoneyEntry>> loadMoney() async {
    final loaded = await database.allMoney();
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
    return loaded;
  }

  Future<List<Thing>> loadThings() async {
    final stored = await database.allThings();
    final loaded = stored
        .map(
          (thing) => Thing(
            title: thing.title,
            category: thing.category,
            icon: Icons.bookmark_outline_rounded,
            reminderDate: thing.reminderDate,
          ),
        )
        .toList();
    return loaded.isEmpty ? _seedEntries() : loaded;
  }

  Future<String?> loadCurrency() => database.setting('currency');
  Future<void> saveCurrency(String currency) =>
      database.saveSetting('currency', currency);
  List<Thing> _seedEntries() => [
    Thing(
      title: 'LG Refrigerator',
      category: 'Appliance',
      icon: Icons.kitchen_outlined,
      reminderDate: DateTime(2026, 9, 18),
    ),
    const Thing(
      title: 'Electricity Bill',
      category: 'Document',
      icon: Icons.receipt_long_outlined,
    ),
    const Thing(
      title: 'Bosch Drill',
      category: 'Tool',
      icon: Icons.handyman_outlined,
    ),
  ];
}
