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
  group('GuxProgressIndicator', () {
    testWidgets('displays with determinate progress', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxProgressIndicator(
            color: Color(0xFF3B82F6),
            trackColor: Color(0xFF484848),
            value: 0.5,
          ),
        ),
      );

      expect(find.byType(GuxProgressIndicator), findsOneWidget);
    });

    testWidgets('displays with indeterminate progress', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxProgressIndicator(
            color: Color(0xFF3B82F6),
            trackColor: Color(0xFF484848),
            value: null, // Indeterminate
          ),
        ),
      );

      expect(find.byType(GuxProgressIndicator), findsOneWidget);
    });

    testWidgets('animates indeterminate progress', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxProgressIndicator(
            color: Color(0xFF3B82F6),
            trackColor: Color(0xFF484848),
            value: null,
          ),
        ),
      );

      // Animation should be running for indeterminate
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(GuxProgressIndicator), findsOneWidget);
    });

    testWidgets('displays with custom size', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxProgressIndicator(
            color: Color(0xFF3B82F6),
            trackColor: Color(0xFF484848),
            size: 32.0,
            strokeWidth: 4.0,
          ),
        ),
      );

      final indicator = tester.widget<GuxProgressIndicator>(
        find.byType(GuxProgressIndicator),
      );
      expect(indicator.size, equals(32.0));
      expect(indicator.strokeWidth, equals(4.0));
    });

    testWidgets('displays progress at 0%', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxProgressIndicator(
            color: Color(0xFF3B82F6),
            trackColor: Color(0xFF484848),
            value: 0.0,
          ),
        ),
      );

      expect(find.byType(GuxProgressIndicator), findsOneWidget);
    });

    testWidgets('displays progress at 100%', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxProgressIndicator(
            color: Color(0xFF3B82F6),
            trackColor: Color(0xFF484848),
            value: 1.0,
          ),
        ),
      );

      expect(find.byType(GuxProgressIndicator), findsOneWidget);
    });

    testWidgets('updates progress value', (tester) async {
      double progress = 0.25;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return GuxProgressIndicator(
                color: const Color(0xFF3B82F6),
                trackColor: const Color(0xFF484848),
                value: progress,
              );
            },
          ),
        ),
      );

      var indicator = tester.widget<GuxProgressIndicator>(
        find.byType(GuxProgressIndicator),
      );
      expect(indicator.value, equals(0.25));

      // Update progress
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxProgressIndicator(
            color: Color(0xFF3B82F6),
            trackColor: Color(0xFF484848),
            value: 0.75,
          ),
        ),
      );

      indicator = tester.widget<GuxProgressIndicator>(
        find.byType(GuxProgressIndicator),
      );
      expect(indicator.value, equals(0.75));
    });

    testWidgets('includes semantics label', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxProgressIndicator(
            color: Color(0xFF3B82F6),
            trackColor: Color(0xFF484848),
            value: 0.5,
            semanticsLabel: 'Loading progress',
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Loading progress'),
        findsOneWidget,
      );
    });

    testWidgets('includes semantics value', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxProgressIndicator(
            color: Color(0xFF3B82F6),
            trackColor: Color(0xFF484848),
            value: 0.5,
            semanticsLabel: 'Loading',
            semanticsValue: '50%',
          ),
        ),
      );

      expect(find.byType(GuxProgressIndicator), findsOneWidget);
    });

    testWidgets('roundtrips through JSON', (tester) async {
      const indicator = GuxProgressIndicator(
        color: Color(0xFF3B82F6),
        trackColor: Color(0xFF484848),
        size: 24.0,
        strokeWidth: 3.0,
        value: 0.75,
        semanticsLabel: 'Progress',
        semanticsValue: '75%',
      );

      final json = indicator.toJson();
      final restored = GuxProgressIndicator.fromJson(json);

      expect(restored.color, equals(indicator.color));
      expect(restored.trackColor, equals(indicator.trackColor));
      expect(restored.size, equals(indicator.size));
      expect(restored.strokeWidth, equals(indicator.strokeWidth));
      expect(restored.value, equals(indicator.value));
      expect(restored.semanticsLabel, equals(indicator.semanticsLabel));
      expect(restored.semanticsValue, equals(indicator.semanticsValue));
    });

    testWidgets('JSON handles null value (indeterminate)', (tester) async {
      const indicator = GuxProgressIndicator(
        color: Color(0xFF3B82F6),
        trackColor: Color(0xFF484848),
        value: null,
      );

      final json = indicator.toJson();
      final restored = GuxProgressIndicator.fromJson(json);

      expect(restored.value, isNull);
    });
  });
}
