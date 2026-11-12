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
  group('GuxToast', () {
    testWidgets('displays message', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxToast(
            message: 'Success!',
            style: GuxToastStyle(),
          ),
        ),
      );

      expect(find.text('Success!'), findsOneWidget);
      expect(find.byType(GuxToast), findsOneWidget);
    });

    testWidgets('applies background and text colors', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxToast(
            message: 'Test',
            style: GuxToastStyle(
              backgroundColor: Color(0xFF10B981),
              textColor: Color(0xFFFFFFFF),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF10B981)));

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.color, equals(const Color(0xFFFFFFFF)));
    });

    testWidgets('applies border radius', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxToast(
            message: 'Test',
            style: GuxToastStyle(borderRadius: 8.0),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(8.0)));
    });

    testWidgets('roundtrips through JSON', (tester) async {
      const toast = GuxToast(
        message: 'Item saved',
        style: GuxToastStyle(
          backgroundColor: Color(0xFF10B981),
          textColor: Color(0xFFFFFFFF),
        ),
      );

      final json = toast.toJson();
      final restored = GuxToast.fromJson(json);

      expect(restored.message, toast.message);
      expect(restored.style.backgroundColor, toast.style.backgroundColor);
      expect(restored.style.textColor, toast.style.textColor);
    });
  });
}
