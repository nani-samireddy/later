import '../../../core/widgets/note_body_editor.dart';

import 'package:flutter/material.dart';

import '../../../core/ai/local_ai_service.dart';
import '../../../core/ai/local_entry_data.dart';

/// Open from Settings using MaterialPageRoute(builder: (_) => LocalAiScreen()).
class LocalAiScreen extends StatefulWidget {
  const LocalAiScreen({super.key, this.service});
  final LocalAiService? service;
  @override
  State<LocalAiScreen> createState() => _LocalAiScreenState();
}

class _LocalAiScreenState extends State<LocalAiScreen> {
  late final service = widget.service ?? LocalAiService.instance;
  @override
  void initState() {
    super.initState();
    service.refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Optional local AI')),
    body: ListenableBuilder(
      listenable: service,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Qwen3 0.6B', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 12),
          const Text(
            'Download: 614 MB (586 MiB). Allow at least 1 GB of free storage and several GB of available memory. Keep Later open during download. Device performance varies.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Apache 2.0 model from LiteRT Community. Installation downloads model weights from Hugging Face. Entry text is processed locally. OCR and manual entry remain available.',
          ),
          const SizedBox(height: 24),
          Text(service.message, key: const Key('local-ai-status')),
          if (service.working) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: service.status == LocalAiStatus.downloading
                  ? service.progress / 100
                  : null,
            ),
            if (service.status == LocalAiStatus.downloading)
              Text('${service.progress}% of 614 MB'),
            TextButton(onPressed: service.cancel, child: const Text('Cancel')),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: service.working || !service.runtime.supported
                ? null
                : service.install,
            child: Text(
              service.status == LocalAiStatus.failed ||
                      service.status == LocalAiStatus.cancelled
                  ? 'Retry installation'
                  : 'Install model',
            ),
          ),
          OutlinedButton(
            onPressed: service.working || !service.runtime.supported
                ? null
                : service.verify,
            child: const Text('Test readiness'),
          ),
          TextButton(
            onPressed: service.working || !service.runtime.supported
                ? null
                : service.remove,
            child: const Text('Remove model'),
          ),
          TextButton(
            onPressed: service.working ? null : service.refresh,
            child: const Text('Refresh status'),
          ),
        ],
      ),
    ),
  );
}

/// Capture can await this sheet and then populate its existing editable form.
/// Dismissal returns null; this widget never writes to the database.
Future<LocalEntryData?> showLocalAiReview(
  BuildContext context,
  LocalEntryData suggestion,
) => showModalBottomSheet<LocalEntryData>(
  context: context,
  isScrollControlled: true,
  builder: (_) => LocalAiReview(suggestion: suggestion),
);

class LocalAiReview extends StatefulWidget {
  const LocalAiReview({super.key, required this.suggestion});
  final LocalEntryData suggestion;
  @override
  State<LocalAiReview> createState() => _LocalAiReviewState();
}

class _LocalAiReviewState extends State<LocalAiReview> {
  late String kind = widget.suggestion.kind;
  late final person = TextEditingController(text: widget.suggestion.person);
  late final amount = TextEditingController(text: widget.suggestion.amount);
  late final description = TextEditingController(
    text: widget.suggestion.description,
  );
  String? error;
  @override
  void dispose() {
    person.dispose();
    amount.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      24,
      24,
      24,
      MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Review AI suggestion', style: TextStyle(fontSize: 22)),
          const Text(
            'Check the debt direction, name and amount before using this suggestion.',
          ),
          DropdownButtonFormField<String>(
            initialValue: kind,
            items: const [
              DropdownMenuItem(value: 'thing', child: Text('Thing / reminder')),
              DropdownMenuItem(
                value: 'owedToMe',
                child: Text('Someone owes me'),
              ),
              DropdownMenuItem(value: 'iOwe', child: Text('I owe someone')),
              DropdownMenuItem(value: 'spending', child: Text('Spending')),
            ],
            onChanged: (value) => setState(() => kind = value!),
          ),
          TextField(
            controller: person,
            maxLength: 120,
            decoration: const InputDecoration(labelText: 'Person'),
          ),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          NoteBodyEditor(controller: description, enabled: true, compact: true),
          if (error != null) Text(error!),
          FilledButton(
            onPressed: () {
              final value = amount.text.trim();
              if (value.isNotEmpty &&
                  (!RegExp(r'^\d{1,12}(?:\.\d{1,2})?$').hasMatch(value) ||
                      double.parse(value) <= 0)) {
                setState(
                  () => error =
                      'Use a positive amount with up to two decimal places.',
                );
                return;
              }
              Navigator.pop(
                context,
                LocalEntryData(
                  kind: kind,
                  person: person.text.trim(),
                  amount: value,
                  description: description.text.trim(),
                ),
              );
            },
            child: const Text('Use edited suggestion'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep original text'),
          ),
        ],
      ),
    ),
  );
}
