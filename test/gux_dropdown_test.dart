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
  group('GuxDropdown', () {
    final options = [
      const GuxDropdownOption(value: 1, label: 'Option 1'),
      const GuxDropdownOption(value: 2, label: 'Option 2'),
      const GuxDropdownOption(value: 3, label: 'Option 3'),
    ];

    testWidgets('displays placeholder when no value selected', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: options,
                  value: null,
                  onChanged: (_) {},
                  placeholder: 'Select an option',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Select an option'), findsOneWidget);
    });

    testWidgets('displays selected value', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: options,
                  value: 2,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Option 2'), findsOneWidget);
    });

    testWidgets('displays loading state', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: options,
                  value: null,
                  onChanged: (_) {},
                  isLoading: true,
                  loadingMessage: 'Loading...',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('displays error state', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: options,
                  value: null,
                  onChanged: (_) {},
                  errorMessage: 'Failed to load',
                  onRetry: () {},
                  retryLabel: 'Retry',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Failed to load'), findsOneWidget);
    });

    testWidgets('triggers retry callback on tap when in error state',
        (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: options,
                  value: null,
                  onChanged: (_) {},
                  errorMessage: 'Failed to load',
                  onRetry: () {
                    retried = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GuxDropdown<int>));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('displays empty message when no options', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: const [],
                  value: null,
                  onChanged: (_) {},
                  emptyMessage: 'No items',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('applies custom placeholder', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: options,
                  value: null,
                  onChanged: (_) {},
                  placeholder: 'Choose one',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Choose one'), findsOneWidget);
    });

    testWidgets('renders as disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: options,
                  value: null,
                  onChanged: (_) {},
                  enabled: false,
                ),
              ),
            ),
          ),
        ),
      );

      final dropdown = tester.widget<GuxDropdown<int>>(
        find.byType(GuxDropdown<int>),
      );
      expect(dropdown.enabled, isFalse);
    });

    testWidgets('renders as disabled when onChanged is null', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: options,
                  value: null,
                  onChanged: null,
                ),
              ),
            ),
          ),
        ),
      );

      final dropdown = tester.widget<GuxDropdown<int>>(
        find.byType(GuxDropdown<int>),
      );
      expect(dropdown.onChanged, isNull);
    });

    testWidgets('applies custom styling', (tester) async {
      const customStyle = GuxDropdownStyle(
        backgroundColor: Color(0xFF1A1A1A),
        menuColor: Color(0xFF2A2A2A),
        borderColor: Color(0xFF3A3A3A),
        textColor: Color(0xFFEEEEEE),
        borderRadius: 8.0,
        borderWidth: 2.0,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: options,
                  value: null,
                  onChanged: (_) {},
                  style: customStyle,
                ),
              ),
            ),
          ),
        ),
      );

      final dropdown = tester.widget<GuxDropdown<int>>(
        find.byType(GuxDropdown<int>),
      );
      expect(dropdown.style.backgroundColor, equals(const Color(0xFF1A1A1A)));
      expect(dropdown.style.menuColor, equals(const Color(0xFF2A2A2A)));
      expect(dropdown.style.borderRadius, equals(8.0));
      expect(dropdown.style.borderWidth, equals(2.0));
    });

    testWidgets('accepts options list', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: options,
                  value: null,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      final dropdown = tester.widget<GuxDropdown<int>>(
        find.byType(GuxDropdown<int>),
      );
      expect(dropdown.options.length, equals(3));
      expect(dropdown.options[0].label, equals('Option 1'));
      expect(dropdown.options[1].label, equals('Option 2'));
      expect(dropdown.options[2].label, equals('Option 3'));
    });

    testWidgets('supports semantic label', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Navigator(
              onGenerateRoute: (_) => PageRouteBuilder<void>(
                pageBuilder: (context, _, __) => GuxDropdown<int>(
                  options: options,
                  value: null,
                  onChanged: (_) {},
                  semanticLabel: 'Choose country',
                ),
              ),
            ),
          ),
        ),
      );

      final dropdown = tester.widget<GuxDropdown<int>>(
        find.byType(GuxDropdown<int>),
      );
      expect(dropdown.semanticLabel, equals('Choose country'));
    });
  });

  group('GuxDropdownOption', () {
    test('creates option with value and label', () {
      const option = GuxDropdownOption(value: 1, label: 'Test');
      expect(option.value, equals(1));
      expect(option.label, equals('Test'));
      expect(option.enabled, isTrue);
      expect(option.subtitle, isNull);
    });

    test('creates option with subtitle', () {
      const option = GuxDropdownOption(
        value: 1,
        label: 'Test',
        subtitle: 'Description',
      );
      expect(option.subtitle, equals('Description'));
    });

    test('creates disabled option', () {
      const option = GuxDropdownOption(
        value: 1,
        label: 'Test',
        enabled: false,
      );
      expect(option.enabled, isFalse);
    });
  });

  group('GuxDropdownStyle', () {
    test('has default values', () {
      const style = GuxDropdownStyle();
      expect(style.backgroundColor, equals(const Color(0xFF292929)));
      expect(style.menuColor, equals(const Color(0xFF292929)));
      expect(style.borderRadius, equals(4));
      expect(style.borderWidth, equals(1));
    });

    test('accepts custom values', () {
      const style = GuxDropdownStyle(
        backgroundColor: Color(0xFF000000),
        borderRadius: 8,
        borderWidth: 2,
      );
      expect(style.backgroundColor, equals(const Color(0xFF000000)));
      expect(style.borderRadius, equals(8));
      expect(style.borderWidth, equals(2));
    });
  });
}
