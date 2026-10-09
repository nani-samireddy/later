import 'package:flutter/material.dart';

class SearchHeading extends StatelessWidget {
  final String text;
  const SearchHeading(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}
