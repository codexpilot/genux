import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/gux_checkbox.dart';

void main() {
  group('GuxCheckboxStyle', () {
    test('fromJson creates style with all properties', () {
      final json = {
        'checkedBackgroundColor': '#3B82F6',
        'uncheckedBackgroundColor': '#252525',
        'hoverBackgroundColor': '#383838',
        'disabledBackgroundColor': '#1F1F1F',
        'checkedBorderColor': '#2563EB',
        'uncheckedBorderColor': '#484848',
        'disabledBorderColor': '#383838',
        'checkColor': '#FFFFFF',
        'disabledCheckColor': '#888888',
        'focusColor': '#60A5FA',
        'size': 20.0,
        'borderRadius': 4.0,
        'checkStrokeWidth': 2.5,
      };

      final style = GuxCheckboxStyle.fromJson(json);

      expect(style.checkedBackgroundColor, const Color(0xFF3B82F6));
      expect(style.uncheckedBackgroundColor, const Color(0xFF252525));
      expect(style.hoverBackgroundColor, const Color(0xFF383838));
      expect(style.disabledBackgroundColor, const Color(0xFF1F1F1F));
      expect(style.checkedBorderColor, const Color(0xFF2563EB));
      expect(style.uncheckedBorderColor, const Color(0xFF484848));
      expect(style.disabledBorderColor, const Color(0xFF383838));
      expect(style.checkColor, const Color(0xFFFFFFFF));
      expect(style.disabledCheckColor, const Color(0xFF888888));
      expect(style.focusColor, const Color(0xFF60A5FA));
      expect(style.size, 20.0);
      expect(style.borderRadius, 4.0);
      expect(style.checkStrokeWidth, 2.5);
    });

    test('fromJson uses defaults for missing properties', () {
      final style = GuxCheckboxStyle.fromJson({});

      expect(style.checkedBackgroundColor, const Color(0xFF3B82F6));
      expect(style.uncheckedBackgroundColor, const Color(0xFF252525));
      expect(style.checkColor, const Color(0xFFFFFFFF));
      expect(style.size, 18.0);
      expect(style.borderRadius, 3.0);
      expect(style.checkStrokeWidth, 2.0);
    });

    test('toJson serializes all properties', () {
      const style = GuxCheckboxStyle(
        checkedBackgroundColor: Color(0xFF123456),
        uncheckedBackgroundColor: Color(0xFF234567),
        hoverBackgroundColor: Color(0xFF345678),
        disabledBackgroundColor: Color(0xFF456789),
        checkedBorderColor: Color(0xFF567890),
        uncheckedBorderColor: Color(0xFF678901),
        disabledBorderColor: Color(0xFF789012),
        checkColor: Color(0xFF890123),
        disabledCheckColor: Color(0xFF901234),
        focusColor: Color(0xFFABCDEF),
        size: 22.0,
        borderRadius: 5.0,
        checkStrokeWidth: 3.0,
      );

      final json = style.toJson();

      expect(json['checkedBackgroundColor'], '#FF123456');
      expect(json['uncheckedBackgroundColor'], '#FF234567');
      expect(json['hoverBackgroundColor'], '#FF345678');
      expect(json['disabledBackgroundColor'], '#FF456789');
      expect(json['checkedBorderColor'], '#FF567890');
      expect(json['uncheckedBorderColor'], '#FF678901');
      expect(json['disabledBorderColor'], '#FF789012');
      expect(json['checkColor'], '#FF890123');
      expect(json['disabledCheckColor'], '#FF901234');
      expect(json['focusColor'], '#FFABCDEF');
      expect(json['size'], 22.0);
      expect(json['borderRadius'], 5.0);
      expect(json['checkStrokeWidth'], 3.0);
    });

    test('roundtrip serialization preserves values', () {
      const original = GuxCheckboxStyle(
        checkedBackgroundColor: Color(0xFF3B82F6),
        uncheckedBackgroundColor: Color(0xFF252525),
        hoverBackgroundColor: Color(0xFF383838),
        disabledBackgroundColor: Color(0xFF1F1F1F),
        checkedBorderColor: Color(0xFF2563EB),
        uncheckedBorderColor: Color(0xFF484848),
        disabledBorderColor: Color(0xFF383838),
        checkColor: Color(0xFFFFFFFF),
        disabledCheckColor: Color(0xFF888888),
        focusColor: Color(0xFF60A5FA),
        size: 20.0,
        borderRadius: 4.0,
        checkStrokeWidth: 2.5,
      );

      final json = original.toJson();
      final restored = GuxCheckboxStyle.fromJson(json);

      expect(restored.checkedBackgroundColor, original.checkedBackgroundColor);
      expect(restored.uncheckedBackgroundColor, original.uncheckedBackgroundColor);
      expect(restored.hoverBackgroundColor, original.hoverBackgroundColor);
      expect(restored.disabledBackgroundColor, original.disabledBackgroundColor);
      expect(restored.checkedBorderColor, original.checkedBorderColor);
      expect(restored.uncheckedBorderColor, original.uncheckedBorderColor);
      expect(restored.disabledBorderColor, original.disabledBorderColor);
      expect(restored.checkColor, original.checkColor);
      expect(restored.disabledCheckColor, original.disabledCheckColor);
      expect(restored.focusColor, original.focusColor);
      expect(restored.size, original.size);
      expect(restored.borderRadius, original.borderRadius);
      expect(restored.checkStrokeWidth, original.checkStrokeWidth);
    });
  });

  group('GuxCheckbox.fromJson', () {
    testWidgets('creates checkbox with minimal JSON', (tester) async {
      final json = {
        'value': true,
      };

      final checkbox = GuxCheckbox.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: checkbox,
        ),
      );

      expect(find.byType(GuxCheckbox), findsOneWidget);
      expect(checkbox.value, true);
    });

    test('binds onChanged action', () {
      bool? changedValue;
      final actions = <String, ValueChanged<bool?>>{
        'handleChange': (value) => changedValue = value,
      };

      final json = {
        'value': false,
        'onChanged': 'handleChange',
      };

      final checkbox = GuxCheckbox.fromJson(json, actions: actions);

      // Verify the callback is bound by calling it directly
      checkbox.onChanged?.call(true);
      expect(changedValue, true);
    });

    testWidgets('parses tristate flag', (tester) async {
      final json = {
        'value': null,
        'tristate': true,
      };

      final checkbox = GuxCheckbox.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: checkbox,
        ),
      );

      expect(checkbox.tristate, true);
      expect(checkbox.value, null);
    });

    testWidgets('parses autofocus flag', (tester) async {
      final json = {
        'value': false,
        'autofocus': true,
      };

      final checkbox = GuxCheckbox.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: checkbox,
          ),
        ),
      );

      expect(checkbox.autofocus, true);
    });

    testWidgets('parses style colors', (tester) async {
      final json = {
        'value': true,
        'style': {
          'checkedBackgroundColor': '#3B82F6',
          'checkColor': '#FFFFFF',
          'size': 20.0,
        },
      };

      final checkbox = GuxCheckbox.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: checkbox,
        ),
      );

      expect(checkbox.style.checkedBackgroundColor, const Color(0xFF3B82F6));
      expect(checkbox.style.checkColor, const Color(0xFFFFFFFF));
      expect(checkbox.style.size, 20.0);
    });

    testWidgets('parses style dimensions', (tester) async {
      final json = {
        'value': false,
        'style': {
          'size': 24.0,
          'borderRadius': 6.0,
          'checkStrokeWidth': 3.0,
        },
      };

      final checkbox = GuxCheckbox.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: checkbox,
        ),
      );

      expect(checkbox.style.size, 24.0);
      expect(checkbox.style.borderRadius, 6.0);
      expect(checkbox.style.checkStrokeWidth, 3.0);
    });

    testWidgets('uses defaults when style is missing', (tester) async {
      final json = {
        'value': true,
      };

      final checkbox = GuxCheckbox.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: checkbox,
        ),
      );

      expect(checkbox.style.size, 18.0);
      expect(checkbox.style.borderRadius, 3.0);
      expect(checkbox.style.checkStrokeWidth, 2.0);
    });

    test('handles null value for unchecked', () {
      final json = {
        'value': null,
        'tristate': false,
      };

      final checkbox = GuxCheckbox.fromJson(json, actions: {});

      expect(checkbox.value, null);
      expect(checkbox.tristate, false);
    });
  });
}
