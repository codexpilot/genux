import 'package:flutter/material.dart';
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
        MaterialApp(
          home: Scaffold(
            body: GuxComboBox<String>(
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
        MaterialApp(
          home: Scaffold(
            body: GuxComboBox<String>(
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
        MaterialApp(
          home: Scaffold(
            body: GuxComboBox<String>(
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
      const option = GuxComboBoxOption(
        value: 'test',
        label: 'Test Label',
      );

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
  });
}
