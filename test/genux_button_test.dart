import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

const style = GenuxButtonStyle(
  backgroundColor: Color(0xFF303030),
  hoverColor: Color(0xFF383838),
  pressedColor: Color(0xFF252525),
  disabledColor: Color(0xFF101010),
  foregroundColor: Color(0xFFECECEC),
  disabledForegroundColor: Color(0xFF8E8E8E),
);

Widget host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: FocusScope(
    child: DefaultTextStyle(
      style: const TextStyle(),
      child: Center(child: child),
    ),
  ),
);

void main() {
  testWidgets('pointer, keyboard and semantics activate the button', (
    tester,
  ) async {
    var presses = 0;
    final focus = FocusNode();
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        GenuxButton(
          onPressed: () => presses++,
          style: style,
          focusNode: focus,
          child: const Text('Save'),
        ),
      ),
    );

    final button = find.byType(GenuxButton);
    await tester.tap(button);
    expect(presses, 1);

    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(presses, 3);

    expect(
      tester.getSemantics(button),
      matchesSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        isFocused: true,
        hasTapAction: true,
        hasFocusAction: true,
        label: 'Save',
      ),
    );
    tester.semantics.tap(find.semantics.byLabel('Save'));
    expect(presses, 4);
    await tester.pumpWidget(const SizedBox());
    focus.dispose();
    semantics.dispose();
  });

  testWidgets('disabled button cannot activate and reports its state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const GenuxButton(
          onPressed: null,
          style: style,
          child: Text('Disabled'),
        ),
      ),
    );
    final button = find.byType(GenuxButton);
    expect(
      tester.getSemantics(button),
      matchesSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        label: 'Disabled',
      ),
    );
    await tester.tap(button);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('hover and press colors update and reset on disable', (
    tester,
  ) async {
    final previousStrategy = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy = previousStrategy,
    );
    var enabled = true;
    late StateSetter update;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return GenuxButton(
              onPressed: enabled ? () {} : null,
              style: style,
              child: const Text('Action'),
            );
          },
        ),
      ),
    );
    Color? color() => tester
        .widget<DecoratedBox>(
          find.descendant(
            of: find.byType(GenuxButton),
            matching: find.byType(DecoratedBox),
          ),
        )
        .decoration
        .letColor;
    expect(color(), style.backgroundColor);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('Action')));
    await tester.pump();
    expect(color(), style.hoverColor);
    await mouse.down(tester.getCenter(find.text('Action')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(color(), style.pressedColor);
    update(() => enabled = false);
    await tester.pump();
    expect(color(), style.disabledColor);
    await mouse.up();
    await mouse.removePointer();
  });
}

extension on Decoration {
  Color? get letColor => (this as BoxDecoration).color;
}
