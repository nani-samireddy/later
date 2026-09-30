import 'package:flutter/material.dart';

import '../domain/thing.dart';

class ThingsListScreen extends StatelessWidget {
  final List<Thing> things;
  const ThingsListScreen({super.key, required this.things});
  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(24),
    itemCount: things.length,
    itemBuilder: (_, index) {
      final thing = things[index];
      return Card(
        elevation: 0,
        child: ListTile(
          leading: Icon(thing.icon),
          title: Text(thing.title),
          subtitle: Text(thing.category),
        ),
      );
    },
  );
}
