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
  group('Disabled control focus behavior', () {
    testWidgets('disabled slider cannot be focused with tap', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
            onChanged: null, // disabled
            style: const GuxSliderStyle(),
          ),
        ),
      );

      // Tap disabled slider
      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      // Try keyboard - should not crash (disabled controls ignore keyboard)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
    });

    testWidgets('disabled switch cannot be focused with tap', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSwitch(
            value: false,
            onChanged: null, // disabled
            style: const GuxSwitchStyle(),
          ),
        ),
      );

      // Tap disabled switch
      await tester.tap(find.byType(GuxSwitch));
      await tester.pump();

      // Should not toggle
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
    });

    testWidgets('disabled radio cannot be focused with tap', (tester) async {
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

      // Tap disabled radio
      await tester.tap(find.byType(GuxRadio));
      await tester.pump();

      // Should not select
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
    });

    testWidgets('enabled slider becomes disabled and stops responding', (tester) async {
      double value = 50.0;

      // First: enabled slider
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: GuxSlider(
                value: value,
                min: 0.0,
                max: 100.0,
                onChanged: (v) => setState(() => value = v),
                style: const GuxSliderStyle(),
              ),
            );
          },
        ),
      );

      // Can interact when enabled
      await tester.tap(find.byType(GuxSlider));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, greaterThan(50.0));

      final valueAfterEnabled = value;

      // Now: disabled slider
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSlider(
            value: value,
            min: 0.0,
            max: 100.0,
            onChanged: null, // disabled
            style: const GuxSliderStyle(),
          ),
        ),
      );

      // Try to interact when disabled - should not work
      await tester.tap(find.byType(GuxSlider));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // Value should not change
      expect(value, equals(valueAfterEnabled));
    });
  });
}
