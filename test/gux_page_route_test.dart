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
  group('GuxPageRoute', () {
    testWidgets('creates route with required builder', (tester) async {
      final route = GuxPageRoute<void>(
        builder: (context) => const Text('Test Page'),
      );

      expect(route.builder, isNotNull);
    });

    testWidgets('uses default fade transition type', (tester) async {
      final route = GuxPageRoute<void>(
        builder: (context) => const Text('Test Page'),
      );

      expect(route.transitionType, GuxTransitionType.fade);
    });

    testWidgets('accepts custom transition type', (tester) async {
      final route = GuxPageRoute<void>(
        builder: (context) => const Text('Test Page'),
        transitionType: GuxTransitionType.slide,
      );

      expect(route.transitionType, GuxTransitionType.slide);
    });

    testWidgets('accepts route settings', (tester) async {
      const settings = RouteSettings(name: '/test', arguments: {'key': 'value'});
      final route = GuxPageRoute<void>(
        builder: (context) => const Text('Test Page'),
        settings: settings,
      );

      expect(route.settings.name, '/test');
      expect(route.settings.arguments, {'key': 'value'});
    });

    test('has correct default route properties', () {
      final route = GuxPageRoute<void>(
        builder: (context) => const Text('Test Page'),
      );

      expect(route.maintainState, true);
      expect(route.fullscreenDialog, false);
      expect(route.transitionDuration, const Duration(milliseconds: 300));
      expect(route.reverseTransitionDuration, const Duration(milliseconds: 300));
      expect(route.opaque, true);
      expect(route.barrierDismissible, false);
      expect(route.barrierColor, null);
      expect(route.barrierLabel, null);
    });

    testWidgets('buildPage returns built widget', (tester) async {
      final testWidget = Container(key: const Key('test-container'));
      final route = GuxPageRoute<void>(
        builder: (context) => testWidget,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Navigator(
            onGenerateRoute: (_) => route,
          ),
        ),
      );

      expect(find.byKey(const Key('test-container')), findsOneWidget);
    });

    testWidgets('fade transition animates opacity', (tester) async {
      final route = GuxPageRoute<void>(
        builder: (context) => const Text('Fade Page'),
        transitionType: GuxTransitionType.fade,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Navigator(
            onGenerateRoute: (_) => route,
          ),
        ),
      );

      // Initially animating
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.text('Fade Page'), findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();
      expect(find.text('Fade Page'), findsOneWidget);
    });

    testWidgets('slide transition animates position', (tester) async {
      final route = GuxPageRoute<void>(
        builder: (context) => const Text('Slide Page'),
        transitionType: GuxTransitionType.slide,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Navigator(
            onGenerateRoute: (_) => route,
          ),
        ),
      );

      // Initially animating
      expect(find.byType(SlideTransition), findsOneWidget);
      expect(find.text('Slide Page'), findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();
      expect(find.text('Slide Page'), findsOneWidget);
    });

    testWidgets('none transition shows widget immediately', (tester) async {
      final route = GuxPageRoute<void>(
        builder: (context) => const Text('No Transition Page'),
        transitionType: GuxTransitionType.none,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Navigator(
            onGenerateRoute: (_) => route,
          ),
        ),
      );

      // No transition wrapper
      expect(find.byType(FadeTransition), findsNothing);
      expect(find.byType(SlideTransition), findsNothing);
      expect(find.text('No Transition Page'), findsOneWidget);
    });

    testWidgets('navigation with GuxPageRoute works correctly', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Navigator(
            key: navigatorKey,
            onGenerateRoute: (settings) {
              if (settings.name == '/') {
                return GuxPageRoute<void>(
                  builder: (context) => const Text('Home'),
                  settings: settings,
                );
              }
              return null;
            },
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);

      // Push a new route
      navigatorKey.currentState!.push(
        GuxPageRoute<void>(
          builder: (context) => const Text('Second Page'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Second Page'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('can pop route and return to previous page', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Navigator(
            key: navigatorKey,
            onGenerateRoute: (settings) {
              return GuxPageRoute<void>(
                builder: (context) => const Text('Home'),
                settings: settings,
              );
            },
          ),
        ),
      );

      // Push second route
      navigatorKey.currentState!.push(
        GuxPageRoute<void>(
          builder: (context) => const Text('Second Page'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);

      // Pop back
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Second Page'), findsNothing);
    });

    testWidgets('supports generic type parameter', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Navigator(
            key: navigatorKey,
            onGenerateRoute: (settings) {
              return GuxPageRoute<void>(
                builder: (context) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      GuxPageRoute<String>(
                        builder: (context) => GestureDetector(
                          onTap: () => Navigator.of(context).pop('result'),
                          child: const Text('Dialog'),
                        ),
                      ),
                    );
                  },
                  child: const Text('Home'),
                ),
                settings: settings,
              );
            },
          ),
        ),
      );

      // Tap to open route
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog'), findsOneWidget);

      // Tap to pop with result
      await tester.tap(find.text('Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('GuxTransitionType', () {
    test('has expected values', () {
      expect(GuxTransitionType.values.length, 3);
      expect(GuxTransitionType.values, contains(GuxTransitionType.fade));
      expect(GuxTransitionType.values, contains(GuxTransitionType.slide));
      expect(GuxTransitionType.values, contains(GuxTransitionType.none));
    });

    test('enum values are correctly named', () {
      expect(GuxTransitionType.fade.name, 'fade');
      expect(GuxTransitionType.slide.name, 'slide');
      expect(GuxTransitionType.none.name, 'none');
    });
  });
}
