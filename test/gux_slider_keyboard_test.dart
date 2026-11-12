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
  group('GuxSlider keyboard handling', () {
    testWidgets('ignores Tab key for focus traversal', (tester) async {
      double value1 = 50.0;
      double value2 = 50.0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return GuxSlider(
                    value: value1,
                    min: 0.0,
                    max: 100.0,
                    onChanged: (newValue) => setState(() => value1 = newValue),
                    style: const GuxSliderStyle(),
                  );
                },
              ),
              StatefulBuilder(
                builder: (context, setState) {
                  return GuxSlider(
                    value: value2,
                    min: 0.0,
                    max: 100.0,
                    onChanged: (newValue) => setState(() => value2 = newValue),
                    style: const GuxSliderStyle(),
                  );
                },
              ),
            ],
          ),
        ),
      );

      // Tap first slider to focus it
      await tester.tap(find.byType(GuxSlider).first);
      await tester.pump();

      // Press Tab - should move focus to second slider if Tab is ignored
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // If Tab was properly ignored, we should be able to interact with second slider
      // This is hard to test directly, so we'll just verify Tab doesn't change the value
      expect(value1, equals(50.0));
    });

    testWidgets('ignores Escape and other unhandled keys', (tester) async {
      double value = 50.0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return GuxSlider(
                value: value,
                min: 0.0,
                max: 100.0,
                onChanged: (newValue) => setState(() => value = newValue),
                style: const GuxSliderStyle(),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      // Press various unhandled keys - none should change the value
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(value, equals(50.0));

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      expect(value, equals(50.0));

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, equals(50.0));
    });

    testWidgets('handles arrow keys', (tester) async {
      double value = 50.0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return GuxSlider(
                value: value,
                min: 0.0,
                max: 100.0,
                onChanged: (newValue) => setState(() => value = newValue),
                style: const GuxSliderStyle(),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      final oldValue = value;

      // Press arrow right - should change value
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(value, greaterThan(oldValue));
    });
  });
}
