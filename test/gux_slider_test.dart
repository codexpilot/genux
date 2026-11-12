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
  group('GuxSlider', () {
    testWidgets('displays value as fraction of range', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
            style: const GuxSliderStyle(),
          ),
        ),
      );

      expect(find.byType(GuxSlider), findsOneWidget);
    });

    testWidgets('clamps value within range during interaction', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSlider(
            value: 100.0, // at max
            min: 0.0,
            max: 100.0,
            onChanged: (value) => changedValue = value,
            style: const GuxSliderStyle(),
          ),
        ),
      );

      // Try to increment beyond max
      await tester.tap(find.byType(GuxSlider));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // Value should remain at max
      expect(changedValue, equals(100.0));
    });

    testWidgets('calls onChanged on tap', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
            onChanged: (value) => changedValue = value,
            style: const GuxSliderStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      expect(changedValue, isNotNull);
    });

    testWidgets('does not call onChanged when disabled', (tester) async {
      double? changedValue;

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

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      expect(changedValue, isNull);
    });

    testWidgets('increments value with right arrow key', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
            onChanged: (value) => changedValue = value,
            style: const GuxSliderStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(changedValue, greaterThan(50.0));
    });

    testWidgets('decrements value with left arrow key', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
            onChanged: (value) => changedValue = value,
            style: const GuxSliderStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(changedValue, lessThan(50.0));
    });

    testWidgets('sets value to min with Home key', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
            onChanged: (value) => changedValue = value,
            style: const GuxSliderStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();

      expect(changedValue, equals(0.0));
    });

    testWidgets('sets value to max with End key', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
            onChanged: (value) => changedValue = value,
            style: const GuxSliderStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();

      expect(changedValue, equals(100.0));
    });

    testWidgets('respects RTL direction', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: GuxSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
            onChanged: (value) => changedValue = value,
            style: const GuxSliderStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      // In RTL, right arrow should decrement
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(changedValue, lessThan(50.0));
    });

    testWidgets('snaps to divisions when specified', (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
            divisions: 10, // 0, 10, 20, ..., 100
            onChanged: (value) => changedValue = value,
            style: const GuxSliderStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxSlider));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // Value should snap to division
      expect(changedValue, isNotNull);
      expect(changedValue! % 10, equals(0.0));
    });

    testWidgets('exposes slider semantics with increase/decrease actions', (tester) async {
      final semantics = tester.ensureSemantics();
      double value = 50.0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: GuxSlider(
                value: value,
                min: 0.0,
                max: 100.0,
                onChanged: (newValue) => setState(() => value = newValue),
                style: const GuxSliderStyle(),
                semanticsLabel: 'Volume',
              ),
            );
          },
        ),
      );

      // Verify semantics label exists
      expect(find.bySemanticsLabel('Volume'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('disabled slider has no onChanged', (tester) async {
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

      // Should not crash when tapping disabled slider
      await tester.tap(find.byType(GuxSlider));
      await tester.pump();
    });

    testWidgets('roundtrips through JSON', (tester) async {
      const slider = GuxSlider(
        value: 50.0,
        min: 0.0,
        max: 100.0,
        divisions: 10,
        style: GuxSliderStyle(
          activeTrackColor: Color(0xFF3B82F6),
          trackColor: Color(0xFFE5E7EB),
        ),
        semanticsLabel: 'Test',
      );

      final json = slider.toJson();
      final restored = GuxSlider.fromJson(json);

      expect(restored.value, slider.value);
      expect(restored.min, slider.min);
      expect(restored.max, slider.max);
      expect(restored.divisions, slider.divisions);
      expect(restored.semanticsLabel, slider.semanticsLabel);
    });
  });
}
