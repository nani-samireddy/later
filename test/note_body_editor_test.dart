import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/core/widgets/note_body_editor.dart';

void main() {
  testWidgets('freeform lines become editable checkboxes and convert back', (
    tester,
  ) async {
    final body = TextEditingController(text: 'Buy milk\nCall home');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NoteBodyEditor(controller: body)),
      ),
    );
    await tester.tap(find.text('Show checkboxes'));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNWidgets(2));
    expect(body.text, '- [ ] Buy milk\n- [ ] Call home');
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(body.text, '- [x] Buy milk\n- [ ] Call home');
    await tester.enterText(find.byType(TextField).last, 'Call Dad');
    expect(body.text, '- [x] Buy milk\n- [ ] Call Dad');
    await tester.tap(find.text('Hide checkboxes'));
    await tester.pumpAndSettle();
    expect(body.text, 'Buy milk\nCall Dad');
    await tester.pumpWidget(const SizedBox());
    body.dispose();
  });

  testWidgets('Enter adds a focused row, deletion preserves remaining state', (
    tester,
  ) async {
    final body = TextEditingController(text: '- [x] First');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NoteBodyEditor(controller: body)),
      ),
    );
    await tester.tap(find.byType(TextField).first);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    expect(body.text, '- [x] First');
    await tester.enterText(find.byType(TextField).last, 'Second');
    await tester.tap(find.byTooltip('Delete list item').first);
    await tester.pumpAndSettle();
    expect(body.text, '- [ ] Second');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    body.dispose();
  });

  testWidgets(
    'detail view renders mixed text and persists only selected checkbox',
    (tester) async {
      String? updated;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteBodyView(
              text: 'Weekend\n- [ ] Milk\n- [x] Bread',
              onChanged: (value) => updated = value,
            ),
          ),
        ),
      );
      expect(find.text('Weekend'), findsOneWidget);
      await tester.tap(find.byType(Checkbox).first);
      expect(updated, 'Weekend\n- [x] Milk\n- [x] Bread');
    },
  );

  test(
    'checklist completion survives database reopen in the existing note',
    () async {
      final temp = await Directory.systemTemp.createTemp('later-checklist');
      final file = File('${temp.path}/db.sqlite');
      var db = AppDatabase.withExecutor(NativeDatabase(file));
      const body = '- [x] First\n- [ ] Second';
      final id = await db.addThing(
        ThingsCompanion.insert(
          title: 'Weekend',
          category: 'General',
          iconCodePoint: 12,
          description: const Value(body),
        ),
      );
      await db.close();
      db = AppDatabase.withExecutor(NativeDatabase(file));
      expect((await db.thingById(id))!.description, body);
      expect((await db.thingById(id))!.status, 'active');
      await db.close();
      await temp.delete(recursive: true);
    },
  );
}
