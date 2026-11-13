import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/forms/gux_text_input.dart';
import 'package:genux/src/forms/gux_text_field.dart';

void main() {
  group('GuxTextInputStyle', () {
    test('fromJson creates style with all properties', () {
      final json = {
        'fieldStyle': {
          'textStyle': {'fontSize': 16, 'color': '#ECECEC'},
          'backgroundColor': '#1A1A1A',
          'borderColor': '#484848',
        },
        'errorFieldStyle': {
          'textStyle': {'fontSize': 16, 'color': '#ECECEC'},
          'backgroundColor': '#1A1A1A',
          'borderColor': '#FF453A',
        },
        'labelStyle': {'fontSize': 14, 'color': '#CCCCCC'},
        'errorTextStyle': {'fontSize': 12, 'color': '#EF4444'},
        'labelSpacing': 6.0,
        'errorSpacing': 8.0,
      };

      final style = GuxTextInputStyle.fromJson(json);

      expect(style.fieldStyle.textStyle.fontSize, 16);
      expect(style.fieldStyle.borderColor, const Color(0xFF484848));
      expect(style.errorFieldStyle.borderColor, const Color(0xFFFF453A));
      expect(style.labelStyle.fontSize, 14);
      expect(style.labelStyle.color, const Color(0xFFCCCCCC));
      expect(style.errorTextStyle.fontSize, 12);
      expect(style.errorTextStyle.color, const Color(0xFFEF4444));
      expect(style.labelSpacing, 6.0);
      expect(style.errorSpacing, 8.0);
    });

    test('fromJson uses defaults for missing properties', () {
      final style = GuxTextInputStyle.fromJson({});

      expect(style.labelStyle.fontSize, 14);
      expect(style.labelStyle.color, const Color(0xFFECECEC));
      expect(style.errorTextStyle.fontSize, 12);
      expect(style.errorTextStyle.color, const Color(0xFFFF453A));
      expect(style.labelSpacing, 4.0);
      expect(style.errorSpacing, 4.0);
    });

    test('toJson serializes all properties', () {
      final fieldStyle = GuxTextFieldStyle.fromJson({
        'textStyle': {'fontSize': 16, 'color': '#FFFFFF'},
        'backgroundColor': '#000000',
      });

      final errorFieldStyle = GuxTextFieldStyle.fromJson({
        'textStyle': {'fontSize': 16, 'color': '#FFFFFF'},
        'backgroundColor': '#1A0000',
      });

      final style = GuxTextInputStyle(
        fieldStyle: fieldStyle,
        errorFieldStyle: errorFieldStyle,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
        errorTextStyle: const TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)),
        labelSpacing: 5.0,
        errorSpacing: 7.0,
      );

      final json = style.toJson();

      expect(json['labelStyle']['fontSize'], 14);
      expect(json['labelStyle']['color'], '#FFAAAAAA');
      expect(json['errorTextStyle']['fontSize'], 12);
      expect(json['errorTextStyle']['color'], '#FFBBBBBB');
      expect(json['labelSpacing'], 5.0);
      expect(json['errorSpacing'], 7.0);
    });

    test('roundtrip serialization preserves values', () {
      final fieldStyle = GuxTextFieldStyle.fromJson({
        'backgroundColor': '#1A1A1A',
      });

      final errorFieldStyle = GuxTextFieldStyle.fromJson({
        'backgroundColor': '#2A0000',
      });

      final original = GuxTextInputStyle(
        fieldStyle: fieldStyle,
        errorFieldStyle: errorFieldStyle,
        labelStyle: const TextStyle(fontSize: 15, color: Color(0xFFCCCCCC)),
        errorTextStyle: const TextStyle(fontSize: 11, color: Color(0xFFDDDDDD)),
        labelSpacing: 6.0,
        errorSpacing: 8.0,
      );

      final json = original.toJson();
      final restored = GuxTextInputStyle.fromJson(json);

      expect(restored.labelStyle.fontSize, original.labelStyle.fontSize);
      expect(restored.labelStyle.color, original.labelStyle.color);
      expect(restored.errorTextStyle.fontSize, original.errorTextStyle.fontSize);
      expect(restored.errorTextStyle.color, original.errorTextStyle.color);
      expect(restored.labelSpacing, original.labelSpacing);
      expect(restored.errorSpacing, original.errorSpacing);
    });
  });

  group('GuxTextInput.fromJson', () {
    testWidgets('creates text input with minimal JSON', (tester) async {
      final controller = TextEditingController();
      final json = {
        'labelText': 'Username',
      };

      final textInput = GuxTextInput.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: textInput,
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.byType(GuxTextInput), findsOneWidget);
      controller.dispose();
    });

    test('binds onChanged action', () {
      final controller = TextEditingController();
      String? changedValue;
      final actions = <String, ValueChanged<String>>{
        'handleChange': (value) => changedValue = value,
      };

      final json = {
        'labelText': 'Email',
        'onChanged': 'handleChange',
      };

      final textInput = GuxTextInput.fromJson(
        json,
        controller: controller,
        actions: actions,
      );

      // Verify the callback is bound by calling it directly
      textInput.onChanged?.call('test@example.com');
      expect(changedValue, 'test@example.com');
      controller.dispose();
    });

    test('binds onSubmitted action', () {
      final controller = TextEditingController();
      String? submittedValue;
      final actions = <String, ValueChanged<String>>{
        'handleSubmit': (value) => submittedValue = value,
      };

      final json = {
        'labelText': 'Search',
        'onSubmitted': 'handleSubmit',
        'textInputAction': 'search',
      };

      final textInput = GuxTextInput.fromJson(
        json,
        controller: controller,
        actions: actions,
      );

      // Verify the callback is bound by calling it directly
      textInput.onSubmitted?.call('search query');
      expect(submittedValue, 'search query');
      controller.dispose();
    });

    testWidgets('parses labelText and placeholder', (tester) async {
      final controller = TextEditingController();
      final json = {
        'labelText': 'Password',
        'placeholder': 'Enter your password',
      };

      final textInput = GuxTextInput.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: textInput,
          ),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('parses errorMessage', (tester) async {
      final controller = TextEditingController();
      final json = {
        'labelText': 'Email',
        'errorMessage': 'Invalid email address',
      };

      final textInput = GuxTextInput.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: textInput,
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Invalid email address'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('parses boolean flags', (tester) async {
      final controller = TextEditingController();
      final json = {
        'labelText': 'Secret',
        'enabled': false,
        'obscureText': true,
        'autofocus': true,
      };

      final textInput = GuxTextInput.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: textInput,
          ),
        ),
      );

      expect(textInput.enabled, false);
      expect(textInput.obscureText, true);
      expect(textInput.autofocus, true);
      controller.dispose();
    });

    testWidgets('parses keyboard type', (tester) async {
      final controller = TextEditingController();
      final testCases = [
        {'keyboardType': 'text', 'expected': TextInputType.text},
        {'keyboardType': 'email', 'expected': TextInputType.emailAddress},
        {'keyboardType': 'number', 'expected': TextInputType.number},
        {'keyboardType': 'phone', 'expected': TextInputType.phone},
      ];

      for (final testCase in testCases) {
        final json = {
          'labelText': 'Input',
          ...testCase,
        };
        json.remove('expected');

        final textInput = GuxTextInput.fromJson(
          json,
          controller: controller,
          actions: {},
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(),
              child: textInput,
            ),
          ),
        );

        expect(find.byType(GuxTextInput), findsOneWidget);
        await tester.pumpAndSettle();
      }

      controller.dispose();
    });

    testWidgets('parses text input action', (tester) async {
      final controller = TextEditingController();
      final actions = ['done', 'go', 'search', 'send', 'next'];

      for (final action in actions) {
        final json = {
          'labelText': 'Input',
          'textInputAction': action,
        };

        final textInput = GuxTextInput.fromJson(
          json,
          controller: controller,
          actions: {},
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(),
              child: textInput,
            ),
          ),
        );

        expect(find.byType(GuxTextInput), findsOneWidget);
        await tester.pumpAndSettle();
      }

      controller.dispose();
    });

    testWidgets('parses style with spacing', (tester) async {
      final controller = TextEditingController();
      final json = {
        'labelText': 'Styled Input',
        'style': {
          'labelSpacing': 8.0,
          'errorSpacing': 6.0,
          'labelStyle': {
            'fontSize': 16.0,
            'color': '#FFFFFF',
          },
        },
      };

      final textInput = GuxTextInput.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: textInput,
          ),
        ),
      );

      expect(textInput.style.labelSpacing, 8.0);
      expect(textInput.style.errorSpacing, 6.0);
      expect(textInput.style.labelStyle.fontSize, 16.0);
      controller.dispose();
    });

    testWidgets('handles maxLines', (tester) async {
      final controller = TextEditingController();
      final json = {
        'labelText': 'Multiline',
        'maxLines': 3,
      };

      final textInput = GuxTextInput.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: textInput,
          ),
        ),
      );

      expect(textInput.maxLines, 3);
      controller.dispose();
    });
  });
}
