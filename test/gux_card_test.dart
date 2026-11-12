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
  group('GuxCard', () {
    testWidgets('displays card with child content', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCard(
            style: GuxCardStyle(),
            child: Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(GuxCard), findsOneWidget);
    });

    testWidgets('applies background color', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCard(
            style: GuxCardStyle(
              backgroundColor: Color(0xFFF0F0F0),
            ),
            child: Text('Content'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxCard),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFFF0F0F0)));
    });

    testWidgets('applies border', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCard(
            style: GuxCardStyle(
              borderColor: Color(0xFF000000),
              borderWidth: 1.0,
            ),
            child: Text('Content'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxCard),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('applies border radius', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCard(
            style: GuxCardStyle(borderRadius: 12.0),
            child: Text('Content'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxCard),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.borderRadius,
        equals(BorderRadius.circular(12.0)),
      );
    });

    testWidgets('applies padding', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCard(
            style: GuxCardStyle(padding: EdgeInsets.all(24.0)),
            child: Text('Content'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxCard),
          matching: find.byType(Container),
        ),
      );

      expect(container.padding, equals(const EdgeInsets.all(24.0)));
    });

    testWidgets('applies shadow with elevation', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCard(
            style: GuxCardStyle(elevation: 4.0),
            child: Text('Content'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxCard),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, isTrue);
    });

    testWidgets('roundtrips through JSON', (tester) async {
      const card = GuxCard(
        style: GuxCardStyle(
          backgroundColor: Color(0xFFFFFFFF),
          borderWidth: 1.0,
          borderRadius: 8.0,
          padding: EdgeInsets.all(16.0),
        ),
        child: Text('Test'),
      );

      final json = card.toJson();
      final restored = GuxCard.fromJson(json);

      expect(restored.style.backgroundColor, card.style.backgroundColor);
      expect(restored.style.borderWidth, card.style.borderWidth);
      expect(restored.style.borderRadius, card.style.borderRadius);
      expect(restored.style.padding, card.style.padding);
    });
  });
}
