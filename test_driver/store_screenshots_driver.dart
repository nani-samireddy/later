import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    await Directory('store-listing').create(recursive: true);
    await File('store-listing/$name.png').writeAsBytes(bytes);
    return true;
  },
);
