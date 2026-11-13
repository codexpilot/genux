import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/display/gux_progress_indicator.dart';

void main() {
  group('GuxProgressIndicator.fromJson', () {
    testWidgets('creates progress indicator with minimal JSON', (tester) async {
      final json = {
        'color': '#3B82F6',
        'trackColor': '#484848',
      };

      final indicator = GuxProgressIndicator.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: indicator,
        ),
      );

      expect(find.byType(GuxProgressIndicator), findsOneWidget);
      expect(indicator.color, const Color(0xFF3B82F6));
      expect(indicator.trackColor, const Color(0xFF484848));
    });

    testWidgets('creates indeterminate progress indicator', (tester) async {
      final json = {
        'color': '#3B82F6',
        'trackColor': '#484848',
      };

      final indicator = GuxProgressIndicator.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: indicator,
        ),
      );

      expect(indicator.value, null);
    });

    testWidgets('creates determinate progress indicator', (tester) async {
      final json = {
        'color': '#3B82F6',
        'trackColor': '#484848',
        'value': 0.75,
      };

      final indicator = GuxProgressIndicator.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: indicator,
        ),
      );

      expect(indicator.value, 0.75);
    });

    testWidgets('parses colors correctly', (tester) async {
      final json = {
        'color': '#FF0000',
        'trackColor': '#00FF00',
      };

      final indicator = GuxProgressIndicator.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: indicator,
        ),
      );

      expect(indicator.color, const Color(0xFFFF0000));
      expect(indicator.trackColor, const Color(0xFF00FF00));
    });

    testWidgets('parses size and strokeWidth', (tester) async {
      final json = {
        'color': '#3B82F6',
        'trackColor': '#484848',
        'size': 24.0,
        'strokeWidth': 3.0,
      };

      final indicator = GuxProgressIndicator.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: indicator,
        ),
      );

      expect(indicator.size, 24.0);
      expect(indicator.strokeWidth, 3.0);
    });

    testWidgets('parses semantics properties', (tester) async {
      final json = {
        'color': '#3B82F6',
        'trackColor': '#484848',
        'value': 0.5,
        'semanticsLabel': 'Loading progress',
        'semanticsValue': '50%',
      };

      final indicator = GuxProgressIndicator.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: indicator,
        ),
      );

      expect(indicator.semanticsLabel, 'Loading progress');
      expect(indicator.semanticsValue, '50%');
    });

    testWidgets('uses defaults for missing properties', (tester) async {
      final json = {
        'color': '#3B82F6',
        'trackColor': '#484848',
      };

      final indicator = GuxProgressIndicator.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: indicator,
        ),
      );

      expect(indicator.size, 16);
      expect(indicator.strokeWidth, 2);
      expect(indicator.value, null);
      expect(indicator.semanticsLabel, null);
      expect(indicator.semanticsValue, null);
    });

    testWidgets('handles value 0.0', (tester) async {
      final json = {
        'color': '#3B82F6',
        'trackColor': '#484848',
        'value': 0.0,
      };

      final indicator = GuxProgressIndicator.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: indicator,
        ),
      );

      expect(indicator.value, 0.0);
    });

    testWidgets('handles value 1.0', (tester) async {
      final json = {
        'color': '#3B82F6',
        'trackColor': '#484848',
        'value': 1.0,
      };

      final indicator = GuxProgressIndicator.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: indicator,
        ),
      );

      expect(indicator.value, 1.0);
    });
  });

  group('GuxProgressIndicator.toJson', () {
    test('serializes all properties', () {
      const indicator = GuxProgressIndicator(
        color: Color(0xFF3B82F6),
        trackColor: Color(0xFF484848),
        size: 24.0,
        strokeWidth: 3.0,
        value: 0.75,
        semanticsLabel: 'Loading',
        semanticsValue: '75%',
      );

      final json = indicator.toJson();

      expect(json['color'], '#FF3B82F6');
      expect(json['trackColor'], '#FF484848');
      expect(json['size'], 24.0);
      expect(json['strokeWidth'], 3.0);
      expect(json['value'], 0.75);
      expect(json['semanticsLabel'], 'Loading');
      expect(json['semanticsValue'], '75%');
    });

    test('omits null value', () {
      const indicator = GuxProgressIndicator(
        color: Color(0xFF3B82F6),
        trackColor: Color(0xFF484848),
      );

      final json = indicator.toJson();

      expect(json.containsKey('value'), false);
      expect(json.containsKey('semanticsLabel'), false);
      expect(json.containsKey('semanticsValue'), false);
    });

    test('roundtrip serialization preserves values', () {
      const original = GuxProgressIndicator(
        color: Color(0xFF3B82F6),
        trackColor: Color(0xFF484848),
        size: 20.0,
        strokeWidth: 2.5,
        value: 0.6,
        semanticsLabel: 'Progress',
        semanticsValue: '60%',
      );

      final json = original.toJson();
      final restored = GuxProgressIndicator.fromJson(json);

      expect(restored.color, original.color);
      expect(restored.trackColor, original.trackColor);
      expect(restored.size, original.size);
      expect(restored.strokeWidth, original.strokeWidth);
      expect(restored.value, original.value);
      expect(restored.semanticsLabel, original.semanticsLabel);
      expect(restored.semanticsValue, original.semanticsValue);
    });

    test('roundtrip indeterminate indicator', () {
      const original = GuxProgressIndicator(
        color: Color(0xFF3B82F6),
        trackColor: Color(0xFF484848),
        size: 16,
        strokeWidth: 2,
      );

      final json = original.toJson();
      final restored = GuxProgressIndicator.fromJson(json);

      expect(restored.value, null);
      expect(restored.color, original.color);
      expect(restored.trackColor, original.trackColor);
    });
  });
}
