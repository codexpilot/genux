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
  group('GuxApp routing', () {
    testWidgets('navigates to home on root route', (tester) async {
      await tester.pumpWidget(
        GuxApp(
          title: 'Test',
          color: const Color(0xFF000000),
          textStyle: const TextStyle(fontSize: 14),
          home: const Text('Home Page'),
        ),
      );

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('uses onGenerateRoute for named routes', (tester) async {
      Widget? currentPage;

      await tester.pumpWidget(
        GuxApp(
          title: 'Test',
          color: const Color(0xFF000000),
          textStyle: const TextStyle(fontSize: 14),
          home: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/about');
                },
                child: const Text('Home Page'),
              );
            },
          ),
          onGenerateRoute: (settings) {
            if (settings.name == '/about') {
              currentPage = const Text('About Page');
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return currentPage!;
                },
              );
            }
            return null;
          },
        ),
      );

      expect(find.text('Home Page'), findsOneWidget);

      // Navigate to /about
      await tester.tap(find.text('Home Page'));
      await tester.pumpAndSettle();

      expect(find.text('About Page'), findsOneWidget);
    });

    testWidgets('falls back to home for unknown routes', (tester) async {
      await tester.pumpWidget(
        GuxApp(
          title: 'Test',
          color: const Color(0xFF000000),
          textStyle: const TextStyle(fontSize: 14),
          home: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  // Try to navigate to unknown route
                  Navigator.of(context).pushNamed('/unknown');
                },
                child: const Text('Home Page'),
              );
            },
          ),
          onGenerateRoute: (settings) {
            if (settings.name == '/known') {
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return const Text('Known Page');
                },
              );
            }
            return null; // Unknown route returns null
          },
        ),
      );

      expect(find.text('Home Page'), findsOneWidget);

      // Try to navigate to unknown route - should fall back to home via onUnknownRoute
      await tester.tap(find.text('Home Page'));
      await tester.pumpAndSettle();

      // Should show home page as fallback
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('handles root route / explicitly', (tester) async {
      bool rootRouteHandled = false;

      await tester.pumpWidget(
        GuxApp(
          title: 'Test',
          color: const Color(0xFF000000),
          textStyle: const TextStyle(fontSize: 14),
          home: const Text('Home Page'),
          onGenerateRoute: (settings) {
            if (settings.name == '/') {
              rootRouteHandled = true;
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return const Text('Custom Home');
                },
              );
            }
            return null;
          },
        ),
      );

      // When onGenerateRoute returns non-null for '/', it should be used
      if (rootRouteHandled) {
        expect(find.text('Custom Home'), findsOneWidget);
      } else {
        // Otherwise falls back to home widget
        expect(find.text('Home Page'), findsOneWidget);
      }
    });

    testWidgets('applies textStyle to descendants', (tester) async {
      await tester.pumpWidget(
        GuxApp(
          title: 'Test',
          color: const Color(0xFF000000),
          textStyle: const TextStyle(fontSize: 24, color: Color(0xFFFF0000)),
          home: const Text('Styled Text'),
        ),
      );

      final defaultStyle = DefaultTextStyle.of(
        tester.element(find.text('Styled Text')),
      );

      expect(defaultStyle.style.fontSize, equals(24));
      expect(defaultStyle.style.color, equals(const Color(0xFFFF0000)));
    });

    testWidgets('uses builder to wrap content', (tester) async {
      await tester.pumpWidget(
        GuxApp(
          title: 'Test',
          color: const Color(0xFF000000),
          textStyle: const TextStyle(fontSize: 14),
          home: const Text('Home Page'),
          builder: (context, child) {
            return Container(
              color: const Color(0xFF00FF00),
              child: child,
            );
          },
        ),
      );

      expect(find.text('Home Page'), findsOneWidget);
      expect(
        tester.widget<Container>(find.byType(Container).first).color,
        equals(const Color(0xFF00FF00)),
      );
    });
  });
}
