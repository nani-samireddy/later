import 'package:flutter/material.dart';

import 'note_format.dart';
export 'note_format.dart' show checklistLine, checklistProgress;

/// Checklists are portable text inside the existing note body.

class NoteBodyEditor extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  const NoteBodyEditor({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<NoteBodyEditor> createState() => _NoteBodyEditorState();
}

class _NoteRow {
  final TextEditingController text;
  bool checked;
  int depth;
  final focus = FocusNode();
  _NoteRow(String value, this.checked, [this.depth = 0])
    : text = TextEditingController(text: value);
}

class _NoteBodyEditorState extends State<NoteBodyEditor> {
  bool checklist = false;
  final rows = <_NoteRow>[];

  @override
  void initState() {
    super.initState();
    if (widget.controller.text
        .split('\n')
        .any((line) => checklistLine.hasMatch(line))) {
      checklist = true;
      _loadRows();
    }
  }

  void _loadRows() {
    for (final line in widget.controller.text.split('\n')) {
      final match = checklistLine.firstMatch(line);
      rows.add(
        _NoteRow(
          match?.group(3) ?? line,
          match != null && match.group(2) != ' ',
          match == null ? 0 : (match.group(1)!.length ~/ 2).clamp(0, 3),
        ),
      );
    }
  }

  void _sync() {
    widget.controller.text = rows
        .where((row) => row.text.text.trim().isNotEmpty)
        .map(
          (row) =>
              '${'  ' * row.depth}- [${row.checked ? 'x' : ' '}] ${row.text.text}',
        )
        .join('\n');
    widget.onChanged?.call(widget.controller.text);
  }

  void _toggleMode() {
    setState(() {
      if (checklist) {
        widget.controller.text = rows.map((row) => row.text.text).join('\n');
        for (final row in rows) {
          row.text.dispose();
          row.focus.dispose();
        }
        rows.clear();
      } else {
        _loadRows();
        _sync();
      }
      checklist = !checklist;
      widget.onChanged?.call(widget.controller.text);
    });
  }

  void _add([int? after]) {
    setState(
      () => rows.insert(
        after == null ? rows.length : after + 1,
        _NoteRow('', false),
      ),
    );
    _sync();
    final added = rows[after == null ? rows.length - 1 : after + 1];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) added.focus.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final row in rows) {
      row.text.dispose();
      row.focus.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!checklist) ...[
        Wrap(
          children: [
            for (final format in ['Bold', 'Italic', 'Underline', 'Heading'])
              TextButton(
                onPressed: !widget.enabled
                    ? null
                    : () {
                        final controller = widget.controller;
                        final selected = controller.selection;
                        final start = selected.isValid
                            ? selected.start
                            : controller.text.length;
                        final end = selected.isValid ? selected.end : start;
                        final marker = {
                          'Bold': '**',
                          'Italic': '*',
                          'Underline': '__',
                          'Heading': '# ',
                        }[format]!;
                        final content = controller.text.substring(start, end);
                        final inserted = format == 'Heading'
                            ? marker + content
                            : marker + content + marker;
                        controller.value = TextEditingValue(
                          text: controller.text.replaceRange(
                            start,
                            end,
                            inserted,
                          ),
                          selection: TextSelection.collapsed(
                            offset: start + inserted.length,
                          ),
                        );
                        widget.onChanged?.call(controller.text);
                      },
                child: Text(format),
              ),
          ],
        ),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          minLines: 3,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Note (optional)',
            hintText: 'Write anything you want to remember',
          ),
        ),
      ] else ...[
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) {
            if (!widget.enabled) return;
            setState(() {
              rows.insert(newIndex, rows.removeAt(oldIndex));
            });
            _sync();
          },
          children: [
            for (var i = 0; i < rows.length; i++)
              Padding(
                key: ObjectKey(rows[i]),
                padding: EdgeInsets.only(left: rows[i].depth * 12.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: rows[i].checked,
                      onChanged: !widget.enabled
                          ? null
                          : (value) {
                              setState(() => rows[i].checked = value!);
                              _sync();
                            },
                    ),
                    Expanded(
                      child: TextField(
                        controller: rows[i].text,
                        focusNode: rows[i].focus,
                        enabled: widget.enabled,
                        decoration: const InputDecoration(
                          hintText: 'List item',
                        ),
                        style: TextStyle(
                          decoration: rows[i].checked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        onChanged: (_) => _sync(),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _add(i),
                      ),
                    ),
                    if (widget.enabled)
                      ReorderableDragStartListener(
                        index: i,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.drag_handle, size: 20),
                        ),
                      ),
                    PopupMenuButton<String>(
                      tooltip: 'List item options',
                      enabled: widget.enabled,
                      onSelected: (action) {
                        setState(() {
                          if (action == 'Indent') {
                            rows[i].depth = (rows[i].depth + 1).clamp(0, 3);
                          }
                          if (action == 'Outdent') {
                            rows[i].depth = (rows[i].depth - 1).clamp(0, 3);
                          }
                        });
                        _sync();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'Indent',
                          enabled: i > 0 && rows[i].depth < 3,
                          child: const Text('Indent'),
                        ),
                        PopupMenuItem(
                          value: 'Outdent',
                          enabled: rows[i].depth > 0,
                          child: const Text('Outdent'),
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Delete list item',
                      icon: const Icon(Icons.close),
                      onPressed: !widget.enabled
                          ? null
                          : () {
                              final removed = rows[i];
                              setState(() => rows.removeAt(i));
                              // Dispose after the field has left the widget tree.
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                removed.text.dispose();
                                removed.focus.dispose();
                              });
                              _sync();
                            },
                    ),
                  ],
                ),
              ),
          ],
        ),
        TextButton.icon(
          onPressed: widget.enabled ? () => _add() : null,
          icon: const Icon(Icons.add),
          label: const Text('Add list item'),
        ),
      ],
      TextButton.icon(
        onPressed: widget.enabled ? _toggleMode : null,
        icon: Icon(checklist ? Icons.notes : Icons.checklist),
        label: Text(checklist ? 'Hide checkboxes' : 'Show checkboxes'),
      ),
    ],
  );
}

class NoteBodyView extends StatelessWidget {
  final String text;
  final ValueChanged<String>? onChanged;
  const NoteBodyView({super.key, required this.text, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines.length; i++)
          if (checklistLine.firstMatch(lines[i]) case final match?)
            CheckboxListTile(
              contentPadding: EdgeInsets.only(
                left: (match.group(1)!.length ~/ 2).clamp(0, 3) * 12.0,
              ),
              controlAffinity: ListTileControlAffinity.leading,
              value: match.group(2) != ' ',
              title: FormattedNoteText(
                match.group(3)!,
                completed: match.group(2) != ' ',
              ),
              onChanged: onChanged == null
                  ? null
                  : (checked) {
                      final updated = [...lines];
                      updated[i] =
                          '${match.group(1)}- [${checked! ? 'x' : ' '}] ${match.group(3)}';
                      onChanged!(updated.join('\n'));
                    },
            )
          else
            FormattedNoteText(lines[i]),
      ],
    );
  }
}
