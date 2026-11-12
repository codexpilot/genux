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
  group('GuxSheet', () {
    testWidgets('displays child content', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSheet(
            style: GuxSheetStyle(),
            child: Text('Sheet Content'),
          ),
        ),
      );

      expect(find.text('Sheet Content'), findsOneWidget);
      expect(find.byType(GuxSheet), findsOneWidget);
    });

    testWidgets('applies background color', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSheet(
            style: GuxSheetStyle(backgroundColor: Color(0xFFFFFFFF)),
            child: Text('Content'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxSheet),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFFFFFFFF)));
    });

    testWidgets('applies rounded top corners only', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSheet(
            style: GuxSheetStyle(borderRadius: 16.0),
            child: Text('Content'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxSheet),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      final borderRadius = decoration.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, equals(16.0));
      expect(borderRadius.topRight.x, equals(16.0));
      expect(borderRadius.bottomLeft.x, equals(0.0));
      expect(borderRadius.bottomRight.x, equals(0.0));
    });

    testWidgets('applies padding', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSheet(
            style: GuxSheetStyle(padding: EdgeInsets.all(24.0)),
            child: Text('Content'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxSheet),
          matching: find.byType(Container),
        ),
      );

      expect(container.padding, equals(const EdgeInsets.all(24.0)));
    });

    testWidgets('applies shadow with elevation', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSheet(
            style: GuxSheetStyle(elevation: 8.0),
            child: Text('Content'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxSheet),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, isTrue);
    });
  });
}
