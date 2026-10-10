import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/attachments/attachment_store.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/core/payments/payment_screenshot_parser.dart';
import 'package:later/features/capture/data/entry_capture_service.dart';
import 'package:later/features/capture/presentation/add_entry_sheet.dart';

void main() {
  testWidgets('screenshot review is editable and cancel never stores image', (
    tester,
  ) async {
    final directory = Directory.systemTemp.createTempSync('payment-review-');
    final source = File('${directory.path}/source.png');
    source.writeAsBytesSync([1, 2, 3]);
    final database = AppDatabase.withExecutor(NativeDatabase.memory());
    final managed = Directory('${directory.path}/private');
    final service = EntryCaptureService(
      database,
      store: AttachmentStore(directory: () async => managed),
    );
    final payment = PaymentScreenshotParser.fromText(
      'Paid to Asha\nINR 100',
      source.path,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAddEntrySheet(
                context,
                service: service,
                currency: 'INR',
                onThingsChanged: () async {},
                onMoneyChanged: () async {},
                paymentScreenshot: payment,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Review the extracted details'), findsOneWidget);
    expect(find.text('I have checked the payment type'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Asha'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Asha'), 'Coffee');
    expect(find.widgetWithText(TextField, 'Coffee'), findsOneWidget);
    expect(managed.existsSync(), false);
    // Dismiss via the modal barrier, preserving the original shared file.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(managed.existsSync(), false);
    expect(source.readAsBytesSync(), [1, 2, 3]);
    await tester.runAsync(() async {
      expect(await database.allMoney(), isEmpty);
    });
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => database.close());
    directory.deleteSync(recursive: true);
  });
}
