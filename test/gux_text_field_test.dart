import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

const inputStyle = GuxTextInputStyle(
  textStyle: TextStyle(color: Color(0xffeeeeee), fontSize: 14),
  backgroundColor: Color(0xff252525),
  disabledBackgroundColor: Color(0xff111111),
  borderColor: Color(0xff333333),
  focusedBorderColor: Color(0xff0000ff),
  errorBorderColor: Color(0xffff0000),
  cursorColor: Color(0xffffffff),
  selectionColor: Color(0xff555555),
  placeholderStyle: TextStyle(color: Color(0xffaaaaaa)),
  errorStyle: TextStyle(color: Color(0xffff0000)),
);

const fieldStyle = GuxTextFieldStyle(
  inputStyle: inputStyle,
  errorInputStyle: inputStyle,
  labelStyle: TextStyle(fontSize: 14, color: Color(0xFFECECEC)),
  errorTextStyle: TextStyle(fontSize: 12, color: Color(0xFFFF453A)),
  labelSpacing: 4.0,
  errorSpacing: 4.0,
);

void main() {
  group('GuxTextField', () {
    testWidgets('displays label text', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxTextField(
            controller: controller,
            style: fieldStyle,
            labelText: 'Email',
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('displays error message', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxTextField(
            controller: controller,
            style: fieldStyle,
            labelText: 'Email',
            errorMessage: 'Invalid email',
          ),
        ),
      );

      expect(find.text('Invalid email'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('wraps GuxTextInput', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxTextField(
            controller: controller,
            style: fieldStyle,
            labelText: 'Email',
          ),
        ),
      );

      expect(find.byType(GuxTextInput), findsOneWidget);
      controller.dispose();
    });
  });
}
