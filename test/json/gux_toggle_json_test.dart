import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/gux_toggle.dart';

void main() {
  group('GuxToggleStyle', () {
    test('fromJson creates style with all properties', () {
      final json = {
        'activeTrackColor': '#3B82F6',
        'inactiveTrackColor': '#484848',
        'disabledTrackColor': '#383838',
        'activeThumbColor': '#FFFFFF',
        'inactiveThumbColor': '#CCCCCC',
        'disabledThumbColor': '#888888',
        'focusColor': '#60A5FA',
        'width': 50.0,
        'height': 24.0,
        'thumbSize': 18.0,
        'thumbPadding': 3.0,
      };

      final style = GuxToggleStyle.fromJson(json);

      expect(style.activeTrackColor, const Color(0xFF3B82F6));
      expect(style.inactiveTrackColor, const Color(0xFF484848));
      expect(style.disabledTrackColor, const Color(0xFF383838));
      expect(style.activeThumbColor, const Color(0xFFFFFFFF));
      expect(style.inactiveThumbColor, const Color(0xFFCCCCCC));
      expect(style.disabledThumbColor, const Color(0xFF888888));
      expect(style.focusColor, const Color(0xFF60A5FA));
      expect(style.width, 50.0);
      expect(style.height, 24.0);
      expect(style.thumbSize, 18.0);
      expect(style.thumbPadding, 3.0);
    });

    test('fromJson uses defaults for missing properties', () {
      final style = GuxToggleStyle.fromJson({});

      expect(style.activeTrackColor, const Color(0xFF3B82F6));
      expect(style.inactiveTrackColor, const Color(0xFF484848));
      expect(style.activeThumbColor, const Color(0xFFFFFFFF));
      expect(style.width, 40.0);
      expect(style.height, 20.0);
      expect(style.thumbSize, 14.0);
      expect(style.thumbPadding, 2.0);
    });

    test('toJson serializes all properties', () {
      const style = GuxToggleStyle(
        activeTrackColor: Color(0xFF123456),
        inactiveTrackColor: Color(0xFF234567),
        disabledTrackColor: Color(0xFF345678),
        activeThumbColor: Color(0xFF456789),
        inactiveThumbColor: Color(0xFF567890),
        disabledThumbColor: Color(0xFF678901),
        focusColor: Color(0xFFABCDEF),
        width: 45.0,
        height: 22.0,
        thumbSize: 16.0,
        thumbPadding: 2.5,
      );

      final json = style.toJson();

      expect(json['activeTrackColor'], '#FF123456');
      expect(json['inactiveTrackColor'], '#FF234567');
      expect(json['disabledTrackColor'], '#FF345678');
      expect(json['activeThumbColor'], '#FF456789');
      expect(json['inactiveThumbColor'], '#FF567890');
      expect(json['disabledThumbColor'], '#FF678901');
      expect(json['focusColor'], '#FFABCDEF');
      expect(json['width'], 45.0);
      expect(json['height'], 22.0);
      expect(json['thumbSize'], 16.0);
      expect(json['thumbPadding'], 2.5);
    });

    test('roundtrip serialization preserves values', () {
      const original = GuxToggleStyle(
        activeTrackColor: Color(0xFF3B82F6),
        inactiveTrackColor: Color(0xFF484848),
        disabledTrackColor: Color(0xFF383838),
        activeThumbColor: Color(0xFFFFFFFF),
        inactiveThumbColor: Color(0xFFCCCCCC),
        disabledThumbColor: Color(0xFF888888),
        focusColor: Color(0xFF60A5FA),
        width: 50.0,
        height: 24.0,
        thumbSize: 18.0,
        thumbPadding: 3.0,
      );

      final json = original.toJson();
      final restored = GuxToggleStyle.fromJson(json);

      expect(restored.activeTrackColor, original.activeTrackColor);
      expect(restored.inactiveTrackColor, original.inactiveTrackColor);
      expect(restored.disabledTrackColor, original.disabledTrackColor);
      expect(restored.activeThumbColor, original.activeThumbColor);
      expect(restored.inactiveThumbColor, original.inactiveThumbColor);
      expect(restored.disabledThumbColor, original.disabledThumbColor);
      expect(restored.focusColor, original.focusColor);
      expect(restored.width, original.width);
      expect(restored.height, original.height);
      expect(restored.thumbSize, original.thumbSize);
      expect(restored.thumbPadding, original.thumbPadding);
    });
  });

  group('GuxToggle.fromJson', () {
    testWidgets('creates toggle with minimal JSON', (tester) async {
      final json = {
        'value': true,
      };

      final toggle = GuxToggle.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: toggle,
        ),
      );

      expect(find.byType(GuxToggle), findsOneWidget);
      expect(toggle.value, true);
    });

    test('binds onChanged action', () {
      bool? changedValue;
      final actions = <String, ValueChanged<bool>>{
        'handleChange': (value) => changedValue = value,
      };

      final json = {
        'value': false,
        'onChanged': 'handleChange',
      };

      final toggle = GuxToggle.fromJson(json, actions: actions);

      // Verify the callback is bound by calling it directly
      toggle.onChanged?.call(true);
      expect(changedValue, true);
    });

    testWidgets('parses value correctly', (tester) async {
      final jsonOn = {'value': true};
      final jsonOff = {'value': false};

      final toggleOn = GuxToggle.fromJson(jsonOn, actions: {});
      final toggleOff = GuxToggle.fromJson(jsonOff, actions: {});

      expect(toggleOn.value, true);
      expect(toggleOff.value, false);
    });

    testWidgets('defaults to false when value is missing', (tester) async {
      final json = <String, dynamic>{};

      final toggle = GuxToggle.fromJson(json, actions: {});

      expect(toggle.value, false);
    });

    testWidgets('parses autofocus flag', (tester) async {
      final json = {
        'value': true,
        'autofocus': true,
      };

      final toggle = GuxToggle.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: toggle,
          ),
        ),
      );

      expect(toggle.autofocus, true);
    });

    testWidgets('parses style colors', (tester) async {
      final json = {
        'value': true,
        'style': {
          'activeTrackColor': '#3B82F6',
          'activeThumbColor': '#FFFFFF',
          'inactiveTrackColor': '#484848',
        },
      };

      final toggle = GuxToggle.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: toggle,
        ),
      );

      expect(toggle.style.activeTrackColor, const Color(0xFF3B82F6));
      expect(toggle.style.activeThumbColor, const Color(0xFFFFFFFF));
      expect(toggle.style.inactiveTrackColor, const Color(0xFF484848));
    });

    testWidgets('parses style dimensions', (tester) async {
      final json = {
        'value': false,
        'style': {
          'width': 50.0,
          'height': 24.0,
          'thumbSize': 18.0,
          'thumbPadding': 3.0,
        },
      };

      final toggle = GuxToggle.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: toggle,
        ),
      );

      expect(toggle.style.width, 50.0);
      expect(toggle.style.height, 24.0);
      expect(toggle.style.thumbSize, 18.0);
      expect(toggle.style.thumbPadding, 3.0);
    });

    testWidgets('uses defaults when style is missing', (tester) async {
      final json = {
        'value': true,
      };

      final toggle = GuxToggle.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: toggle,
        ),
      );

      expect(toggle.style.width, 40.0);
      expect(toggle.style.height, 20.0);
      expect(toggle.style.thumbSize, 14.0);
      expect(toggle.style.thumbPadding, 2.0);
    });

    testWidgets('creates disabled toggle without onChanged', (tester) async {
      final json = {
        'value': true,
      };

      final toggle = GuxToggle.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: toggle,
        ),
      );

      expect(toggle.onChanged, null);
    });
  });
}
