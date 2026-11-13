import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/forms/gux_text_input.dart';

void main() {
  group('GuxTextInputStyle', () {
    test('fromJson creates style with all properties', () {
      final json = {
        'textStyle': {'fontSize': 16.0, 'color': '#ECECEC'},
        'backgroundColor': '#1A1A1A',
        'disabledBackgroundColor': '#0F0F0F',
        'borderColor': '#333333',
        'focusedBorderColor': '#0066FF',
        'errorBorderColor': '#FF0000',
        'cursorColor': '#FFFFFF',
        'selectionColor': '#555555',
        'placeholderStyle': {'fontSize': 14.0, 'color': '#999999'},
        'errorStyle': {'fontSize': 12.0, 'color': '#FF0000'},
        'padding': {'left': 12.0, 'top': 8.0, 'right': 12.0, 'bottom': 8.0},
        'borderRadius': 4.0,
      };

      final style = GuxTextInputStyle.fromJson(json);

      expect(style.textStyle.fontSize, 16.0);
      expect(style.backgroundColor, const Color(0xFF1A1A1A));
      expect(style.borderColor, const Color(0xFF333333));
    });

    test('fromJson uses defaults for missing properties', () {
      final style = GuxTextInputStyle.fromJson({});

      expect(style.textStyle, isNotNull);
      expect(style.backgroundColor, isNotNull);
      expect(style.cursorColor, isNotNull);
    });

    test('toJson roundtrips correctly', () {
      const original = GuxTextInputStyle(
        textStyle: TextStyle(fontSize: 18.0, color: Color(0xFFFFFFFF)),
        backgroundColor: Color(0xFF112233),
        disabledBackgroundColor: Color(0xFF001122),
        borderColor: Color(0xFF445566),
        focusedBorderColor: Color(0xFF778899),
        errorBorderColor: Color(0xFFFF0000),
        cursorColor: Color(0xFF00FF00),
        selectionColor: Color(0xFF0000FF),
        placeholderStyle: TextStyle(fontSize: 14.0, color: Color(0xFF888888)),
        errorStyle: TextStyle(fontSize: 12.0, color: Color(0xFFFF0000)),
      );

      final json = original.toJson();
      final restored = GuxTextInputStyle.fromJson(json);

      expect(restored.textStyle.fontSize, original.textStyle.fontSize);
      expect(restored.backgroundColor, original.backgroundColor);
      expect(restored.borderColor, original.borderColor);
    });
  });
}
