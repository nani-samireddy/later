import 'package:flutter_test/flutter_test.dart';

import 'package:later/core/theme/app_theme.dart';

void main() {
  test('Later theme exposes the product color scheme', () {
    final theme = buildAppTheme();
    expect(theme.colorScheme.primary, isNotNull);
    expect(theme.useMaterial3, isTrue);
  });
}
