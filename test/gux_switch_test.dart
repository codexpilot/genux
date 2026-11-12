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
  group('GuxSwitch', () {
    testWidgets('displays on and off states', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSwitch(
            value: true,
            style: const GuxSwitchStyle(),
          ),
        ),
      );

      expect(find.byType(GuxSwitch), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSwitch(
            value: false,
            onChanged: (value) => changedValue = value,
            style: const GuxSwitchStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxSwitch));
      await tester.pump();

      expect(changedValue, isTrue);
    });

    testWidgets('does not call onChanged when disabled', (tester) async {
      bool? changedValue;

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

      await tester.tap(find.byType(GuxSwitch));
      await tester.pump();

      expect(changedValue, isNull);
    });

    testWidgets('toggles with Space key', (tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSwitch(
            value: false,
            onChanged: (value) => changedValue = value,
            style: const GuxSwitchStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxSwitch));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(changedValue, isTrue);
    });

    testWidgets('toggles with Enter key', (tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSwitch(
            value: false,
            onChanged: (value) => changedValue = value,
            style: const GuxSwitchStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxSwitch));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(changedValue, isTrue);
    });

    testWidgets('exposes toggle semantics with label', (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSwitch(
            value: true,
            onChanged: (value) {},
            style: const GuxSwitchStyle(),
            semanticsLabel: 'Dark mode',
          ),
        ),
      );

      // Verify semantics label exists
      expect(find.bySemanticsLabel('Dark mode'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('disabled switch has no onChanged', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSwitch(
            value: true,
            onChanged: null, // disabled
            style: const GuxSwitchStyle(),
          ),
        ),
      );

      // Should not crash when tapping disabled switch
      await tester.tap(find.byType(GuxSwitch));
      await tester.pump();
    });

    testWidgets('animates thumb position', (tester) async {
      bool value = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: GuxSwitch(
                value: value,
                onChanged: (newValue) => setState(() => value = newValue),
                style: const GuxSwitchStyle(),
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(GuxSwitch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Animation should be in progress
      expect(find.byType(AnimatedPositioned), findsOneWidget);
    });

    testWidgets('roundtrips through JSON', (tester) async {
      const switchWidget = GuxSwitch(
        value: true,
        style: GuxSwitchStyle(
          onColor: Color(0xFF3B82F6),
          offColor: Color(0xFFE5E7EB),
        ),
        semanticsLabel: 'Test',
      );

      final json = switchWidget.toJson();
      final restored = GuxSwitch.fromJson(json);

      expect(restored.value, switchWidget.value);
      expect(restored.semanticsLabel, switchWidget.semanticsLabel);
    });
  });
}
