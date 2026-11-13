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
  group('GuxDateTimePicker', () {
    testWidgets('displays placeholder when no value', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDateTimePicker(
            value: null,
            onChanged: (_) {},
            placeholder: 'Select date',
          ),
        ),
      );

      expect(find.text('Select date'), findsOneWidget);
    });

    testWidgets('formats date value', (tester) async {
      final date = DateTime(2025, 1, 15);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDateTimePicker(
            value: date,
            onChanged: (_) {},
            mode: DateTimePickerMode.date,
          ),
        ),
      );

      expect(find.text('2025-01-15'), findsOneWidget);
    });

    testWidgets('formats time value in 12-hour format', (tester) async {
      final time = DateTime(2025, 1, 15, 14, 30);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDateTimePicker(
            value: time,
            onChanged: (_) {},
            mode: DateTimePickerMode.time,
            use24HourFormat: false,
          ),
        ),
      );

      expect(find.text('02:30 PM'), findsOneWidget);
    });

    testWidgets('formats time value in 24-hour format', (tester) async {
      final time = DateTime(2025, 1, 15, 14, 30);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDateTimePicker(
            value: time,
            onChanged: (_) {},
            mode: DateTimePickerMode.time,
            use24HourFormat: true,
          ),
        ),
      );

      expect(find.text('14:30'), findsOneWidget);
    });

    testWidgets('formats datetime value', (tester) async {
      final dateTime = DateTime(2025, 1, 15, 14, 30);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDateTimePicker(
            value: dateTime,
            onChanged: (_) {},
            mode: DateTimePickerMode.dateTime,
            use24HourFormat: false,
          ),
        ),
      );

      expect(find.text('2025-01-15 02:30 PM'), findsOneWidget);
    });

    testWidgets('is disabled when onChanged is null', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDateTimePicker(
            value: null,
            onChanged: null,
          ),
        ),
      );

      final picker = tester.widget<GuxDateTimePicker>(
        find.byType(GuxDateTimePicker),
      );
      expect(picker.onChanged, isNull);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDateTimePicker(
            value: null,
            onChanged: (_) {},
            enabled: false,
          ),
        ),
      );

      final picker = tester.widget<GuxDateTimePicker>(
        find.byType(GuxDateTimePicker),
      );
      expect(picker.enabled, isFalse);
    });

    testWidgets('applies custom style', (tester) async {
      const customStyle = GuxDateTimePickerStyle(
        backgroundColor: Color(0xFF1A1A1A),
        textColor: Color(0xFFFFFFFF),
        borderRadius: 8.0,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDateTimePicker(
            value: null,
            onChanged: (_) {},
            style: customStyle,
          ),
        ),
      );

      final picker = tester.widget<GuxDateTimePicker>(
        find.byType(GuxDateTimePicker),
      );
      expect(picker.style.backgroundColor, equals(const Color(0xFF1A1A1A)));
      expect(picker.style.borderRadius, equals(8.0));
    });
  });
}
