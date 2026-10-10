import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/ai/local_entry_data.dart';
import 'package:later/features/ai/presentation/local_ai_screen.dart';

void main() {
  testWidgets(
    'review edits all fields and returns only after explicit acceptance',
    (tester) async {
      LocalEntryData? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showLocalAiReview(
                    context,
                    const LocalEntryData(
                      kind: 'iOwe',
                      person: 'Ravi',
                      amount: '500',
                      description: 'Loan',
                    ),
                  );
                },
                child: const Text('Review'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(find.text('I owe someone'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'Priya');
      await tester.enterText(find.byType(TextField).at(1), '-12');
      await tester.ensureVisible(find.text('Use edited suggestion'));
      await tester.tap(find.text('Use edited suggestion'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(
        find.text('Use a positive amount with up to two decimal places.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField).at(1), '250.50');
      await tester.enterText(find.byType(TextField).at(2), 'Corrected loan');
      await tester.ensureVisible(find.text('Use edited suggestion'));
      await tester.tap(find.text('Use edited suggestion'));
      await tester.pumpAndSettle();
      expect(result!.kind, 'iOwe');
      expect(result!.person, 'Priya');
      expect(result!.amount, '250.50');
      expect(result!.description, 'Corrected loan');
    },
  );
  testWidgets('dismissing review preserves original capture fallback', (
    tester,
  ) async {
    LocalEntryData? result;
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showLocalAiReview(
                  context,
                  const LocalEntryData(
                    kind: 'thing',
                    person: '',
                    amount: '',
                    description: 'Milk',
                  ),
                );
                completed = true;
              },
              child: const Text('Review'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Keep original text'));
    await tester.tap(find.text('Keep original text'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(result, isNull);
  });
}
