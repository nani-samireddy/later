import 'package:flutter/material.dart';

class Thing {
  final String title;
  final String category;
  final IconData icon;
  final DateTime? reminderDate;
  final List<String> attachments;

  const Thing({
    required this.title,
    required this.category,
    required this.icon,
    this.reminderDate,
    this.attachments = const [],
  });
}
