import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/gux_workspace_scaffold.dart';
import 'package:genux/src/json/gux_json_renderer.dart';

void main() {
  setUpAll(() {
    // Register Text widget for JSON rendering in tests
    GuxJsonRenderer.register('Text', (json, actions) {
      return Text(json['data'] as String? ?? '');
    });
  });

  tearDownAll(() {
    GuxJsonRenderer.clear();
  });

  group('GuxWorkspaceScaffold.fromJson', () {
    testWidgets('creates scaffold with body only', (tester) async {
      final json = {
        'body': {'type': 'Text', 'data': 'Main content'},
        'topBarHeight': 0.0,
        'bottomBarHeight': 0.0,
        'sideBarWidth': 0.0,
      };

      final scaffold = GuxWorkspaceScaffold.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 800,
            height: 600,
            child: scaffold,
          ),
        ),
      );

      expect(find.byType(GuxWorkspaceScaffold), findsOneWidget);
      expect(scaffold.body, isA<Text>());
    });

    testWidgets('creates scaffold with all regions', (tester) async {
      final json = {
        'body': {'type': 'Text', 'data': 'Main content'},
        'topBar': {'type': 'Text', 'data': 'Top bar'},
        'bottomBar': {'type': 'Text', 'data': 'Bottom bar'},
        'sideBar': {'type': 'Text', 'data': 'Side bar'},
        'topBarHeight': 48.0,
        'bottomBarHeight': 32.0,
        'sideBarWidth': 44.0,
      };

      final scaffold = GuxWorkspaceScaffold.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 800,
            height: 600,
            child: scaffold,
          ),
        ),
      );

      expect(scaffold.body, isA<Text>());
      expect(scaffold.topBar, isA<Text>());
      expect(scaffold.bottomBar, isA<Text>());
      expect(scaffold.sideBar, isA<Text>());
    });

    testWidgets('parses dimensions', (tester) async {
      final json = {
        'body': {'type': 'Text', 'data': 'Body'},
        'topBarHeight': 60.0,
        'bottomBarHeight': 40.0,
        'sideBarWidth': 200.0,
      };

      final scaffold = GuxWorkspaceScaffold.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: scaffold,
        ),
      );

      expect(scaffold.topBarHeight, 60.0);
      expect(scaffold.bottomBarHeight, 40.0);
      expect(scaffold.sideBarWidth, 200.0);
    });

    testWidgets('defaults dimensions to 0', (tester) async {
      final json = {
        'body': {'type': 'Text', 'data': 'Body'},
      };

      final scaffold = GuxWorkspaceScaffold.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: scaffold,
        ),
      );

      expect(scaffold.topBarHeight, 0);
      expect(scaffold.bottomBarHeight, 0);
      expect(scaffold.sideBarWidth, 0);
    });

    testWidgets('parses backgroundColor', (tester) async {
      final json = {
        'body': {'type': 'Text', 'data': 'Body'},
        'topBarHeight': 0.0,
        'bottomBarHeight': 0.0,
        'sideBarWidth': 0.0,
        'backgroundColor': '#1E1E1E',
      };

      final scaffold = GuxWorkspaceScaffold.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: scaffold,
        ),
      );

      expect(scaffold.backgroundColor, const Color(0xFF1E1E1E));
    });

    testWidgets('parses textStyle', (tester) async {
      final json = {
        'body': {'type': 'Text', 'data': 'Body'},
        'topBarHeight': 0.0,
        'bottomBarHeight': 0.0,
        'sideBarWidth': 0.0,
        'textStyle': {
          'color': '#FFFFFF',
          'fontSize': 14.0,
        },
      };

      final scaffold = GuxWorkspaceScaffold.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: scaffold,
        ),
      );

      expect(scaffold.textStyle, isNotNull);
      expect(scaffold.textStyle!.color, const Color(0xFFFFFFFF));
      expect(scaffold.textStyle!.fontSize, 14.0);
    });

    testWidgets('handles null optional regions', (tester) async {
      final json = {
        'body': {'type': 'Text', 'data': 'Body'},
        'topBarHeight': 48.0,
        'bottomBarHeight': 32.0,
        'sideBarWidth': 44.0,
      };

      final scaffold = GuxWorkspaceScaffold.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: scaffold,
        ),
      );

      expect(scaffold.topBar, null);
      expect(scaffold.bottomBar, null);
      expect(scaffold.sideBar, null);
    });

    testWidgets('handles null backgroundColor and textStyle', (tester) async {
      final json = {
        'body': {'type': 'Text', 'data': 'Body'},
        'topBarHeight': 0.0,
        'bottomBarHeight': 0.0,
        'sideBarWidth': 0.0,
      };

      final scaffold = GuxWorkspaceScaffold.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: scaffold,
        ),
      );

      expect(scaffold.backgroundColor, null);
      expect(scaffold.textStyle, null);
    });
  });

  group('GuxWorkspaceScaffold.toJson', () {
    test('serializes dimensions', () {
      const scaffold = GuxWorkspaceScaffold(
        body: Text('Body'),
        topBarHeight: 48,
        bottomBarHeight: 32,
        sideBarWidth: 44,
      );

      final json = scaffold.toJson();

      expect(json['topBarHeight'], 48.0);
      expect(json['bottomBarHeight'], 32.0);
      expect(json['sideBarWidth'], 44.0);
    });

    test('serializes backgroundColor when present', () {
      const scaffold = GuxWorkspaceScaffold(
        body: Text('Body'),
        topBarHeight: 0,
        bottomBarHeight: 0,
        sideBarWidth: 0,
        backgroundColor: Color(0xFF1E1E1E),
      );

      final json = scaffold.toJson();

      expect(json['backgroundColor'], '#FF1E1E1E');
    });

    test('omits backgroundColor when null', () {
      const scaffold = GuxWorkspaceScaffold(
        body: Text('Body'),
        topBarHeight: 0,
        bottomBarHeight: 0,
        sideBarWidth: 0,
      );

      final json = scaffold.toJson();

      expect(json.containsKey('backgroundColor'), false);
    });

    test('serializes textStyle when present', () {
      const scaffold = GuxWorkspaceScaffold(
        body: Text('Body'),
        topBarHeight: 0,
        bottomBarHeight: 0,
        sideBarWidth: 0,
        textStyle: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14,
        ),
      );

      final json = scaffold.toJson();

      expect(json['textStyle'], isA<Map>());
      expect(json['textStyle']['color'], '#FFFFFFFF');
      expect(json['textStyle']['fontSize'], 14.0);
    });

    test('omits textStyle when null', () {
      const scaffold = GuxWorkspaceScaffold(
        body: Text('Body'),
        topBarHeight: 0,
        bottomBarHeight: 0,
        sideBarWidth: 0,
      );

      final json = scaffold.toJson();

      expect(json.containsKey('textStyle'), false);
    });

    test('roundtrip serialization preserves values', () {
      const original = GuxWorkspaceScaffold(
        body: Text('Body'),
        topBarHeight: 48,
        bottomBarHeight: 32,
        sideBarWidth: 44,
        backgroundColor: Color(0xFF1E1E1E),
        textStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
      );

      final json = original.toJson();
      json['body'] = {'type': 'Text', 'data': 'Body'};

      final restored = GuxWorkspaceScaffold.fromJson(json);

      expect(restored.topBarHeight, original.topBarHeight);
      expect(restored.bottomBarHeight, original.bottomBarHeight);
      expect(restored.sideBarWidth, original.sideBarWidth);
      expect(restored.backgroundColor, original.backgroundColor);
      expect(restored.textStyle?.color, original.textStyle?.color);
      expect(restored.textStyle?.fontSize, original.textStyle?.fontSize);
    });
  });
}
