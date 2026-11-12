// Copyright 2025 AIX Project
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

class _TestRadioGroup extends StatefulWidget {
  final String? initialValue;
  final List<String> options;
  final Axis axis;
  final double spacing;
  final bool disableMiddle;
  final TextDirection textDirection;

  const _TestRadioGroup({
    this.initialValue,
    required this.options,
    this.axis = Axis.vertical,
    this.spacing = 8.0,
    this.disableMiddle = false,
    this.textDirection = TextDirection.ltr,
  });

  @override
  State<_TestRadioGroup> createState() => _TestRadioGroupState();
}

class _TestRadioGroupState extends State<_TestRadioGroup> {
  late String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.textDirection,
      child: GuxRadioGroup<String>(
        value: selectedValue,
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
        },
        axis: widget.axis,
        spacing: widget.spacing,
        children: [
          for (int i = 0; i < widget.options.length; i++)
            GuxRadio(
              value: widget.options[i],
              groupValue: selectedValue,
              onChanged: (widget.disableMiddle && i == 1)
                  ? null
                  : (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
              style: const GuxRadioStyle(),
            ),
        ],
      ),
    );
  }
}

String? _getSelectedValue(WidgetTester tester) {
  final radio = tester.widget<GuxRadio>(find.byType(GuxRadio).first);
  return radio.groupValue;
}

// Helper to establish focus on a radio without changing selection
Future<void> _focusRadio(WidgetTester tester, {int index = 0}) async {
  await tester.tap(find.byType(GuxRadio).at(index));
  await tester.pump();
}

// Helper to establish focus on the currently selected radio
Future<void> _focusSelectedRadio(WidgetTester tester) async {
  final radios = tester.widgetList<GuxRadio>(find.byType(GuxRadio));
  int selectedIndex = 0;
  int i = 0;
  for (final radio in radios) {
    if (radio.value == radio.groupValue) {
      selectedIndex = i;
      break;
    }
    i++;
  }
  await _focusRadio(tester, index: selectedIndex);
}

void main() {
  group('GuxRadioGroup', () {
    testWidgets('displays radio buttons in vertical layout', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          options: ['small', 'medium', 'large'],
        ),
      );

      expect(find.byType(GuxRadio), findsNWidgets(3));
    });

    testWidgets('displays radio buttons in horizontal layout', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          options: ['small', 'medium'],
          axis: Axis.horizontal,
        ),
      );

      expect(find.byType(GuxRadio), findsNWidgets(2));
    });

    testWidgets('arrow down moves focus and selects next radio', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          options: ['small', 'medium', 'large'],
        ),
      );

      // Tap first radio to establish focus
      await tester.tap(find.byType(GuxRadio).first);
      await tester.pump();

      // Press arrow down
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(_getSelectedValue(tester), equals('medium'));
    });

    testWidgets('arrow up moves focus and selects previous radio', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          initialValue: 'medium',
          options: ['small', 'medium', 'large'],
        ),
      );

      // Focus currently selected radio
      await _focusSelectedRadio(tester);
      await tester.pump();

      // Press arrow up
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      expect(_getSelectedValue(tester), equals('small'));
    });

    testWidgets('wraps from last to first with arrow down', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          initialValue: 'large',
          options: ['small', 'medium', 'large'],
        ),
      );

      // Focus currently selected radio
      await _focusSelectedRadio(tester);
      await tester.pump();

      // Press arrow down (should wrap to first)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(_getSelectedValue(tester), equals('small'));
    });

    testWidgets('wraps from first to last with arrow up', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          initialValue: 'small',
          options: ['small', 'medium', 'large'],
        ),
      );

      // Focus currently selected radio
      await _focusSelectedRadio(tester);
      await tester.pump();

      // Press arrow up (should wrap to last)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      expect(_getSelectedValue(tester), equals('large'));
    });

    testWidgets('skips disabled radios during arrow navigation', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          options: ['small', 'medium', 'large'],
          disableMiddle: true,
        ),
      );

      // Focus first radio
      await _focusRadio(tester);
      await tester.pump();

      // Press arrow down (should skip disabled 'medium' and go to 'large')
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(_getSelectedValue(tester), equals('large'));
    });

    testWidgets('arrow right moves forward in LTR', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          options: ['small', 'medium'],
        ),
      );

      // Focus first radio
      await _focusRadio(tester);
      await tester.pump();

      // Press arrow right
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(_getSelectedValue(tester), equals('medium'));
    });

    testWidgets('arrow right moves backward in RTL', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          initialValue: 'medium',
          options: ['small', 'medium'],
          textDirection: TextDirection.rtl,
        ),
      );

      // Focus currently selected radio
      await _focusSelectedRadio(tester);
      await tester.pump();

      // Press arrow right (should go backward in RTL)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(_getSelectedValue(tester), equals('small'));
    });

    testWidgets('arrow left moves backward in LTR', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          initialValue: 'medium',
          options: ['small', 'medium'],
        ),
      );

      // Focus currently selected radio
      await _focusSelectedRadio(tester);
      await tester.pump();

      // Press arrow left
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(_getSelectedValue(tester), equals('small'));
    });

    testWidgets('arrow left moves forward in RTL', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          options: ['small', 'medium'],
          textDirection: TextDirection.rtl,
        ),
      );

      // Focus first radio
      await _focusRadio(tester);
      await tester.pump();

      // Press arrow left (should go forward in RTL)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(_getSelectedValue(tester), equals('medium'));
    });

    testWidgets('mouse/touch selection still works', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          options: ['small', 'medium'],
        ),
      );

      // Tap the second radio
      await tester.tap(find.byType(GuxRadio).last);
      await tester.pump();

      expect(_getSelectedValue(tester), equals('medium'));
    });

    testWidgets('respects custom spacing', (tester) async {
      await tester.pumpWidget(
        const _TestRadioGroup(
          options: ['small', 'medium'],
          spacing: 16.0,
        ),
      );

      expect(find.byType(GuxRadio), findsNWidgets(2));
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('handles empty children list', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxRadioGroup<String>(
            value: null,
            children: [],
          ),
        ),
      );

      // Should not crash
      expect(find.byType(GuxRadio), findsNothing);
    });
  });
}
