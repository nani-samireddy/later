import 'package:flutter/material.dart';

enum ThingStatus {
  active('Active'),
  completed('Completed'),
  archived('Archived');

  final String label;
  const ThingStatus(this.label);
}

class Thing {
  final int id;
  final ThingStatus status;
  final DateTime? completedAt;
  final DateTime? archivedAt;
  bool get isActive => status == ThingStatus.active;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final DateTime? reminderDate;
  final List<String> attachments;

  const Thing({
    this.id = 0,
    this.status = ThingStatus.active,
    this.completedAt,
    this.archivedAt,
    required this.title,
    this.description = '',
    required this.category,
    required this.icon,
    this.reminderDate,
    this.attachments = const [],
  });
}
