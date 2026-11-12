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

// Helper to create button styles for testing
GuxButtonStyle _buttonStyle(Color bg, Color fg) => GuxButtonStyle(
      backgroundColor: bg,
      hoverColor: Color.alphaBlend(const Color(0x33FFFFFF), bg),
      pressedColor: Color.alphaBlend(const Color(0x66000000), bg),
      disabledColor: const Color(0xFF6B7280),
      foregroundColor: fg,
      disabledForegroundColor: const Color(0xFF9CA3AF),
    );

void main() {
  group('GuxDialog', () {
    testWidgets('displays with title only', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialog(
            title: Text('Dialog Title'),
          ),
        ),
      );

      expect(find.text('Dialog Title'), findsOneWidget);
      expect(find.byType(GuxDialog), findsOneWidget);
    });

    testWidgets('displays with content only', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialog(
            content: Text('Dialog content goes here'),
          ),
        ),
      );

      expect(find.text('Dialog content goes here'), findsOneWidget);
    });

    testWidgets('displays with title and content', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialog(
            title: Text('Confirm'),
            content: Text('Are you sure?'),
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
    });

    testWidgets('displays action buttons', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialog(
            title: const Text('Confirm'),
            content: const Text('Are you sure?'),
            actions: [
              GuxButton(
                onPressed: () {},
                style: _buttonStyle(
                  const Color(0xFF3B82F6),
                  const Color(0xFFFFFFFF),
                ),
                child: const Text('Cancel'),
              ),
              GuxButton(
                onPressed: () {},
                style: _buttonStyle(
                  const Color(0xFFEF4444),
                  const Color(0xFFFFFFFF),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('applies custom background color', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialog(
            title: Text('Dialog'),
            backgroundColor: Color(0xFF1A1A1A),
          ),
        ),
      );

      expect(find.byType(GuxDialog), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialog(
            title: Text('Dialog'),
            padding: EdgeInsets.all(32.0),
          ),
        ),
      );

      final dialog = tester.widget<GuxDialog>(find.byType(GuxDialog));
      expect(dialog.padding, equals(const EdgeInsets.all(32.0)));
    });

    testWidgets('applies custom width constraints', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialog(
            title: Text('Dialog'),
            minWidth: 200,
            maxWidth: 400,
          ),
        ),
      );

      final dialog = tester.widget<GuxDialog>(find.byType(GuxDialog));
      expect(dialog.minWidth, equals(200));
      expect(dialog.maxWidth, equals(400));
    });

    testWidgets('applies custom border radius', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialog(
            title: Text('Dialog'),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      );

      final dialog = tester.widget<GuxDialog>(find.byType(GuxDialog));
      expect(
        dialog.borderRadius,
        equals(const BorderRadius.all(Radius.circular(16))),
      );
    });

    testWidgets('displays without title or content', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialog(
            actions: [
              GuxButton(
                onPressed: () {},
                style: _buttonStyle(
                  const Color(0xFF3B82F6),
                  const Color(0xFFFFFFFF),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Close'), findsOneWidget);
      expect(find.byType(GuxDialog), findsOneWidget);
    });

    testWidgets('handles scrollable content', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialog(
            title: const Text('Long Content'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                50,
                (index) => Text('Line $index'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Long Content'), findsOneWidget);
      expect(find.byType(GuxDialog), findsOneWidget);
    });
  });
}
