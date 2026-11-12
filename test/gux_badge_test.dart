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
  group('GuxBadge', () {
    testWidgets('displays badge with label', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxBadge(
            label: 'New',
            style: GuxBadgeStyle(),
          ),
        ),
      );

      expect(find.text('New'), findsOneWidget);
      expect(find.byType(GuxBadge), findsOneWidget);
    });

    testWidgets('applies background and text colors', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxBadge(
            label: 'Test',
            style: GuxBadgeStyle(
              backgroundColor: Color(0xFFFF0000),
              textColor: Color(0xFFFFFFFF),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxBadge),
          matching: find.byType(Container),
        ),
      );

      expect(
        container.decoration,
        isA<BoxDecoration>().having(
          (d) => d.color,
          'color',
          equals(const Color(0xFFFF0000)),
        ),
      );
    });

    testWidgets('applies border when specified', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxBadge(
            label: 'Test',
            style: GuxBadgeStyle(
              borderColor: Color(0xFF000000),
              borderWidth: 1.0,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxBadge),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('applies padding', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxBadge(
            label: 'Test',
            style: GuxBadgeStyle(
              padding: EdgeInsets.all(16.0),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxBadge),
          matching: find.byType(Container),
        ),
      );

      expect(container.padding, equals(const EdgeInsets.all(16.0)));
    });

    testWidgets('roundtrips through JSON', (tester) async {
      const badge = GuxBadge(
        label: 'Badge',
        style: GuxBadgeStyle(
          backgroundColor: Color(0xFFE5E7EB),
          textColor: Color(0xFF1F2937),
          borderRadius: 4.0,
        ),
      );

      final json = badge.toJson();
      final restored = GuxBadge.fromJson(json);

      expect(restored.label, badge.label);
      expect(restored.style.backgroundColor, badge.style.backgroundColor);
      expect(restored.style.textColor, badge.style.textColor);
      expect(restored.style.borderRadius, badge.style.borderRadius);
    });
  });
}
