import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later/core/theme/app_theme.dart';
import 'package:later/features/home/presentation/home_dashboard.dart';
import 'package:later/features/home/presentation/widgets/home_scaffold.dart';
import 'package:later/features/things/domain/thing.dart';

void main() {
  for (final width in [320.0, 411.0]) {
    testWidgets(
      'reference home fits $width px and navigation remains connected',
      (tester) async {
        tester.view.physicalSize = Size(width, 890);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final pages = PageController();
        addTearDown(pages.dispose);
        var selected = 0;
        var completed = false;
        var searches = 0;
        var filters = 0;
        var adds = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StatefulBuilder(
              builder: (context, setState) => HomeScaffold(
                selected: selected,
                pageController: pages,
                onSelected: (value) => setState(() => selected = value),
                onAdd: () => adds++,
                onSearch: () => searches++,
                onFilter: selected == 1 || selected == 2
                    ? () => filters++
                    : null,
                viewFor: (index) => index == 0
                    ? HomeDashboard(
                        currency: 'INR',
                        moneyEntries: const [],
                        entries: completed
                            ? []
                            : const [
                                Thing(
                                  id: 1,
                                  title: 'Water the balcony plants',
                                  category: 'Home',
                                  icon: Icons.eco_outlined,
                                ),
                              ],
                        query: '',
                        onQueryChanged: (_) {},
                        onSearchTap: () {},
                        onOpenMoney: (_) {},
                        onOpenUpcoming: () {},
                        onOpenThings: () {},
                        onOpenThing: (_) {},
                        onSettingsTap: () {},
                        onOpenMoneySection: () {},
                        onCompleteThing: (_) =>
                            setState(() => completed = true),
                      )
                    : Center(child: Text('Page $index')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.text('later.'), findsOneWidget);
        expect(find.text('Water the balcony plants'), findsOneWidget);
        final left = tester.getTopLeft(find.text('Owed to you'));
        final right = tester.getTopLeft(find.text('You owe'));
        expect(left.dy, right.dy);
        expect(left.dx, lessThan(right.dx));
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();
        expect(completed, isTrue);
        expect(find.text('Water the balcony plants'), findsNothing);
        await tester.tap(find.byTooltip('Search everything'));
        expect(searches, 1);
        await tester.tap(find.byTooltip('Add'));
        expect(adds, 1);
        await tester.tap(find.text('Money'));
        await tester.pumpAndSettle();
        expect(find.text('Page 2'), findsOneWidget);
        final search = tester.getRect(
          find.ancestor(
            of: find.byTooltip('Search everything'),
            matching: find.byType(IconButton),
          ),
        );
        final filter = tester.getRect(
          find.ancestor(
            of: find.byTooltip('Filter'),
            matching: find.byType(IconButton),
          ),
        );
        expect(filter.top, search.top);
        expect(filter.left - search.right, inInclusiveRange(0, 8));
        expect(filter.width, greaterThanOrEqualTo(48));
        await tester.tap(find.byTooltip('Filter'));
        expect(filters, 1);
        await tester.tap(find.byTooltip('Settings'));
        await tester.pumpAndSettle();
        expect(find.text('Page 4'), findsOneWidget);
        await tester.tap(find.text('Overview'));
        await tester.pumpAndSettle();
        expect(find.text('Your things'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
