import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart' as db;
import 'package:later/core/widgets/note_body_editor.dart';
import 'package:later/core/widgets/note_format.dart';
import 'package:later/features/capture/data/entry_capture_service.dart';
import 'package:later/features/capture/presentation/note_composer_screen.dart';

import 'support/fake_reminders.dart';

void main() {
  testWidgets('voice draft uses first 50 characters as title and full body', (
    tester,
  ) async {
    final database = db.AppDatabase.withExecutor(NativeDatabase.memory());
    final transcript =
        '${List.filled(49, 'a').join()}👨‍👩‍👧‍👦 remaining full text';
    await tester.pumpWidget(
      MaterialApp(
        home: NoteComposerScreen(
          service: EntryCaptureService(database, scheduler: FakeReminders()),
          onChanged: () async {},
          initialText: transcript,
        ),
      ),
    );
    final title = tester
        .widget<TextField>(find.byType(TextField).first)
        .controller!
        .text;
    expect(title, '${List.filled(49, 'a').join()}👨‍👩‍👧‍👦');
    final body = tester
        .widget<NoteBodyEditor>(find.byType(NoteBodyEditor))
        .controller
        .text;
    expect(body, transcript);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await database.close();
  });

  testWidgets(
    'nested checklist toggles retain indentation and count progress',
    (tester) async {
      var text = '- [ ] Parent\n  - [x] Child';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteBodyView(text: text, onChanged: (value) => text = value),
          ),
        ),
      );
      await tester.tap(find.byType(Checkbox).first);
      expect(text, '- [x] Parent\n  - [x] Child');
      expect(checklistProgress(text), (2, 2));
    },
  );
  testWidgets('reordering preserves checked state and indentation', (
    tester,
  ) async {
    final controller = TextEditingController(
      text: '- [ ] First\n  - [x] Second',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NoteBodyEditor(controller: controller)),
      ),
    );
    tester
        .widget<ReorderableListView>(find.byType(ReorderableListView))
        .onReorderItem!(1, 0);
    await tester.pump();
    expect(controller.text, '  - [x] Second\n- [ ] First');
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
  testWidgets('reordering a parent moves its checked descendants', (
    tester,
  ) async {
    final controller = TextEditingController(
      text: '- [ ] Parent\n  - [x] Child\n- [ ] Other',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NoteBodyEditor(controller: controller)),
      ),
    );
    tester
        .widget<ReorderableListView>(find.byType(ReorderableListView))
        .onReorderItem!(0, 2);
    await tester.pump();
    expect(controller.text, '- [ ] Other\n- [ ] Parent\n  - [x] Child');
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('compact composer fits a small screen with keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final database = db.AppDatabase.withExecutor(NativeDatabase.memory());
    await tester.pumpWidget(
      MaterialApp(
        home: NoteComposerScreen(
          service: EntryCaptureService(database, scheduler: FakeReminders()),
          onChanged: () async {},
          checklist: true,
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Formatting'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await database.close();
  });

  testWidgets('formatting renders a heading and inline emphasis', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FormattedNoteText('# Weekend'),
              FormattedNoteText('Buy **milk** and *bread*'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Weekend'), findsOneWidget);
    expect(find.text('Buy milk and bread'), findsOneWidget);
  });
  testWidgets(
    'new note autosaves once, subsequent edits update it, back flushes',
    (tester) async {
      final database = db.AppDatabase.withExecutor(NativeDatabase.memory());
      final service = EntryCaptureService(database, scheduler: FakeReminders());
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => NoteComposerScreen(
                      service: service,
                      onChanged: () async {},
                    ),
                  ),
                ),
                child: const Text('New'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Weekend');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect((await database.allThings()).length, 1);
      await tester.enterText(find.byType(TextField).last, 'Buy milk');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '');
      await tester.enterText(find.byType(TextField).last, '');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      final cleared = (await database.allThings()).single;
      expect(cleared.description, '');
      expect(cleared.title, 'Untitled note');
      await tester.enterText(find.byType(TextField).last, 'Buy milk');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      final entries = await database.allThings();
      expect(entries.length, 1);
      expect(entries.single.description, 'Buy milk');
      expect(find.text('New'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await database.close();
    },
  );
}
