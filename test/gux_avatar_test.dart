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
  group('GuxAvatar', () {
    testWidgets('displays initials', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAvatar(
            initials: 'AB',
            style: GuxAvatarStyle(),
          ),
        ),
      );

      expect(find.text('AB'), findsOneWidget);
      expect(find.byType(GuxAvatar), findsOneWidget);
    });

    testWidgets('has circular shape', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAvatar(
            initials: 'AB',
            style: GuxAvatarStyle(),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxAvatar),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('applies size', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAvatar(
            initials: 'AB',
            style: GuxAvatarStyle(size: 60.0),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxAvatar),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.minWidth, equals(60.0));
      expect(container.constraints?.minHeight, equals(60.0));
    });

    testWidgets('applies background and text colors', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAvatar(
            initials: 'AB',
            style: GuxAvatarStyle(
              backgroundColor: Color(0xFFFF0000),
              textColor: Color(0xFFFFFFFF),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxAvatar),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFFFF0000)));
    });

    testWidgets('applies border when specified', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAvatar(
            initials: 'AB',
            style: GuxAvatarStyle(
              borderColor: Color(0xFF000000),
              borderWidth: 2.0,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GuxAvatar),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('roundtrips through JSON', (tester) async {
      const avatar = GuxAvatar(
        initials: 'JD',
        style: GuxAvatarStyle(
          backgroundColor: Color(0xFFE5E7EB),
          textColor: Color(0xFF1F2937),
          size: 40.0,
        ),
      );

      final json = avatar.toJson();
      final restored = GuxAvatar.fromJson(json);

      expect(restored.initials, avatar.initials);
      expect(restored.style.backgroundColor, avatar.style.backgroundColor);
      expect(restored.style.textColor, avatar.style.textColor);
      expect(restored.style.size, avatar.style.size);
    });
  });
}
