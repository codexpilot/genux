import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/showcase/showcase_app.dart';

void main() {
  final fixture = File(
    'assets/views/customer-edit.genux.json',
  ).readAsStringSync();

  testWidgets('renders the Genux showcase two-tab layout', (tester) async {
    await tester.pumpWidget(GenuxShowcaseApp(fixtureSource: fixture));
    await tester.pumpAndSettle();

    expect(find.text('Genux Showcase'), findsOneWidget);
    expect(find.text('JSON Source'), findsOneWidget);
    expect(find.text('Runtime View'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(TabBarView), findsOneWidget);
  });

  testWidgets('showcase displays and navigates views', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(GenuxShowcaseApp(fixtureSource: fixture));
    await tester.pumpAndSettle();

    // Start on JSON tab, switch to Runtime tab
    await tester.tap(find.text('Runtime View'));
    await tester.pumpAndSettle();

    // Check runtime view is loaded
    expect(find.text('Edit customer'), findsOneWidget);
    expect(find.byKey(const ValueKey('showcase-surface-host')), findsOneWidget);
  });

  testWidgets('showcase navigates views and preserves state', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(GenuxShowcaseApp(fixtureSource: fixture));
    await tester.pumpAndSettle();

    final nameField = find.descendant(
      of: find.byKey(const ValueKey('genux:customerName')),
      matching: find.byType(TextField),
    );
    await tester.enterText(nameField, 'Preserved name');
    await tester.pump();

    final openSummary = find.text('Open customer summary');
    await tester.ensureVisible(openSummary);
    await tester.tap(openSummary);
    await tester.pumpAndSettle();

    expect(find.text('Customer summary'), findsOneWidget);

    final backToEditor = find.text('Back to editor');
    await tester.ensureVisible(backToEditor);
    await tester.tap(backToEditor);
    await tester.pumpAndSettle();

    expect(find.text('Edit customer'), findsOneWidget);
    final restored = tester.widget<TextField>(nameField);
    expect(restored.controller!.text, 'Preserved name');
  });

  testWidgets(
    'semantic actions navigate Views and restore editor state',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 1000);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(GenuxShowcaseApp(fixtureSource: fixture));
      await tester.pumpAndSettle();

      final nameField = find.descendant(
        of: find.byKey(const ValueKey('genux:customerName')),
        matching: find.byType(TextField),
      );
      await tester.enterText(nameField, 'Survives navigation');
      await tester.pump();

      final openLab = find.text('Open Component Lab');
      await tester.ensureVisible(openLab);
      await tester.tap(openLab);
      await _pumpUntilFound(tester, find.text('Component Lab'));

      expect(find.text('Component Lab'), findsOneWidget);

      final backButton = find.widgetWithIcon(IconButton, Icons.arrow_back);
      await tester.tap(backButton);
      await _pumpUntilFound(tester, find.text('Edit customer'));

      expect(find.text('Edit customer'), findsOneWidget);
      expect(
        tester.widget<TextField>(nameField).controller!.text,
        'Survives navigation',
      );
    },
  );

  testWidgets(
    'Component Lab navigation works',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 1000);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(GenuxShowcaseApp(fixtureSource: fixture));
      await tester.pumpAndSettle();

      final nameField = find.descendant(
        of: find.byKey(const ValueKey('genux:customerName')),
        matching: find.byType(TextField),
      );
      await tester.enterText(nameField, 'Test navigation');
      await tester.pump();

      final openLab = find.text('Open Component Lab');
      await tester.ensureVisible(openLab);
      await tester.tap(openLab);
      await _pumpUntilFound(tester, find.text('Component Lab'));

      expect(find.text('Component Lab'), findsOneWidget);

      final backButton = find.widgetWithIcon(IconButton, Icons.arrow_back);
      await tester.tap(backButton);
      await _pumpUntilFound(tester, find.text('Edit customer'));

      expect(find.text('Edit customer'), findsOneWidget);
      expect(
        tester.widget<TextField>(nameField).controller!.text,
        'Test navigation',
      );
    },
  );

  testWidgets('failed secondary load keeps the active surface visible', (
    tester,
  ) async {
    await tester.pumpWidget(GenuxShowcaseApp(fixtureSource: fixture));
    await tester.pumpAndSettle();

    expect(find.text('Edit customer'), findsOneWidget);
  });

  testWidgets('superseded open cannot clear a newer navigation busy state', (
    tester,
  ) async {
    await tester.pumpWidget(GenuxShowcaseApp(fixtureSource: fixture));
    await tester.pumpAndSettle();

    expect(find.text('Edit customer'), findsOneWidget);
    expect(find.byKey(const ValueKey('showcase-surface-host')), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = tester.binding.clock.now().add(timeout);
  do {
    if (tester.any(finder)) return;
    await tester.pump(const Duration(milliseconds: 100));
  } while (tester.binding.clock.now().isBefore(deadline));
  throw TimeoutException(
    'Timed out waiting for $finder',
    timeout,
  );
}
