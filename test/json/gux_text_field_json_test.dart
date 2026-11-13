import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/forms/gux_text_field.dart';

void main() {
  group('GuxTextFieldStyle', () {
    test('fromJson creates style with all properties', () {
      final json = {
        'inputStyle': {
          'textStyle': {'fontSize': 14.0, 'color': '#ECECEC'},
          'backgroundColor': '#252525',
          'disabledBackgroundColor': '#1F1F1F',
          'borderColor': '#484848',
          'focusedBorderColor': '#3B82F6',
          'errorBorderColor': '#FF453A',
          'cursorColor': '#3B82F6',
          'selectionColor': '#803B82F6',
          'placeholderStyle': {'fontSize': 14.0, 'color': '#8E8E8E'},
          'errorStyle': {'fontSize': 12.0, 'color': '#FF453A'},
        },
        'errorInputStyle': {
          'textStyle': {'fontSize': 14.0, 'color': '#ECECEC'},
          'backgroundColor': '#252525',
          'disabledBackgroundColor': '#1F1F1F',
          'borderColor': '#FF453A',
          'focusedBorderColor': '#FF453A',
          'errorBorderColor': '#FF453A',
          'cursorColor': '#3B82F6',
          'selectionColor': '#803B82F6',
          'placeholderStyle': {'fontSize': 14.0, 'color': '#8E8E8E'},
          'errorStyle': {'fontSize': 12.0, 'color': '#FF453A'},
        },
        'labelStyle': {'fontSize': 14.0, 'color': '#ECECEC'},
        'errorTextStyle': {'fontSize': 12.0, 'color': '#FF453A'},
        'labelSpacing': 6.0,
        'errorSpacing': 4.0,
      };

      final style = GuxTextFieldStyle.fromJson(json);

      expect(style.labelStyle.fontSize, 14.0);
      expect(style.errorTextStyle.fontSize, 12.0);
      expect(style.labelSpacing, 6.0);
      expect(style.errorSpacing, 4.0);
    });

    test('toJson produces valid JSON', () {
      final style = GuxTextFieldStyle.fromJson({});
      final json = style.toJson();

      expect(json['inputStyle'], isA<Map<String, dynamic>>());
      expect(json['errorInputStyle'], isA<Map<String, dynamic>>());
      expect(json['labelStyle'], isA<Map<String, dynamic>>());
      expect(json['errorTextStyle'], isA<Map<String, dynamic>>());
    });
  });
}
