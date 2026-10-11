import 'package:flutter/material.dart';

import 'note_format.dart';
export 'note_format.dart' show checklistLine, checklistProgress;

/// Checklists are portable text inside the existing note body.

class NoteBodyEditor extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final bool compact;
  final bool hideControls;
  const NoteBodyEditor({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onChanged,
    this.compact = false,
    this.hideControls = false,
  });

  @override
  State<NoteBodyEditor> createState() => NoteBodyEditorState();
}

class _NoteRow {
  final TextEditingController text;
  bool checked;
  int depth;
  final focus = FocusNode();
  _NoteRow(String value, this.checked, [this.depth = 0])
    : text = TextEditingController(text: value);
}

class NoteBodyEditorState extends State<NoteBodyEditor> {
  bool checklist = false;
  bool _writingBody = false;
  late String _lastBody;
  final rows = <_NoteRow>[];

  @override
  void initState() {
    super.initState();
    _lastBody = widget.controller.text;
    widget.controller.addListener(_bodyChanged);
    if (widget.controller.text
        .split('\n')
        .any((line) => checklistLine.hasMatch(line))) {
      checklist = true;
      _loadRows();
    }
  }

  void _bodyChanged() {
    final text = widget.controller.text;
    if (_writingBody || text == _lastBody) return;
    _lastBody = text;
    if (!checklist && !text.split('\n').any(checklistLine.hasMatch)) return;
    final previous = [...rows];
    setState(() {
      rows.clear();
      checklist = text.split('\n').any(checklistLine.hasMatch);
      if (checklist) _loadRows();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final row in previous) {
        row.text.dispose();
        row.focus.dispose();
      }
    });
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
    _writingBody = true;
    widget.controller.text = rows
        .where((row) => row.text.text.trim().isNotEmpty)
        .map(
          (row) =>
              '${'  ' * row.depth}- [${row.checked ? 'x' : ' '}] ${row.text.text}',
        )
        .join('\n');
    _lastBody = widget.controller.text;
    _writingBody = false;
    widget.onChanged?.call(widget.controller.text);
  }

  void toggleChecklist() => _toggleMode();

  void applyFormat(String format) {
    final focused = rows.where((row) => row.focus.hasFocus);
    final c = checklist && rows.isNotEmpty
        ? (focused.isEmpty ? rows.first.text : focused.first.text)
        : widget.controller;
    final selection = c.selection;
    final start = selection.isValid ? selection.start : c.text.length;
    final end = selection.isValid ? selection.end : start;
    final marker = {
      'Bold': '**',
      'Italic': '*',
      'Underline': '__',
      'Heading': '# ',
    }[format]!;
    final text = c.text.substring(start, end);
    final inserted = format == 'Heading'
        ? marker + text
        : marker + text + marker;
    c.value = TextEditingValue(
      text: c.text.replaceRange(start, end, inserted),
      selection: TextSelection.collapsed(offset: start + inserted.length),
    );
    if (checklist) {
      _sync();
    } else {
      widget.onChanged?.call(c.text);
    }
  }

  void _toggleMode() {
    _writingBody = true;
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
      _lastBody = widget.controller.text;
      _writingBody = false;
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
    widget.controller.removeListener(_bodyChanged);
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
        if (!widget.compact)
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
            hintText: 'Note',
            border: InputBorder.none,
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
              var end = oldIndex + 1;
              while (end < rows.length &&
                  rows[end].depth > rows[oldIndex].depth) {
                end++;
              }
              if (newIndex >= oldIndex && newIndex < end) return;
              final block = rows.sublist(oldIndex, end);
              rows.removeRange(oldIndex, end);
              final target = newIndex > oldIndex
                  ? newIndex - (block.length - 1)
                  : newIndex;
              rows.insertAll(target.clamp(0, rows.length), block);
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
      if (widget.hideControls)
        const SizedBox.shrink()
      else if (widget.compact)
        Row(
          children: [
            IconButton(
              tooltip: checklist ? 'Hide checkboxes' : 'Show checkboxes',
              onPressed: widget.enabled ? _toggleMode : null,
              icon: Icon(checklist ? Icons.notes : Icons.checklist),
            ),
            PopupMenuButton<String>(
              tooltip: 'Formatting',
              icon: const Icon(Icons.text_format),
              enabled: widget.enabled && !checklist,
              itemBuilder: (_) => [
                for (final label in ['Bold', 'Italic', 'Underline', 'Heading'])
                  PopupMenuItem(value: label, child: Text(label)),
              ],
              onSelected: (format) {
                final c = widget.controller;
                final selection = c.selection;
                final start = selection.isValid
                    ? selection.start
                    : c.text.length;
                final end = selection.isValid ? selection.end : start;
                final marker = {
                  'Bold': '**',
                  'Italic': '*',
                  'Underline': '__',
                  'Heading': '# ',
                }[format]!;
                final text = c.text.substring(start, end);
                final inserted = format == 'Heading'
                    ? marker + text
                    : marker + text + marker;
                c.value = TextEditingValue(
                  text: c.text.replaceRange(start, end, inserted),
                  selection: TextSelection.collapsed(
                    offset: start + inserted.length,
                  ),
                );
                widget.onChanged?.call(c.text);
              },
            ),
          ],
        )
      else
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
