import 'package:genux/genux.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {Size size = const Size(300, 200)}) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox.fromSize(size: size, child: child),
      ),
    );

void main() {
  const topKey = Key('top');
  const bottomKey = Key('bottom');
  const sideKey = Key('side');
  const bodyKey = Key('body');

  testWidgets('lays out supplied regions at their configured dimensions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const GuxWorkspaceScaffold(
          topBarHeight: 44,
          bottomBarHeight: 26,
          sideBarWidth: 44,
          topBar: SizedBox.expand(key: topKey),
          bottomBar: SizedBox.expand(key: bottomKey),
          sideBar: SizedBox.expand(key: sideKey),
          body: SizedBox.expand(key: bodyKey),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(topKey)), const Size(300, 44));
    expect(tester.getSize(find.byKey(bottomKey)), const Size(300, 26));
    expect(tester.getSize(find.byKey(sideKey)), const Size(44, 130));
    expect(tester.getSize(find.byKey(bodyKey)), const Size(256, 130));
    expect(tester.getTopLeft(find.byKey(bodyKey)), const Offset(44, 44));
  });

  testWidgets('omitted regions reserve no space', (tester) async {
    await tester.pumpWidget(
      _host(
        const GuxWorkspaceScaffold(
          topBarHeight: 44,
          bottomBarHeight: 26,
          sideBarWidth: 44,
          body: SizedBox.expand(key: bodyKey),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(bodyKey)), const Size(300, 200));
  });

  testWidgets('clamps region sizes to small bounded viewports', (tester) async {
    await tester.pumpWidget(
      _host(
        const GuxWorkspaceScaffold(
          topBarHeight: 44,
          bottomBarHeight: 26,
          sideBarWidth: 44,
          topBar: SizedBox.expand(key: topKey),
          bottomBar: SizedBox.expand(key: bottomKey),
          sideBar: SizedBox.expand(key: sideKey),
          body: SizedBox.expand(key: bodyKey),
        ),
        size: const Size(20, 30),
      ),
    );
    expect(tester.getSize(find.byKey(topKey)), const Size(20, 30));
    expect(tester.getSize(find.byKey(bottomKey)), const Size(20, 0));
    expect(tester.getSize(find.byKey(sideKey)), const Size(20, 0));
    expect(tester.getSize(find.byKey(bodyKey)), Size.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets('merges text style and paints configured background', (
    tester,
  ) async {
    const background = Color(0xFF112233);
    const foreground = Color(0xFF456789);
    await tester.pumpWidget(
      _host(
        const DefaultTextStyle(
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          child: GuxWorkspaceScaffold(
            topBarHeight: 0,
            bottomBarHeight: 0,
            sideBarWidth: 0,
            backgroundColor: background,
            textStyle: TextStyle(color: foreground),
            body: Text('Body'),
          ),
        ),
      ),
    );
    final textContext = tester.element(find.text('Body'));
    final style = DefaultTextStyle.of(textContext).style;
    expect(style.color, foreground);
    expect(style.fontSize, 17);
    expect(style.fontWeight, FontWeight.w600);
    expect(
      tester.widget<ColoredBox>(find.byType(ColoredBox)).color,
      background,
    );
  });
}
