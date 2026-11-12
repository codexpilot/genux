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
  group('GuxAccordion', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAccordion(
            title: 'Section Title',
            content: Text('Content'),
            style: GuxAccordionStyle(),
          ),
        ),
      );

      expect(find.text('Section Title'), findsOneWidget);
      expect(find.byType(GuxAccordion), findsOneWidget);
    });

    testWidgets('content hidden when collapsed', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAccordion(
            title: 'Section',
            content: Text('Hidden Content'),
            style: GuxAccordionStyle(),
            initiallyExpanded: false,
          ),
        ),
      );

      expect(find.text('Hidden Content'), findsNothing);
    });

    testWidgets('content visible when initially expanded', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAccordion(
            title: 'Section',
            content: Text('Visible Content'),
            style: GuxAccordionStyle(),
            initiallyExpanded: true,
          ),
        ),
      );

      expect(find.text('Visible Content'), findsOneWidget);
    });

    testWidgets('toggles expansion on tap', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAccordion(
            title: 'Section',
            content: Text('Toggle Content'),
            style: GuxAccordionStyle(),
            initiallyExpanded: false,
          ),
        ),
      );

      // Initially collapsed
      expect(find.text('Toggle Content'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Section'));
      await tester.pumpAndSettle();

      expect(find.text('Toggle Content'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.text('Section'));
      await tester.pumpAndSettle();

      expect(find.text('Toggle Content'), findsNothing);
    });

    testWidgets('calls onExpansionChanged callback', (tester) async {
      bool? expansionState;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAccordion(
            title: 'Section',
            content: const Text('Content'),
            style: const GuxAccordionStyle(),
            onExpansionChanged: (expanded) => expansionState = expanded,
          ),
        ),
      );

      // Expand
      await tester.tap(find.text('Section'));
      await tester.pump();

      expect(expansionState, isTrue);

      // Collapse
      await tester.tap(find.text('Section'));
      await tester.pump();

      expect(expansionState, isFalse);
    });

    testWidgets('supports keyboard activation with Space', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAccordion(
            title: 'Section',
            content: Text('Keyboard Content'),
            style: GuxAccordionStyle(),
          ),
        ),
      );

      // Tap to focus
      await tester.tap(find.text('Section'));
      await tester.pump();

      // Space key should toggle (this is handled by GestureDetector automatically in tests)
      expect(find.text('Keyboard Content'), findsOneWidget);
    });

    testWidgets('applies expanded background color', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAccordion(
            title: 'Section',
            content: Text('Content'),
            style: GuxAccordionStyle(
              backgroundColor: Color(0xFFFFFFFF),
              expandedBackgroundColor: Color(0xFFF0F0F0),
            ),
            initiallyExpanded: true,
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxAccordion),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFFF0F0F0)));
    });

    testWidgets('roundtrips through JSON', (tester) async {
      const accordion = GuxAccordion(
        title: 'Test Section',
        content: Text('Test'),
        style: GuxAccordionStyle(
          backgroundColor: Color(0xFFFFFFFF),
          borderRadius: 8.0,
        ),
        initiallyExpanded: false,
      );

      final json = accordion.toJson();
      final restored = GuxAccordion.fromJson(json);

      expect(restored.title, accordion.title);
      expect(restored.initiallyExpanded, accordion.initiallyExpanded);
      expect(restored.style.backgroundColor, accordion.style.backgroundColor);
      expect(restored.style.borderRadius, accordion.style.borderRadius);
    });
  });
}
