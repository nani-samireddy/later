import 'package:flutter/material.dart';

class UpcomingListScreen extends StatelessWidget {
  final List<Widget> items;
  const UpcomingListScreen({super.key, required this.items});
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(24), children: items);
}
