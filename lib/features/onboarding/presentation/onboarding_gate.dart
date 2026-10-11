import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

/// A local, one-time introduction. No account or network request is needed.
class OnboardingGate extends StatefulWidget {
  final Widget home;
  final AppDatabase? database;
  const OnboardingGate({super.key, required this.home, this.database});
  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  late final database = widget.database ?? AppDatabase();
  final name = TextEditingController();
  bool loading = true;
  bool done = false;
  bool saving = false;
  String? error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final completed =
          await database.setting('onboarding_completed') == 'true';
      final savedName = await database.setting('user_name') ?? '';
      if (mounted) {
        name.text = savedName;
        setState(() {
          done = completed;
          loading = false;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Could not load your preferences. Try again.';
        });
      }
    }
  }

  Future<void> _finish({bool skip = false}) async {
    if (!skip && name.text.trim().isEmpty) {
      setState(() => error = 'Enter your name, or choose Skip for now.');
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await database.transaction(() async {
        await database.saveSetting('user_name', skip ? '' : name.text.trim());
        await database.saveSetting('onboarding_completed', 'true');
      });
      if (mounted) setState(() => done = true);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Could not save your name. Try again.');
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    if (widget.database == null) database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (done) return widget.home;
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'later.',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'What should we call you?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A little space for your day. Your name stays on this device and is included in local backups.',
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: name,
                    enabled: !saving,
                    maxLength: 40,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.givenName],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!saving) _finish();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Your name',
                      hintText: 'Sam',
                    ),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(error!),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: saving ? null : () => _finish(),
                    child: Text(saving ? 'Saving…' : 'Get started'),
                  ),
                  TextButton(
                    onPressed: saving ? null : () => _finish(skip: true),
                    child: const Text('Skip for now'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
