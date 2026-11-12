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
  group('GuxAlert', () {
    testWidgets('displays message', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAlert(
            message: 'Your changes have been saved.',
            style: GuxAlertStyle(),
          ),
        ),
      );

      expect(find.text('Your changes have been saved.'), findsOneWidget);
      expect(find.byType(GuxAlert), findsOneWidget);
    });

    testWidgets('displays optional title', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAlert(
            message: 'Operation completed.',
            title: 'Success',
            style: GuxAlertStyle(),
          ),
        ),
      );

      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Operation completed.'), findsOneWidget);
    });

    testWidgets('displays optional icon', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAlert(
            message: 'Warning message',
            icon: Icon(IconData(0xe800)),
            style: GuxAlertStyle(),
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
      expect(find.text('Warning message'), findsOneWidget);
    });

    testWidgets('applies colors', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAlert(
            message: 'Test',
            style: GuxAlertStyle(
              backgroundColor: Color(0xFFDCFCE7),
              textColor: Color(0xFF166534),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFFDCFCE7)));
    });

    testWidgets('applies border', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAlert(
            message: 'Test',
            style: GuxAlertStyle(
              borderColor: Color(0xFF86EFAC),
              borderWidth: 1.0,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('roundtrips through JSON', (tester) async {
      const alert = GuxAlert(
        message: 'Your changes have been saved.',
        title: 'Success',
        style: GuxAlertStyle(
          backgroundColor: Color(0xFFDCFCE7),
          textColor: Color(0xFF166534),
        ),
      );

      final json = alert.toJson();
      final restored = GuxAlert.fromJson(json);

      expect(restored.message, alert.message);
      expect(restored.title, alert.title);
      expect(restored.style.backgroundColor, alert.style.backgroundColor);
      expect(restored.style.textColor, alert.style.textColor);
    });
  });
}
