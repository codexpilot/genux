import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

const fieldStyle = GuxTextInputStyle(
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

Widget host(Widget child) => WidgetsApp(
  color: const Color(0xff000000),
  builder: (context, _) => Overlay(
    initialEntries: [
      OverlayEntry(
        builder: (_) => Center(child: SizedBox(width: 240, child: child)),
      ),
    ],
  ),
);

void main() {
  testWidgets('accepts text, exposes focus, and submits keyboard input', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    final semantics = tester.ensureSemantics();
    final changes = <String>[];
    String? submitted;
    await tester.pumpWidget(
      host(
        GuxTextInput(
          controller: controller,
          focusNode: focus,
          style: fieldStyle,
          semanticsLabel: 'Username',
          placeholder: 'Enter username',
          onChanged: changes.add,
          onSubmitted: (value) => submitted = value,
          textInputAction: TextInputAction.done,
        ),
      ),
    );
    expect(find.text('Enter username'), findsOneWidget);
    expect(
      find.semantics
          .byLabel('Username')
          .evaluate()
          .single
          .getSemanticsData()
          .hint,
      'Enter username',
    );
    await tester.tap(find.byType(GuxTextInput));
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    await tester.enterText(find.byType(EditableText), 'Alice');
    await tester.pump();
    expect(controller.text, 'Alice');
    expect(changes, ['Alice']);
    expect(find.text('Enter username'), findsNothing);
    expect(
      find.semantics
          .byLabel('Username')
          .evaluate()
          .single
          .getSemanticsData()
          .hint,
      isEmpty,
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(controller.selection.textInside(controller.text), 'e');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(submitted, 'Alice');
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });

  testWidgets('obscured input retains value without exposing it to semantics', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        GuxTextInput(
          controller: controller,
          style: fieldStyle,
          semanticsLabel: 'Password',
          obscureText: true,
        ),
      ),
    );
    await tester.enterText(find.byType(EditableText), 'secret');
    await tester.pump();
    expect(controller.text, 'secret');
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isTrue,
    );
    final nodes = tester.getSemantics(find.byType(GuxTextInput));
    expect(nodes.toStringDeep(), isNot(contains('secret')));
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });

  testWidgets('disabled fields cannot focus and errors expose validation', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'unchanged');
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        GuxTextInput(
          controller: controller,
          focusNode: focus,
          style: fieldStyle,
          semanticsLabel: 'Account',
          errorText: 'Account is required',
          enabled: false,
        ),
      ),
    );
    await tester.tap(find.byType(GuxTextInput), warnIfMissed: false);
    await tester.pump();
    expect(focus.hasFocus, isFalse);
    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isFalse);
    expect(controller.text, 'unchanged');
    expect(find.text('Account is required'), findsOneWidget);
    final fieldSemantics = find.semantics.byLabel('Account').evaluate().single;
    expect(
      fieldSemantics.getSemanticsData().validationResult,
      SemanticsValidationResult.invalid,
    );
    expect(
      fieldSemantics.getSemanticsData().flagsCollection.isEnabled,
      Tristate.isFalse,
    );
    expect(
      fieldSemantics.getSemanticsData().flagsCollection.isFocused,
      Tristate.none,
    );
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });

  testWidgets('read-only fields preserve their text while allowing focus', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'fixed');
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      host(
        GuxTextInput(
          controller: controller,
          focusNode: focus,
          style: fieldStyle,
          semanticsLabel: 'Reference',
          readOnly: true,
        ),
      ),
    );
    await tester.tap(find.byType(GuxTextInput));
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).readOnly,
      isTrue,
    );
    expect(controller.text, 'fixed');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('secondary click shows localized menu and copies selected text', (
    tester,
  ) async {
    String? copied;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String?;
      }
      if (call.method == 'Clipboard.hasStrings') return {'value': false};
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final controller = TextEditingController(text: 'hello world');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        GuxTextInput(
          controller: controller,
          style: fieldStyle,
          semanticsLabel: 'Message',
          selectionMenuStyle: const GuxTextSelectionMenuStyle(
            copyLabel: 'Copy text',
          ),
        ),
      ),
    );
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 11);
    await tester.pump();
    await tester.tapAt(
      tester.getCenter(find.byType(EditableText)),
      buttons: kSecondaryMouseButton,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Copy text'), findsOneWidget);
    await tester.tap(find.text('Copy text'));
    await tester.pump();
    expect(copied, 'hello world');
    expect(find.text('Copy text'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('read-only and obscured selection menus respect editing rules', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        GuxTextInput(
          controller: controller,
          style: fieldStyle,
          semanticsLabel: 'Read only',
          readOnly: true,
        ),
      ),
    );
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 5);
    await tester.pump();
    tester.state<EditableTextState>(find.byType(EditableText)).showToolbar();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Cut'), findsNothing);
    expect(find.text('Paste'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('Copy'), findsNothing);
    await tester.pumpWidget(const SizedBox());

    await tester.pumpWidget(
      host(
        GuxTextInput(
          controller: controller,
          style: fieldStyle,
          semanticsLabel: 'Password',
          obscureText: true,
        ),
      ),
    );
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 5);
    await tester.pump();
    tester.state<EditableTextState>(find.byType(EditableText)).showToolbar();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Copy'), findsNothing);
    expect(find.text('Cut'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('selected text exposes copy and cut semantics actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final controller = TextEditingController(text: 'hello');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        GuxTextInput(
          controller: controller,
          style: fieldStyle,
          semanticsLabel: 'Text',
        ),
      ),
    );
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 5);
    await tester.pump();
    final data = find.semantics
        .byLabel('Text')
        .evaluate()
        .single
        .getSemanticsData();
    expect(data.hasAction(SemanticsAction.copy), isTrue);
    expect(data.hasAction(SemanticsAction.cut), isTrue);
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });

  // Context menu and selection handles require platform-specific implementation.
  // Flutter's EditableText provides showSelectionHandles property but the actual
  // handles and context menu rendering depend on TextSelectionControls which are
  // framework-specific (Material/Cupertino). Genux needs a framework-independent
  // implementation or explicit platform adapter integration.
  // Tracked in P1 work: implement platform-appropriate selection UI or document
  // as requiring host-provided TextSelectionControls.
  testWidgets(
    'touch long-press presents a selection and its handles',
    skip: true,
    (tester) async {
    final controller = TextEditingController(text: 'hello world');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        GuxTextInput(
          controller: controller,
          style: fieldStyle,
          semanticsLabel: 'Text',
        ),
      ),
    );
    await tester.longPress(find.byType(EditableText));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(controller.selection.isCollapsed, isFalse);
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText))
          .showSelectionHandles,
      isTrue,
    );
    expect(find.text('Copy'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
