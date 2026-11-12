import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/summary_lines.dart';

void main() {
  group('GuxSummaryLines.fromJson', () {
    testWidgets('creates summary with minimal JSON', (tester) async {
      final json = {
        'primary': 'John Doe',
        'secondary': 'Software Engineer',
        'tertiary': 'San Francisco, CA',
      };

      final summary = GuxSummaryLines.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: summary,
        ),
      );

      expect(find.byType(GuxSummaryLines), findsOneWidget);
      expect(summary.primary, 'John Doe');
      expect(summary.secondary, 'Software Engineer');
      expect(summary.tertiary, 'San Francisco, CA');
    });

    testWidgets('parses all text values', (tester) async {
      final json = {
        'primary': 'Primary text',
        'secondary': 'Secondary text',
        'tertiary': 'Tertiary text',
      };

      final summary = GuxSummaryLines.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: summary,
        ),
      );

      expect(find.text('Primary text'), findsOneWidget);
      expect(find.text('Secondary text'), findsOneWidget);
      expect(find.text('Tertiary text'), findsOneWidget);
    });

    testWidgets('defaults to empty strings', (tester) async {
      final json = <String, dynamic>{};

      final summary = GuxSummaryLines.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: summary,
        ),
      );

      expect(summary.primary, '');
      expect(summary.secondary, '');
      expect(summary.tertiary, '');
    });

    testWidgets('parses spacing', (tester) async {
      final json = {
        'primary': 'Primary',
        'secondary': 'Secondary',
        'tertiary': 'Tertiary',
        'spacing': 8.0,
      };

      final summary = GuxSummaryLines.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: summary,
        ),
      );

      expect(summary.spacing, 8.0);
    });

    testWidgets('defaults spacing to 4', (tester) async {
      final json = {
        'primary': 'Primary',
        'secondary': 'Secondary',
        'tertiary': 'Tertiary',
      };

      final summary = GuxSummaryLines.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: summary,
        ),
      );

      expect(summary.spacing, 4);
    });

    testWidgets('parses primaryStyle', (tester) async {
      final json = {
        'primary': 'Primary',
        'secondary': 'Secondary',
        'tertiary': 'Tertiary',
        'primaryStyle': {
          'fontSize': 16.0,
          'fontWeight': '600',
          'color': '#FFFFFF',
        },
      };

      final summary = GuxSummaryLines.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: summary,
        ),
      );

      expect(summary.primaryStyle, isNotNull);
      expect(summary.primaryStyle!.fontSize, 16.0);
      expect(summary.primaryStyle!.fontWeight, FontWeight.w600);
      expect(summary.primaryStyle!.color, const Color(0xFFFFFFFF));
    });

    testWidgets('parses secondaryStyle', (tester) async {
      final json = {
        'primary': 'Primary',
        'secondary': 'Secondary',
        'tertiary': 'Tertiary',
        'secondaryStyle': {
          'fontSize': 14.0,
          'color': '#CCCCCC',
        },
      };

      final summary = GuxSummaryLines.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: summary,
        ),
      );

      expect(summary.secondaryStyle, isNotNull);
      expect(summary.secondaryStyle!.fontSize, 14.0);
      expect(summary.secondaryStyle!.color, const Color(0xFFCCCCCC));
    });

    testWidgets('parses tertiaryStyle', (tester) async {
      final json = {
        'primary': 'Primary',
        'secondary': 'Secondary',
        'tertiary': 'Tertiary',
        'tertiaryStyle': {
          'fontSize': 12.0,
          'color': '#888888',
        },
      };

      final summary = GuxSummaryLines.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: summary,
        ),
      );

      expect(summary.tertiaryStyle, isNotNull);
      expect(summary.tertiaryStyle!.fontSize, 12.0);
      expect(summary.tertiaryStyle!.color, const Color(0xFF888888));
    });

    testWidgets('parses all styles together', (tester) async {
      final json = {
        'primary': 'Primary',
        'secondary': 'Secondary',
        'tertiary': 'Tertiary',
        'primaryStyle': {
          'fontSize': 16.0,
          'color': '#FFFFFF',
        },
        'secondaryStyle': {
          'fontSize': 14.0,
          'color': '#CCCCCC',
        },
        'tertiaryStyle': {
          'fontSize': 12.0,
          'color': '#888888',
        },
      };

      final summary = GuxSummaryLines.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: summary,
        ),
      );

      expect(summary.primaryStyle, isNotNull);
      expect(summary.secondaryStyle, isNotNull);
      expect(summary.tertiaryStyle, isNotNull);
    });

    testWidgets('handles null styles', (tester) async {
      final json = {
        'primary': 'Primary',
        'secondary': 'Secondary',
        'tertiary': 'Tertiary',
      };

      final summary = GuxSummaryLines.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: summary,
        ),
      );

      expect(summary.primaryStyle, null);
      expect(summary.secondaryStyle, null);
      expect(summary.tertiaryStyle, null);
    });
  });

  group('GuxSummaryLines.toJson', () {
    test('serializes text values', () {
      const summary = GuxSummaryLines(
        primary: 'Primary text',
        secondary: 'Secondary text',
        tertiary: 'Tertiary text',
      );

      final json = summary.toJson();

      expect(json['primary'], 'Primary text');
      expect(json['secondary'], 'Secondary text');
      expect(json['tertiary'], 'Tertiary text');
    });

    test('serializes spacing', () {
      const summary = GuxSummaryLines(
        primary: 'Primary',
        secondary: 'Secondary',
        tertiary: 'Tertiary',
        spacing: 8,
      );

      final json = summary.toJson();

      expect(json['spacing'], 8.0);
    });

    test('serializes styles when present', () {
      const summary = GuxSummaryLines(
        primary: 'Primary',
        secondary: 'Secondary',
        tertiary: 'Tertiary',
        primaryStyle: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
        secondaryStyle: TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
        tertiaryStyle: TextStyle(fontSize: 12, color: Color(0xFF888888)),
      );

      final json = summary.toJson();

      expect(json['primaryStyle'], isA<Map>());
      expect(json['secondaryStyle'], isA<Map>());
      expect(json['tertiaryStyle'], isA<Map>());
    });

    test('omits null styles', () {
      const summary = GuxSummaryLines(
        primary: 'Primary',
        secondary: 'Secondary',
        tertiary: 'Tertiary',
      );

      final json = summary.toJson();

      expect(json.containsKey('primaryStyle'), false);
      expect(json.containsKey('secondaryStyle'), false);
      expect(json.containsKey('tertiaryStyle'), false);
    });

    test('roundtrip serialization preserves values', () {
      const original = GuxSummaryLines(
        primary: 'John Doe',
        secondary: 'Software Engineer',
        tertiary: 'San Francisco, CA',
        primaryStyle: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
        secondaryStyle: TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
        tertiaryStyle: TextStyle(fontSize: 12, color: Color(0xFF888888)),
        spacing: 6,
      );

      final json = original.toJson();
      final restored = GuxSummaryLines.fromJson(json);

      expect(restored.primary, original.primary);
      expect(restored.secondary, original.secondary);
      expect(restored.tertiary, original.tertiary);
      expect(restored.spacing, original.spacing);
      expect(restored.primaryStyle?.fontSize, original.primaryStyle?.fontSize);
      expect(restored.primaryStyle?.color, original.primaryStyle?.color);
      expect(restored.secondaryStyle?.fontSize, original.secondaryStyle?.fontSize);
      expect(restored.secondaryStyle?.color, original.secondaryStyle?.color);
      expect(restored.tertiaryStyle?.fontSize, original.tertiaryStyle?.fontSize);
      expect(restored.tertiaryStyle?.color, original.tertiaryStyle?.color);
    });
  });
}
