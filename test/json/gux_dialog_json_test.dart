import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/layout/gux_dialog.dart';
import 'package:genux/src/forms/gux_button.dart';
import 'package:genux/src/json/gux_json_renderer.dart';

void main() {
  setUpAll(() {
    // Register GuxButton with the renderer
    GuxJsonRenderer.register('gux.button', (props, actions) {
      return GuxButton.fromJson(props, actions: actions);
    });
  });

  tearDownAll(() {
    GuxJsonRenderer.clear();
  });
  group('GuxDialog.fromJson', () {
    testWidgets('creates dialog with minimal JSON', (tester) async {
      final json = {
        'content': 'Hello World',
      };

      final dialog = GuxDialog.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: dialog,
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
      expect(find.byType(GuxDialog), findsOneWidget);
    });

    testWidgets('creates dialog with string title and content', (tester) async {
      final json = {
        'title': 'Confirm Action',
        'content': 'Are you sure?',
      };

      final dialog = GuxDialog.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: dialog,
          ),
        ),
      );

      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
    });

    testWidgets('creates dialog with action buttons', (tester) async {
      final json = {
        'title': 'Delete Item',
        'content': 'This cannot be undone.',
        'actions': [
          {
            'type': 'gux.button',
            'props': {
              'child': 'Cancel',
              'onPressed': 'handleCancel',
            },
          },
          {
            'type': 'gux.button',
            'props': {
              'child': 'Delete',
              'onPressed': 'handleConfirm',
            },
          },
        ],
      };

      final actions = <String, VoidCallback>{
        'handleCancel': () {},
        'handleConfirm': () {},
      };

      final dialog = GuxDialog.fromJson(json, actions: actions);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: dialog,
          ),
        ),
      );

      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);
    });

    testWidgets('parses backgroundColor', (tester) async {
      final json = {
        'content': 'Styled dialog',
        'backgroundColor': '#1A1A1A',
      };

      final dialog = GuxDialog.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: dialog,
          ),
        ),
      );

      expect(find.byType(GuxDialog), findsOneWidget);
      expect(dialog.backgroundColor, const Color(0xFF1A1A1A));
    });

    testWidgets('parses padding and insetPadding', (tester) async {
      final json = {
        'content': 'Padded dialog',
        'padding': {'all': 16},
        'insetPadding': {'horizontal': 40, 'vertical': 24},
      };

      final dialog = GuxDialog.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: dialog,
          ),
        ),
      );

      expect(dialog.padding, const EdgeInsets.all(16));
      expect(dialog.insetPadding, const EdgeInsets.symmetric(horizontal: 40, vertical: 24));
    });

    testWidgets('parses minWidth and maxWidth', (tester) async {
      final json = {
        'content': 'Constrained dialog',
        'minWidth': 300.0,
        'maxWidth': 600.0,
      };

      final dialog = GuxDialog.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: dialog,
          ),
        ),
      );

      expect(dialog.minWidth, 300.0);
      expect(dialog.maxWidth, 600.0);
    });

    testWidgets('parses borderRadius', (tester) async {
      final json = {
        'content': 'Rounded dialog',
        'borderRadius': 12,
      };

      final dialog = GuxDialog.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: dialog,
          ),
        ),
      );

      expect(dialog.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('parses titleStyle and contentStyle', (tester) async {
      final json = {
        'title': 'Styled Title',
        'content': 'Styled Content',
        'titleStyle': {
          'fontSize': 20.0,
          'fontWeight': 'bold',
          'color': '#FFFFFF',
        },
        'contentStyle': {
          'fontSize': 14.0,
          'color': '#CCCCCC',
        },
      };

      final dialog = GuxDialog.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: dialog,
          ),
        ),
      );

      expect(dialog.titleStyle?.fontSize, 20.0);
      expect(dialog.titleStyle?.fontWeight, FontWeight.bold);
      expect(dialog.titleStyle?.color, const Color(0xFFFFFFFF));
      expect(dialog.contentStyle?.fontSize, 14.0);
      expect(dialog.contentStyle?.color, const Color(0xFFCCCCCC));
    });

    testWidgets('uses defaults for missing properties', (tester) async {
      final json = {
        'content': 'Default dialog',
      };

      final dialog = GuxDialog.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: dialog,
          ),
        ),
      );

      expect(dialog.backgroundColor, const Color(0xFF252525));
      expect(dialog.padding, const EdgeInsets.all(20));
      expect(dialog.insetPadding, const EdgeInsets.all(24));
      expect(dialog.minWidth, 0);
      expect(dialog.maxWidth, 560);
      expect(dialog.borderRadius, const BorderRadius.all(Radius.circular(8)));
      expect(dialog.actions, isEmpty);
    });

    testWidgets('handles empty actions list', (tester) async {
      final json = {
        'content': 'No actions',
        'actions': [],
      };

      final dialog = GuxDialog.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: dialog,
          ),
        ),
      );

      expect(dialog.actions, isEmpty);
      expect(find.text('No actions'), findsOneWidget);
    });

    test('parses all numeric properties correctly', () {
      final json = {
        'content': 'Test',
        'minWidth': 100,
        'maxWidth': 500,
      };

      final dialog = GuxDialog.fromJson(json, actions: {});

      expect(dialog.minWidth, 100.0);
      expect(dialog.maxWidth, 500.0);
    });
  });
}
