import 'camera_android_test.dart' as camera;
import 'payment_ocr_test.dart' as ocr;
import 'shared_capture_android_test.dart' as sharing;

import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/database/app_database.dart';
import 'package:later/features/things/data/things_repository.dart';
import 'package:later/features/money/data/money_repository.dart';

// Run the two native capture checks in one Android build/install.
void main() {
  camera.main();
  ocr.main();
  sharing.main();
  tearDownAll(() async {
    // Optional exact-title cleanup for an interrupted prior QA run. Ordinary
    // verification never removes pre-existing records by prefix or category.
    const title = String.fromEnvironment('LATER_QA_CLEANUP_TITLE');
    if (title.isEmpty) {
      return;
    }
    final db = AppDatabase();
    try {
      for (final item in await db.allThings()) {
        if (item.title == title) {
          await ThingsRepository(db).delete(item.id);
        }
      }
      for (final item in await db.allMoney()) {
        if (item.person == title) {
          await MoneyRepository(db).delete(item.id);
        }
      }
    } finally {
      await db.close();
    }
  });
}
