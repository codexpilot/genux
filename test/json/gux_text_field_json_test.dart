import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/forms/gux_text_field.dart';

void main() {
  group('GuxTextSelectionMenuStyle', () {
    test('fromJson creates style with all properties', () {
      final json = {
        'cutLabel': 'Cut Text',
        'copyLabel': 'Copy Text',
        'pasteLabel': 'Paste Text',
        'selectAllLabel': 'Select All Text',
        'backgroundColor': '#252525',
        'foregroundColor': '#ECECEC',
        'hoverColor': '#484848',
        'focusColor': '#3B82F6',
        'textStyle': {'fontSize': 12.0, 'color': '#FFFFFF'},
      };

      final style = GuxTextSelectionMenuStyle.fromJson(json);

      expect(style.cutLabel, 'Cut Text');
      expect(style.copyLabel, 'Copy Text');
      expect(style.pasteLabel, 'Paste Text');
      expect(style.selectAllLabel, 'Select All Text');
      expect(style.backgroundColor, const Color(0xFF252525));
      expect(style.foregroundColor, const Color(0xFFECECEC));
      expect(style.hoverColor, const Color(0xFF484848));
      expect(style.focusColor, const Color(0xFF3B82F6));
      expect(style.textStyle.fontSize, 12.0);
      expect(style.textStyle.color, const Color(0xFFFFFFFF));
    });

    test('fromJson uses defaults for missing properties', () {
      final style = GuxTextSelectionMenuStyle.fromJson({});

      expect(style.cutLabel, 'Cut');
      expect(style.copyLabel, 'Copy');
      expect(style.pasteLabel, 'Paste');
      expect(style.selectAllLabel, 'Select all');
      expect(style.backgroundColor, const Color(0xFF252525));
      expect(style.foregroundColor, const Color(0xFFECECEC));
    });

    test('toJson serializes all properties', () {
      const style = GuxTextSelectionMenuStyle(
        cutLabel: 'Custom Cut',
        copyLabel: 'Custom Copy',
        pasteLabel: 'Custom Paste',
        selectAllLabel: 'Custom Select',
        backgroundColor: Color(0xFF123456),
        foregroundColor: Color(0xFFABCDEF),
        hoverColor: Color(0xFF111111),
        focusColor: Color(0xFF222222),
        textStyle: TextStyle(fontSize: 14.0, color: Color(0xFF333333)),
      );

      final json = style.toJson();

      expect(json['cutLabel'], 'Custom Cut');
      expect(json['copyLabel'], 'Custom Copy');
      expect(json['pasteLabel'], 'Custom Paste');
      expect(json['selectAllLabel'], 'Custom Select');
      expect(json['backgroundColor'], '#FF123456');
      expect(json['foregroundColor'], '#FFABCDEF');
      expect(json['hoverColor'], '#FF111111');
      expect(json['focusColor'], '#FF222222');
      expect(json['textStyle']['fontSize'], 14.0);
      expect(json['textStyle']['color'], '#FF333333');
    });

    test('roundtrip serialization preserves values', () {
      const original = GuxTextSelectionMenuStyle(
        cutLabel: 'Cut It',
        copyLabel: 'Copy It',
        backgroundColor: Color(0xFF112233),
        foregroundColor: Color(0xFF445566),
      );

      final json = original.toJson();
      final restored = GuxTextSelectionMenuStyle.fromJson(json);

      expect(restored.cutLabel, original.cutLabel);
      expect(restored.copyLabel, original.copyLabel);
      expect(restored.backgroundColor, original.backgroundColor);
      expect(restored.foregroundColor, original.foregroundColor);
    });
  });

  group('GuxTextFieldStyle', () {
    test('fromJson creates style with all properties', () {
      final json = {
        'textStyle': {'fontSize': 16.0, 'color': '#ECECEC'},
        'backgroundColor': '#1A1A1A',
        'disabledBackgroundColor': '#0F0F0F',
        'borderColor': '#484848',
        'focusedBorderColor': '#3B82F6',
        'errorBorderColor': '#EF4444',
        'cursorColor': '#3B82F6',
        'selectionColor': '#803B82F6',
        'placeholderStyle': {'fontSize': 16.0, 'color': '#71717A'},
        'errorStyle': {'fontSize': 12.0, 'color': '#EF4444'},
        'padding': {'horizontal': 12, 'vertical': 8},
        'borderRadius': 6,
      };

      final style = GuxTextFieldStyle.fromJson(json);

      expect(style.textStyle.fontSize, 16.0);
      expect(style.textStyle.color, const Color(0xFFECECEC));
      expect(style.backgroundColor, const Color(0xFF1A1A1A));
      expect(style.disabledBackgroundColor, const Color(0xFF0F0F0F));
      expect(style.borderColor, const Color(0xFF484848));
      expect(style.focusedBorderColor, const Color(0xFF3B82F6));
      expect(style.errorBorderColor, const Color(0xFFEF4444));
      expect(style.cursorColor, const Color(0xFF3B82F6));
      expect(style.selectionColor, const Color(0x803B82F6));
      expect(style.placeholderStyle.color, const Color(0xFF71717A));
      expect(style.errorStyle.color, const Color(0xFFEF4444));
      expect(style.padding, const EdgeInsets.symmetric(horizontal: 12, vertical: 8));
      expect(style.borderRadius, BorderRadius.circular(6));
    });

    test('fromJson uses defaults for missing properties', () {
      final style = GuxTextFieldStyle.fromJson({});

      expect(style.textStyle.fontSize, 14.0);
      expect(style.backgroundColor, const Color(0xFF252525));
      expect(style.disabledBackgroundColor, const Color(0xFF1F1F1F));
      expect(style.borderColor, const Color(0xFF484848));
      expect(style.cursorColor, const Color(0xFF3B82F6));
    });

    test('toJson serializes all properties', () {
      final style = GuxTextFieldStyle(
        textStyle: const TextStyle(fontSize: 18.0, color: Color(0xFFFFFFFF)),
        backgroundColor: const Color(0xFF000000),
        disabledBackgroundColor: const Color(0xFF111111),
        borderColor: const Color(0xFF222222),
        focusedBorderColor: const Color(0xFF333333),
        errorBorderColor: const Color(0xFF444444),
        cursorColor: const Color(0xFF555555),
        selectionColor: const Color(0xFF666666),
        placeholderStyle: const TextStyle(fontSize: 16.0, color: Color(0xFF777777)),
        errorStyle: const TextStyle(fontSize: 12.0, color: Color(0xFF888888)),
        padding: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(8),
      );

      final json = style.toJson();

      expect(json['textStyle']['fontSize'], 18.0);
      expect(json['textStyle']['color'], '#FFFFFFFF');
      expect(json['backgroundColor'], '#FF000000');
      expect(json['disabledBackgroundColor'], '#FF111111');
      expect(json['borderColor'], '#FF222222');
      expect(json['focusedBorderColor'], '#FF333333');
      expect(json['errorBorderColor'], '#FF444444');
      expect(json['cursorColor'], '#FF555555');
      expect(json['selectionColor'], '#FF666666');
      expect(json['placeholderStyle']['color'], '#FF777777');
      expect(json['errorStyle']['color'], '#FF888888');
      expect(json['padding']['all'], 10.0);
      expect(json['borderRadius']['circular'], 8.0);
    });

    test('roundtrip serialization preserves values', () {
      final original = GuxTextFieldStyle(
        textStyle: const TextStyle(fontSize: 20.0, color: Color(0xFFFFFFFF)),
        backgroundColor: const Color(0xFFABCDEF),
        disabledBackgroundColor: const Color(0xFF888888),
        borderColor: const Color(0xFF123456),
        focusedBorderColor: const Color(0xFF3B82F6),
        errorBorderColor: const Color(0xFFEF4444),
        cursorColor: const Color(0xFF3B82F6),
        selectionColor: const Color(0x803B82F6),
        placeholderStyle: const TextStyle(fontSize: 16.0, color: Color(0xFF71717A)),
        errorStyle: const TextStyle(fontSize: 12.0, color: Color(0xFFEF4444)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: BorderRadius.circular(4),
      );

      final json = original.toJson();
      final restored = GuxTextFieldStyle.fromJson(json);

      expect(restored.textStyle.fontSize, original.textStyle.fontSize);
      expect(restored.backgroundColor, original.backgroundColor);
      expect(restored.disabledBackgroundColor, original.disabledBackgroundColor);
      expect(restored.borderColor, original.borderColor);
      expect(restored.focusedBorderColor, original.focusedBorderColor);
      expect(restored.errorBorderColor, original.errorBorderColor);
      expect(restored.cursorColor, original.cursorColor);
      expect(restored.selectionColor, original.selectionColor);
      expect(restored.padding, original.padding);
      expect(restored.borderRadius, original.borderRadius);
    });
  });

  group('GuxTextField.fromJson', () {
    testWidgets('creates text field with minimal JSON', (tester) async {
      final controller = TextEditingController();
      final json = {
        'semanticsLabel': 'Username',
      };

      final textField = GuxTextField.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: textField,
        ),
      );

      expect(find.byType(GuxTextField), findsOneWidget);
      controller.dispose();
    });

    test('binds onChanged action', () {
      final controller = TextEditingController();
      String? changedValue;
      final actions = <String, ValueChanged<String>>{
        'handleChange': (value) => changedValue = value,
      };

      final json = {
        'semanticsLabel': 'Email',
        'onChanged': 'handleChange',
      };

      final textField = GuxTextField.fromJson(
        json,
        controller: controller,
        actions: actions,
      );

      // Verify the callback is bound by calling it directly
      textField.onChanged?.call('test@example.com');
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
        'semanticsLabel': 'Search',
        'onSubmitted': 'handleSubmit',
        'textInputAction': 'search',
      };

      final textField = GuxTextField.fromJson(
        json,
        controller: controller,
        actions: actions,
      );

      // Verify the callback is bound by calling it directly
      textField.onSubmitted?.call('search query');
      expect(submittedValue, 'search query');
      controller.dispose();
    });

    testWidgets('parses placeholder and errorText', (tester) async {
      final controller = TextEditingController();
      final json = {
        'semanticsLabel': 'Password',
        'placeholder': 'Enter your password',
        'errorText': 'Password is required',
      };

      final textField = GuxTextField.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: textField,
        ),
      );

      expect(find.text('Enter your password'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('parses boolean flags', (tester) async {
      final controller = TextEditingController();
      final json = {
        'semanticsLabel': 'Secret',
        'enabled': false,
        'readOnly': true,
        'obscureText': true,
        'autofocus': true,
      };

      final textField = GuxTextField.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: textField,
          ),
        ),
      );

      expect(find.byType(GuxTextField), findsOneWidget);
      controller.dispose();
    });

    testWidgets('parses keyboard type', (tester) async {
      final controller = TextEditingController();
      final testCases = [
        {'keyboardType': 'text', 'expected': TextInputType.text},
        {'keyboardType': 'multiline', 'expected': TextInputType.multiline},
        {'keyboardType': 'number', 'expected': TextInputType.number},
        {'keyboardType': 'phone', 'expected': TextInputType.phone},
        {'keyboardType': 'email', 'expected': TextInputType.emailAddress},
        {'keyboardType': 'url', 'expected': TextInputType.url},
      ];

      for (final testCase in testCases) {
        final json = {
          'semanticsLabel': 'Input',
          ...testCase,
        };
        json.remove('expected');

        final textField = GuxTextField.fromJson(
          json,
          controller: controller,
          actions: {},
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: textField,
          ),
        );

        expect(find.byType(GuxTextField), findsOneWidget);
        await tester.pumpAndSettle();
      }

      controller.dispose();
    });

    testWidgets('parses text input action', (tester) async {
      final controller = TextEditingController();
      final testCases = [
        'done',
        'go',
        'search',
        'send',
        'next',
        'previous',
      ];

      for (final action in testCases) {
        final json = {
          'semanticsLabel': 'Input',
          'textInputAction': action,
        };

        final textField = GuxTextField.fromJson(
          json,
          controller: controller,
          actions: {},
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: textField,
          ),
        );

        expect(find.byType(GuxTextField), findsOneWidget);
        await tester.pumpAndSettle();
      }

      controller.dispose();
    });

    testWidgets('parses style with color', (tester) async {
      final controller = TextEditingController();
      final json = {
        'semanticsLabel': 'Styled Input',
        'style': {
          'backgroundColor': '#1A1A1A',
          'borderColor': '#484848',
          'textStyle': {
            'fontSize': 16.0,
            'color': '#ECECEC',
          },
        },
      };

      final textField = GuxTextField.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: textField,
        ),
      );

      expect(find.byType(GuxTextField), findsOneWidget);
      controller.dispose();
    });

    testWidgets('parses style with padding', (tester) async {
      final controller = TextEditingController();
      final json = {
        'semanticsLabel': 'Padded Input',
        'style': {
          'padding': {'horizontal': 16, 'vertical': 12},
          'borderRadius': 8,
        },
      };

      final textField = GuxTextField.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: textField,
        ),
      );

      expect(find.byType(GuxTextField), findsOneWidget);
      controller.dispose();
    });

    testWidgets('parses selection menu style', (tester) async {
      final controller = TextEditingController();
      final json = {
        'semanticsLabel': 'Custom Menu',
        'selectionMenuStyle': {
          'cutLabel': 'Cut Text',
          'copyLabel': 'Copy Text',
          'backgroundColor': '#252525',
        },
      };

      final textField = GuxTextField.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: textField,
        ),
      );

      expect(find.byType(GuxTextField), findsOneWidget);
      controller.dispose();
    });

    testWidgets('handles maxLines', (tester) async {
      final controller = TextEditingController();
      final json = {
        'semanticsLabel': 'Multiline',
        'maxLines': 5,
      };

      final textField = GuxTextField.fromJson(
        json,
        controller: controller,
        actions: {},
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: textField,
        ),
      );

      expect(find.byType(GuxTextField), findsOneWidget);
      controller.dispose();
    });
  });
}
