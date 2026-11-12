import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/gux_button.dart';
import 'package:genux/src/json/gux_json_renderer.dart';
import 'package:flutter/widgets.dart';

void main() {
  group('GuxButton.fromJson', () {
    test('creates button from minimal JSON', () {
      final button = GuxButton.fromJson(
        {
          'style': {
            'backgroundColor': '#3B82F6',
            'hoverColor': '#2563EB',
            'pressedColor': '#1D4ED8',
            'disabledColor': '#9CA3AF',
            'foregroundColor': '#FFFFFF',
            'disabledForegroundColor': '#D1D5DB',
          },
          'child': 'Click Me',
        },
        actions: {},
      );

      expect(button, isA<GuxButton>());
      expect(button.onPressed, null);
      expect(button.semanticsLabel, null);
      expect(button.autofocus, false);
    });

    test('creates button with action callback', () {
      var clicked = false;
      final button = GuxButton.fromJson(
        {
          'style': {},
          'child': 'Click Me',
          'onPressed': 'handleClick',
        },
        actions: {
          'handleClick': () => clicked = true,
        },
      );

      expect(button.onPressed, isNotNull);
      button.onPressed!();
      expect(clicked, true);
    });

    test('creates button with semantics label', () {
      final button = GuxButton.fromJson(
        {
          'style': {},
          'child': 'Click Me',
          'semanticsLabel': 'Submit button',
        },
        actions: {},
      );

      expect(button.semanticsLabel, 'Submit button');
    });

    test('creates button with autofocus', () {
      final button = GuxButton.fromJson(
        {
          'style': {},
          'child': 'Click Me',
          'autofocus': true,
        },
        actions: {},
      );

      expect(button.autofocus, true);
    });

    test('parses style colors correctly', () {
      final button = GuxButton.fromJson(
        {
          'style': {
            'backgroundColor': 'rgb(255, 0, 0)',
            'hoverColor': '#00FF00',
            'pressedColor': '0x0000FF',
            'disabledColor': 'gray',
            'foregroundColor': 'white',
            'disabledForegroundColor': 'black',
          },
          'child': 'Button',
        },
        actions: {},
      );

      expect(button.style.backgroundColor, const Color(0xFFFF0000));
      expect(button.style.hoverColor, const Color(0xFF00FF00));
      expect(button.style.pressedColor, const Color(0xFF0000FF));
      expect(button.style.disabledColor, const Color(0xFF808080));
      expect(button.style.foregroundColor, const Color(0xFFFFFFFF));
      expect(button.style.disabledForegroundColor, const Color(0xFF000000));
    });

    test('parses style padding correctly', () {
      final button = GuxButton.fromJson(
        {
          'style': {
            'backgroundColor': '#000000',
            'hoverColor': '#000000',
            'pressedColor': '#000000',
            'disabledColor': '#000000',
            'foregroundColor': '#FFFFFF',
            'disabledForegroundColor': '#FFFFFF',
            'padding': {'horizontal': 16, 'vertical': 8},
          },
          'child': 'Button',
        },
        actions: {},
      );

      expect(button.style.padding,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
    });
  });

  group('GuxButtonStyle JSON serialization', () {
    test('roundtrip serialization preserves values', () {
      const original = GuxButtonStyle(
        backgroundColor: Color(0xFF3B82F6),
        hoverColor: Color(0xFF2563EB),
        pressedColor: Color(0xFF1D4ED8),
        disabledColor: Color(0xFF9CA3AF),
        foregroundColor: Color(0xFFFFFFFF),
        disabledForegroundColor: Color(0xFFD1D5DB),
        focusColor: Color(0xFF3B82F6),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        minimumSize: Size(100, 40),
        borderRadius: BorderRadius.all(Radius.circular(6)),
        textStyle: TextStyle(fontSize: 14),
      );

      final json = original.toJson();
      final restored = GuxButtonStyle.fromJson(json);

      expect(restored.backgroundColor, original.backgroundColor);
      expect(restored.hoverColor, original.hoverColor);
      expect(restored.pressedColor, original.pressedColor);
      expect(restored.disabledColor, original.disabledColor);
      expect(restored.foregroundColor, original.foregroundColor);
      expect(restored.disabledForegroundColor, original.disabledForegroundColor);
      expect(restored.focusColor, original.focusColor);
      expect(restored.padding, original.padding);
      expect(restored.minimumSize, original.minimumSize);
      expect(restored.textStyle.fontSize, original.textStyle.fontSize);
    });
  });

  group('GuxJsonRenderer integration', () {
    test('can render GuxButton via registry', () {
      // Register GuxButton
      GuxJsonRenderer.register('gux.button', (props, actions) {
        return GuxButton.fromJson(props, actions: actions);
      });

      final widget = GuxJsonRenderer.build({
        'type': 'gux.button',
        'props': {
          'style': {
            'backgroundColor': '#3B82F6',
            'hoverColor': '#2563EB',
            'pressedColor': '#1D4ED8',
            'disabledColor': '#9CA3AF',
            'foregroundColor': '#FFFFFF',
            'disabledForegroundColor': '#D1D5DB',
          },
          'child': 'Click',
        },
      });

      expect(widget, isA<GuxButton>());

      // Cleanup
      GuxJsonRenderer.clear();
    });
  });
}
