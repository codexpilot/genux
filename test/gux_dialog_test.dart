import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  testWidgets('dialog returns a caller-selected result', (tester) async {
    final semantics = tester.ensureSemantics();
    String? result;
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, _, _) => builder(context),
        ),
        home: Builder(
          builder: (context) => Center(
            child: GestureDetector(
              onTap: () async {
                result = await showGuxDialog<String>(
                  context: context,
                  barrierLabel: 'Dismiss dialog',
                  builder: (context) => GuxDialog(
                    title: const Text('Confirm'),
                    content: const Text('Continue?'),
                    actions: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop('yes'),
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Continue?'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Confirm')),
      matchesSemantics(label: 'Confirm', namesRoute: true),
    );
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(result, 'yes');
    semantics.dispose();
  });

  testWidgets('reserves space for the onscreen keyboard', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 260)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 14),
            child: GuxDialog(title: Text('Title'), actions: [Text('Done')]),
          ),
        ),
      ),
    );
    expect(tester.getBottomLeft(find.text('Done')).dy, lessThanOrEqualTo(340));
    expect(tester.takeException(), isNull);
  });

  testWidgets('honors minimum width without overflowing narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(220, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: TextStyle(fontSize: 14),
          child: GuxDialog(minWidth: 300, title: Text('Title')),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(DecoratedBox)).width,
      lessThanOrEqualTo(220),
    );
  });

  testWidgets('small viewport can scroll long content to actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: TextStyle(fontSize: 14),
          child: GuxDialog(
            title: Text('Long dialog'),
            content: SizedBox(height: 600, child: Text('Content')),
            actions: [Text('Done')],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Done')).bottom, lessThanOrEqualTo(240));
    expect(tester.takeException(), isNull);
  });
}
