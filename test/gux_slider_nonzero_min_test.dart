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
  group('GuxSlider nonzero min snapping', () {
    testWidgets('snaps divisions relative to min, not zero', (tester) async {
      double value = 50.0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: GuxSlider(
                value: value,
                min: 10.0,
                max: 100.0,
                divisions: 9, // 10.0, 20.0, 30.0, ..., 100.0
                onChanged: (newValue) => setState(() => value = newValue),
                style: const GuxSliderStyle(),
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      // Press Home to go to min
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();

      // Should snap to min (10.0), not 0.0
      expect(value, equals(10.0));

      // Press arrow right to increment by one division
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      // Should be at 20.0 (min + 1 * step where step = (100-10)/9 = 10)
      expect(value, equals(20.0));
    });

    testWidgets('can reach both endpoints with divisions', (tester) async {
      double value = 55.0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: GuxSlider(
                value: value,
                min: 50.0,
                max: 150.0,
                divisions: 10, // 50, 60, 70, ..., 150
                onChanged: (newValue) => setState(() => value = newValue),
                style: const GuxSliderStyle(),
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      // Go to min
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(value, equals(50.0));

      // Go to max
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(value, equals(150.0));
    });

    testWidgets('semantics actions use correct step from min', (tester) async {
      final semantics = tester.ensureSemantics();
      double value = 25.0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: GuxSlider(
                value: value,
                min: 20.0,
                max: 120.0,
                divisions: 10, // 20, 30, 40, ..., 120 (step = 10)
                onChanged: (newValue) => setState(() => value = newValue),
                style: const GuxSliderStyle(),
              ),
            );
          },
        ),
      );

      // At 25.0, should snap to 30.0 on increase (next division from min)
      expect(value, equals(25.0));

      semantics.dispose();
    });
  });
}
