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
  group('GuxSeparator', () {
    testWidgets('displays horizontal separator', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSeparator(
            style: GuxSeparatorStyle(),
          ),
        ),
      );

      expect(find.byType(GuxSeparator), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('displays vertical separator', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSeparator(
            style: GuxSeparatorStyle(orientation: Axis.vertical),
          ),
        ),
      );

      expect(find.byType(GuxSeparator), findsOneWidget);
    });

    testWidgets('applies color and thickness', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSeparator(
            style: GuxSeparatorStyle(
              color: Color(0xFFFF0000),
              thickness: 2.0,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, equals(const Color(0xFFFF0000)));
      expect(container.constraints?.minHeight, equals(2.0));
    });

    testWidgets('applies spacing', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxSeparator(
            style: GuxSeparatorStyle(spacing: 16.0),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(
        padding.padding,
        equals(const EdgeInsets.symmetric(vertical: 16.0)),
      );
    });

    testWidgets('roundtrips through JSON', (tester) async {
      const separator = GuxSeparator(
        style: GuxSeparatorStyle(
          color: Color(0xFFE5E7EB),
          thickness: 1.0,
          spacing: 8.0,
          orientation: Axis.horizontal,
        ),
      );

      final json = separator.toJson();
      final restored = GuxSeparator.fromJson(json);

      expect(restored.style.color, separator.style.color);
      expect(restored.style.thickness, separator.style.thickness);
      expect(restored.style.spacing, separator.style.spacing);
      expect(restored.style.orientation, separator.style.orientation);
    });

    testWidgets('parses orientation from JSON', (tester) async {
      final json = <String, dynamic>{
        'style': <String, dynamic>{
          'orientation': 'vertical',
        },
      };

      final separator = GuxSeparator.fromJson(json);
      expect(separator.style.orientation, equals(Axis.vertical));
    });
  });
}
