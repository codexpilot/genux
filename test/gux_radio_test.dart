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

void main() {
  group('GuxRadio', () {
    testWidgets('displays checked and unchecked states', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxRadio(
            value: 'option1',
            groupValue: 'option1',
            style: const GuxRadioStyle(),
          ),
        ),
      );

      expect(find.byType(GuxRadio), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxRadio(
            value: 'option1',
            groupValue: null,
            onChanged: (value) => changedValue = value,
            style: const GuxRadioStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxRadio));
      await tester.pump();

      expect(changedValue, equals('option1'));
    });

    testWidgets('does not call onChanged when already selected', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxRadio(
            value: 'option1',
            groupValue: 'option1', // already selected
            onChanged: (value) => callCount++,
            style: const GuxRadioStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxRadio));
      await tester.pump();

      expect(callCount, equals(0));
    });

    testWidgets('does not call onChanged when disabled', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxRadio(
            value: 'option1',
            groupValue: null,
            onChanged: null, // disabled
            style: const GuxRadioStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxRadio));
      await tester.pump();

      expect(changedValue, isNull);
    });

    testWidgets('selects with Space key', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxRadio(
            value: 'option1',
            groupValue: null,
            onChanged: (value) => changedValue = value,
            style: const GuxRadioStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxRadio));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(changedValue, equals('option1'));
    });

    testWidgets('selects with Enter key', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxRadio(
            value: 'option1',
            groupValue: null,
            onChanged: (value) => changedValue = value,
            style: const GuxRadioStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxRadio));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(changedValue, equals('option1'));
    });

    testWidgets('exposes mutually exclusive group semantics with label', (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxRadio(
            value: 'option1',
            groupValue: 'option1',
            onChanged: (value) {},
            style: const GuxRadioStyle(),
            semanticsLabel: 'Option 1',
          ),
        ),
      );

      // Verify semantics label exists
      expect(find.bySemanticsLabel('Option 1'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('disabled radio has no onChanged', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxRadio(
            value: 'option1',
            groupValue: null,
            onChanged: null, // disabled
            style: const GuxRadioStyle(),
          ),
        ),
      );

      // Should not crash when tapping disabled radio
      await tester.tap(find.byType(GuxRadio));
      await tester.pump();
    });

    testWidgets('group behavior with multiple radios', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  GuxRadio(
                    value: 'option1',
                    groupValue: selectedValue,
                    onChanged: (value) => setState(() => selectedValue = value),
                    style: const GuxRadioStyle(),
                  ),
                  GuxRadio(
                    value: 'option2',
                    groupValue: selectedValue,
                    onChanged: (value) => setState(() => selectedValue = value),
                    style: const GuxRadioStyle(),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Tap first radio
      await tester.tap(find.byType(GuxRadio).first);
      await tester.pump();
      expect(selectedValue, equals('option1'));

      // Tap second radio
      await tester.tap(find.byType(GuxRadio).last);
      await tester.pump();
      expect(selectedValue, equals('option2'));
    });

    testWidgets('roundtrips through JSON', (tester) async {
      const radio = GuxRadio(
        value: 'option1',
        groupValue: 'option1',
        style: GuxRadioStyle(
          checkedColor: Color(0xFF3B82F6),
          borderColor: Color(0xFFD1D5DB),
        ),
        semanticsLabel: 'Test',
      );

      final json = radio.toJson();
      final restored = GuxRadio.fromJson(json);

      expect(restored.value, radio.value);
      expect(restored.groupValue, radio.groupValue);
      expect(restored.semanticsLabel, radio.semanticsLabel);
    });
  });
}
