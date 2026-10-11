import 'package:flutter/material.dart';

final checklistLine = RegExp(r'^( *)- \[([ xX])\] (.*)$');

(int, int) checklistProgress(String text) {
  final items = text
      .split('\n')
      .map(checklistLine.firstMatch)
      .whereType<RegExpMatch>();
  return (items.where((m) => m.group(2) != ' ').length, items.length);
}

/// Small, offline formatting vocabulary: headings, bold, italic and underline.
class FormattedNoteText extends StatelessWidget {
  final String text;
  final bool completed;
  const FormattedNoteText(this.text, {super.key, this.completed = false});
  @override
  Widget build(BuildContext context) {
    final heading = text.startsWith('# ');
    final source = heading ? text.substring(2) : text;
    final pattern = RegExp(r'(\*\*.+?\*\*|__.+?__|\*[^*]+\*)');
    final spans = <TextSpan>[];
    var offset = 0;
    for (final match in pattern.allMatches(source)) {
      spans.add(TextSpan(text: source.substring(offset, match.start)));
      final token = match.group(0)!;
      final bold = token.startsWith('**');
      final underline = token.startsWith('__');
      final trim = bold || underline ? 2 : 1;
      spans.add(
        TextSpan(
          text: token.substring(trim, token.length - trim),
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : null,
            fontStyle: !bold && !underline ? FontStyle.italic : null,
            decoration: underline ? TextDecoration.underline : null,
          ),
        ),
      );
      offset = match.end;
    }
    spans.add(TextSpan(text: source.substring(offset)));
    return Text.rich(
      TextSpan(children: spans),
      style: TextStyle(
        fontSize: heading ? 22 : null,
        fontWeight: heading ? FontWeight.w700 : null,
        decoration: completed ? TextDecoration.lineThrough : null,
      ),
    );
  }
}
