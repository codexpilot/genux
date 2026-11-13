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
  group('GuxModal', () {
    testWidgets('displays with child content', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxModal(
            child: Text('Modal Content'),
          ),
        ),
      );

      expect(find.text('Modal Content'), findsOneWidget);
      expect(find.byType(GuxModal), findsOneWidget);
    });

    testWidgets('applies custom background color', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxModal(
            backgroundColor: Color(0xFF1A1A1A),
            child: Text('Content'),
          ),
        ),
      );

      final modal = tester.widget<GuxModal>(find.byType(GuxModal));
      expect(modal.backgroundColor, equals(const Color(0xFF1A1A1A)));
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxModal(
            padding: EdgeInsets.all(32.0),
            child: Text('Content'),
          ),
        ),
      );

      final modal = tester.widget<GuxModal>(find.byType(GuxModal));
      expect(modal.padding, equals(const EdgeInsets.all(32.0)));
    });

    testWidgets('applies custom width constraints', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxModal(
            minWidth: 300,
            maxWidth: 600,
            child: Text('Content'),
          ),
        ),
      );

      final modal = tester.widget<GuxModal>(find.byType(GuxModal));
      expect(modal.minWidth, equals(300));
      expect(modal.maxWidth, equals(600));
    });

    testWidgets('applies custom height constraints', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxModal(
            minHeight: 200,
            maxHeight: 500,
            child: Text('Content'),
          ),
        ),
      );

      final modal = tester.widget<GuxModal>(find.byType(GuxModal));
      expect(modal.minHeight, equals(200));
      expect(modal.maxHeight, equals(500));
    });

    testWidgets('applies custom border radius', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxModal(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Text('Content'),
          ),
        ),
      );

      final modal = tester.widget<GuxModal>(find.byType(GuxModal));
      expect(
        modal.borderRadius,
        equals(const BorderRadius.all(Radius.circular(16))),
      );
    });
  });
}
