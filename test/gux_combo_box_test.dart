import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

const style = GuxComboBoxStyle();

void main() {
  group('GuxComboBox', () {
    testWidgets('creates widget with label', (tester) async {
      final options = [
        const GuxComboBoxOption(value: 'us', label: 'United States'),
        const GuxComboBoxOption(value: 'ca', label: 'Canada'),
      ];

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          builder: (context, _) => Center(
            child: GuxComboBox<String>(
              options: options,
              value: 'us',
              onChanged: (_) {},
              labelText: 'Country',
              style: style,
            ),
          ),
        ),
      );

      expect(find.text('Country'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);
    });

    testWidgets('creates widget in editable mode', (tester) async {
      final options = [
        const GuxComboBoxOption(value: 'us', label: 'United States'),
        const GuxComboBoxOption(value: 'ca', label: 'Canada'),
      ];

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          builder: (context, _) => Center(
            child: GuxComboBox<String>(
              options: options,
              value: null,
              onChanged: (_) {},
              editable: true,
              placeholder: 'Type to search',
              style: style,
            ),
          ),
        ),
      );

      expect(find.text('Type to search'), findsOneWidget);
    });

    testWidgets('creates widget in non-editable mode', (tester) async {
      final options = [
        const GuxComboBoxOption(value: 'us', label: 'United States'),
        const GuxComboBoxOption(value: 'ca', label: 'Canada'),
      ];

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          builder: (context, _) => Center(
            child: GuxComboBox<String>(
              options: options,
              value: null,
              onChanged: (_) {},
              editable: false,
              placeholder: 'Select country',
              style: style,
            ),
          ),
        ),
      );

      expect(find.text('Select country'), findsOneWidget);
    });

    test('GuxComboBoxOption creates correctly', () {
      const option = GuxComboBoxOption(
        value: 'test',
        label: 'Test Label',
        enabled: true,
      );

      expect(option.value, 'test');
      expect(option.label, 'Test Label');
      expect(option.enabled, true);
    });

    test('GuxComboBoxOption defaults enabled to true', () {
      const option = GuxComboBoxOption(value: 'test', label: 'Test Label');

      expect(option.enabled, true);
    });

    test('GuxComboBoxStyle has correct defaults', () {
      const style = GuxComboBoxStyle();

      expect(style.menuBackgroundColor, const Color(0xFF292929));
      expect(style.itemHighlightColor, const Color(0xFF444444));
      expect(style.overlayDimColor, const Color(0x40000000));
    });

    test('GuxComboBoxStyle can override defaults', () {
      const style = GuxComboBoxStyle(
        menuBackgroundColor: Color(0xFF000000),
        itemHighlightColor: Color(0xFF555555),
        menuElevation: 8.0,
      );

      expect(style.menuBackgroundColor, const Color(0xFF000000));
      expect(style.itemHighlightColor, const Color(0xFF555555));
      expect(style.menuElevation, 8.0);
    });

    testWidgets('uses valueEquals for custom equality', (tester) async {
      // Simple user class without == override
      final user1 = _User(id: 1, name: 'Alice');
      final user2 = _User(id: 1, name: 'Alice');
      final user3 = _User(id: 2, name: 'Bob');

      final options = [
        GuxComboBoxOption(value: user1, label: user1.name),
        GuxComboBoxOption(value: user3, label: user3.name),
      ];

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          builder: (context, _) => Center(
            child: GuxComboBox<_User>(
              options: options,
              value: user2, // Different instance, same id
              valueEquals: (a, b) => a.id == b.id,
              onChanged: (_) {},
              style: style,
            ),
          ),
        ),
      );

      // Should show Alice (matched by ID)
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('shows loading spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          builder: (context, _) => Center(
            child: GuxComboBox<String>(
              options: const [],
              value: null,
              onChanged: (_) {},
              isLoading: true,
              labelText: 'Country',
              style: style,
            ),
          ),
        ),
      );

      // Find the GuxProgressIndicator
      expect(find.byType(GuxProgressIndicator), findsOneWidget);
    });

    testWidgets('shows retry button when error and onRetry provided', (tester) async {
      bool retryCallbackCalled = false;

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          builder: (context, _) => Center(
            child: GuxComboBox<String>(
              options: const [],
              value: null,
              onChanged: (_) {},
              errorMessage: 'Failed to load',
              onRetry: () => retryCallbackCalled = true,
              style: style,
            ),
          ),
        ),
      );

      expect(find.text('Failed to load'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      expect(retryCallbackCalled, true);
    });

    testWidgets('accepts emptyMessage parameter', (tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          builder: (context, _) => Center(
            child: GuxComboBox<String>(
              options: const [],
              value: null,
              onChanged: (_) {},
              emptyMessage: 'No items available',
              style: style,
            ),
          ),
        ),
      );

      // Widget should build without errors
      expect(find.byType(GuxComboBox<String>), findsOneWidget);
    });
  });
}

class _User {
  _User({required this.id, required this.name});
  final int id;
  final String name;
}
