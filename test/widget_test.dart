import 'package:flutter_test/flutter_test.dart';

import 'package:later/main.dart';

void main() {
  testWidgets('Later dashboard renders', (tester) async {
    await tester.pumpWidget(const LaterApp());
    expect(find.textContaining('What should you know'), findsOneWidget);
    expect(find.text('Coming up'), findsOneWidget);
    expect(find.text('Recently added'), findsOneWidget);
  });
}
