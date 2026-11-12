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
  group('GuxTabs', () {
    final testTabs = [
      const GuxTab(id: 'tab1', label: 'Tab 1'),
      const GuxTab(id: 'tab2', label: 'Tab 2'),
      const GuxTab(id: 'tab3', label: 'Tab 3'),
    ];

    final testChildren = {
      'tab1': const Text('Content 1'),
      'tab2': const Text('Content 2'),
      'tab3': const Text('Content 3'),
    };

    testWidgets('displays all tab labels', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxTabs(
            tabs: testTabs,
            style: const GuxTabsStyle(),
            children: testChildren,
          ),
        ),
      );

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Tab 3'), findsOneWidget);
    });

    testWidgets('shows first tab content by default', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxTabs(
            tabs: testTabs,
            style: const GuxTabsStyle(),
            children: testChildren,
          ),
        ),
      );

      expect(find.text('Content 1'), findsOneWidget);
      expect(find.text('Content 2'), findsNothing);
      expect(find.text('Content 3'), findsNothing);
    });

    testWidgets('switches content on tab tap', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxTabs(
            tabs: testTabs,
            style: const GuxTabsStyle(),
            children: testChildren,
          ),
        ),
      );

      // Initially showing tab 1
      expect(find.text('Content 1'), findsOneWidget);

      // Tap tab 2
      await tester.tap(find.text('Tab 2'));
      await tester.pumpAndSettle();

      expect(find.text('Content 1'), findsNothing);
      expect(find.text('Content 2'), findsOneWidget);

      // Tap tab 3
      await tester.tap(find.text('Tab 3'));
      await tester.pumpAndSettle();

      expect(find.text('Content 2'), findsNothing);
      expect(find.text('Content 3'), findsOneWidget);
    });

    testWidgets('respects initialTabId', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxTabs(
            tabs: testTabs,
            initialTabId: 'tab2',
            style: const GuxTabsStyle(),
            children: testChildren,
          ),
        ),
      );

      // Should start with tab 2
      expect(find.text('Content 2'), findsOneWidget);
      expect(find.text('Content 1'), findsNothing);
    });

    testWidgets('calls onTabChanged callback', (tester) async {
      String? changedTabId;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxTabs(
            tabs: testTabs,
            style: const GuxTabsStyle(),
            children: testChildren,
            onTabChanged: (tabId) => changedTabId = tabId,
          ),
        ),
      );

      // Tap tab 2
      await tester.tap(find.text('Tab 2'));
      await tester.pump();

      expect(changedTabId, equals('tab2'));

      // Tap tab 3
      await tester.tap(find.text('Tab 3'));
      await tester.pump();

      expect(changedTabId, equals('tab3'));
    });

    testWidgets('does not call onTabChanged when tapping active tab', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxTabs(
            tabs: testTabs,
            style: const GuxTabsStyle(),
            children: testChildren,
            onTabChanged: (tabId) => callCount++,
          ),
        ),
      );

      // Tap same tab twice
      await tester.tap(find.text('Tab 1'));
      await tester.pump();

      expect(callCount, equals(0)); // No callback for same tab
    });

    testWidgets('applies tab styling', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxTabs(
            tabs: testTabs,
            style: const GuxTabsStyle(
              activeTabColor: Color(0xFF3B82F6),
              inactiveTabColor: Color(0xFFE5E7EB),
            ),
            children: testChildren,
          ),
        ),
      );

      expect(find.byType(GuxTabs), findsOneWidget);
    });
  });
}
