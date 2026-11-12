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

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  group('GuxRadio.fromJson callback compatibility', () {
    testWidgets('accepts ValueChanged<String> in action map', (tester) async {
      String? selectedValue;

      final actions = <String, ValueChanged<String>>{
        'selectOption': (value) => selectedValue = value,
      };

      final json = <String, dynamic>{
        'value': 'option1',
        'groupValue': null,
        'onChanged': 'selectOption',
        'style': <String, dynamic>{},
      };

      final radio = GuxRadio.fromJson(json, actions: actions);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: radio,
        ),
      );

      // Tap radio
      await tester.tap(find.byType(GuxRadio));
      await tester.pump();

      // Should receive the value
      expect(selectedValue, equals('option1'));
    });

    testWidgets('handles missing action key gracefully', (tester) async {
      final json = <String, dynamic>{
        'value': 'option1',
        'groupValue': null,
        // No 'onChanged' key
        'style': <String, dynamic>{},
      };

      final radio = GuxRadio.fromJson(json);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: radio,
        ),
      );

      // Should be disabled (onChanged is null)
      expect(radio.onChanged, isNull);

      // Tap should not crash
      await tester.tap(find.byType(GuxRadio));
      await tester.pump();
    });

    testWidgets('handles unknown action key gracefully', (tester) async {
      final actions = <String, ValueChanged<String>>{
        'knownAction': (value) {},
      };

      final json = <String, dynamic>{
        'value': 'option1',
        'groupValue': null,
        'onChanged': 'unknownAction', // Not in actions map
        'style': <String, dynamic>{},
      };

      final radio = GuxRadio.fromJson(json, actions: actions);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: radio,
        ),
      );

      // Should be disabled (action not found)
      expect(radio.onChanged, isNull);
    });

    testWidgets('passes correct value to callback', (tester) async {
      final receivedValues = <String>[];

      final actions = <String, ValueChanged<String>>{
        'select': (value) => receivedValues.add(value),
      };

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              GuxRadio.fromJson(<String, dynamic>{
                'value': 'option1',
                'groupValue': null,
                'onChanged': 'select',
              }, actions: actions),
              GuxRadio.fromJson(<String, dynamic>{
                'value': 'option2',
                'groupValue': null,
                'onChanged': 'select',
              }, actions: actions),
            ],
          ),
        ),
      );

      // Tap first radio
      await tester.tap(find.byType(GuxRadio).first);
      await tester.pump();
      expect(receivedValues, equals(['option1']));

      // Tap second radio
      await tester.tap(find.byType(GuxRadio).last);
      await tester.pump();
      expect(receivedValues, equals(['option1', 'option2']));
    });
  });
}
