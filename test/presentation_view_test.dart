import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  testWidgets(
    'renders the sample with workspace slots, summary and semantics',
    (tester) async {
      final document = GuxPresentationDocument.parse(
        File('examples/dashboard.json').readAsStringSync(),
      );
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
            child: GuxPresentationView(document: document),
          ),
        ),
      );
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text("Today's activity"), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('3 items'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.bySemanticsLabel('Orders'), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('nested workspace in a scrolling column receives bounded space', (
    tester,
  ) async {
    final document = GuxPresentationDocument.parse(
      jsonEncode({
        'schemaVersion': 1,
        'root': {
          'type': 'column',
          'children': [
            {'type': 'text', 'text': 'Before'},
            {
              'type': 'workspace',
              'body': {'type': 'text', 'text': 'Inside'},
            },
          ],
        },
      }),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 14),
          child: GuxPresentationView(document: document),
        ),
      ),
    );
    expect(find.text('Before'), findsOneWidget);
    expect(find.text('Inside'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested columns lay out and scroll without a viewport error', (
    tester,
  ) async {
    final document = GuxPresentationDocument.parse(
      jsonEncode({
        'schemaVersion': 1,
        'root': {
          'type': 'column',
          'children': [
            {
              'type': 'column',
              'children': List.generate(
                100,
                (i) => {'type': 'text', 'text': 'Row $i'},
              ),
            },
          ],
        },
      }),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 14),
          child: GuxPresentationView(document: document),
        ),
      ),
    );
    expect(find.text('Row 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small slots tolerate large text and right-to-left layout', (
    tester,
  ) async {
    final document = GuxPresentationDocument.parse(
      jsonEncode({
        'schemaVersion': 1,
        'root': {
          'type': 'workspace',
          'topBarHeight': 1,
          'sideBarWidth': 0,
          'bottomBarHeight': 2,
          'topBar': {
            'type': 'summaryLines',
            'primary': 'Primary',
            'secondary': 'Secondary',
            'tertiary': 'Tertiary',
          },
          'sideBar': {'type': 'text', 'text': 'Very narrow sidebar'},
          'bottomBar': {'type': 'text', 'text': 'Small footer'},
          'body': {
            'type': 'workspace',
            'topBarHeight': 1,
            'topBar': {'type': 'text', 'text': 'Nested'},
            'body': {'type': 'text', 'text': 'Content'},
          },
        },
      }),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3)),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 20),
            child: Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: GuxPresentationView(document: document),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
