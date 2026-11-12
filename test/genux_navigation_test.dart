import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

Widget _host(Widget child, {Size size = const Size(44, 200)}) => WidgetsApp(
  color: const Color(0xFF000000),
  builder: (context, _) => FocusScope(
    autofocus: true,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox.fromSize(size: size, child: child),
      ),
    ),
  ),
);

void main() {
  testWidgets('selects actions by pointer and reports selected semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var count = 0;
    await tester.pumpWidget(
      _host(
        GenuxNavigation(
          items: [
            GenuxNavigationItem(
              icon: const SizedBox(width: 12, height: 12),
              label: 'Home',
              selected: true,
              onSelected: () => count++,
            ),
            const GenuxNavigationItem(
              icon: SizedBox(width: 12, height: 12),
              label: 'Disabled',
              onSelected: null,
            ),
          ],
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')),
      matchesSemantics(
        label: 'Home',
        isButton: true,
        isSelected: true,
        isEnabled: true,
        hasEnabledState: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.bySemanticsLabel('Home'));
    expect(count, 1);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Disabled')),
      matchesSemantics(
        label: 'Disabled',
        isButton: true,
        isSelected: false,
        isEnabled: false,
        hasEnabledState: true,
        hasSelectedState: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('keyboard activates focused item', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      _host(
        GenuxNavigation(
          items: [
            GenuxNavigationItem(
              icon: const SizedBox(width: 12, height: 12),
              label: 'Open',
              onSelected: () => count++,
            ),
          ],
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(count, 2);
  });

  testWidgets('clicking an item moves focus for keyboard activation', (
    tester,
  ) async {
    var firstCount = 0;
    var secondCount = 0;
    await tester.pumpWidget(
      _host(
        GenuxNavigation(
          items: [
            GenuxNavigationItem(
              icon: const Text('A'),
              label: 'First',
              onSelected: () => firstCount++,
            ),
            GenuxNavigationItem(
              icon: const Text('B'),
              label: 'Second',
              onSelected: () => secondCount++,
            ),
          ],
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.tap(find.text('B'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(firstCount, 0);
    expect(secondCount, 2);
  });

  testWidgets('anchors bottom items and scrolls in short, narrow bounds', (
    tester,
  ) async {
    GenuxNavigationItem item(String label) =>
        GenuxNavigationItem(icon: Text(label), label: label, onSelected: () {});
    await tester.pumpWidget(
      _host(GenuxNavigation(items: [item('A')], bottomItems: [item('B')])),
    );
    expect(tester.getBottomLeft(find.text('B')).dy, greaterThan(160));
    await tester.pumpWidget(
      _host(
        GenuxNavigation(
          items: [item('A'), item('B'), item('C')],
          bottomItems: [item('D')],
        ),
        size: const Size(20, 35),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(Scrollable), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('D')).dy, lessThan(35));
    expect(tester.takeException(), isNull);
  });
}
