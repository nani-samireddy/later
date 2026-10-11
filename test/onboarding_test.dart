import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/features/onboarding/presentation/onboarding_gate.dart';
import 'package:later/features/home/presentation/widgets/home_scaffold.dart';

void main() {
  testWidgets('name is trimmed, saved locally and onboarding is shown once', (
    tester,
  ) async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    Widget app() => MaterialApp(
      home: OnboardingGate(database: db, home: const Text('Home')),
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('What should we call you?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  Sam  ');
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(await db.setting('user_name'), 'Sam');
    expect(await db.setting('onboarding_completed'), 'true');
    expect(find.text('Home'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('blank name requires entry or explicit skip', (tester) async {
    final db = AppDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingGate(database: db, home: const Text('Home')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(await db.setting('onboarding_completed'), isNull);
    expect(
      find.text('Enter your name, or choose Skip for now.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(await db.setting('user_name'), '');
    expect(await db.setting('onboarding_completed'), 'true');
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('home greeting displays the name without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(411, 731);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pages = PageController();
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScaffold(
          userName: 'Sam with a very long display name',
          selected: 0,
          pageController: pages,
          onSelected: (_) {},
          viewFor: (_) => const SizedBox(),
          onAdd: () {},
          onSearch: () {},
        ),
      ),
    );
    expect(find.text('Hey, Sam with a very long display name'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    pages.dispose();
  });
}
