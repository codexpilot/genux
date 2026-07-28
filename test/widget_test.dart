import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/showcase/showcase_app.dart';
import 'package:genux/showcase/pages/workspace_page.dart';
import 'package:genux/showcase/showcase_runtime.dart';

void main() {
  final fixture = File(
    'assets/views/customer-edit.genux.json',
  ).readAsStringSync();

  testWidgets('renders the Genux showcase shell', (tester) async {
    await tester.pumpWidget(GenuxShowcaseApp(fixtureSource: fixture));
    await tester.pumpAndSettle();

    expect(find.text('GENUX'), findsOneWidget);
    expect(find.byKey(const ValueKey('workspace-page')), findsOneWidget);
  });

  testWidgets('showcase navigates and retains the last good surface', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(GenuxShowcaseApp(fixtureSource: fixture));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Edit customer'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('safe-rejection-button')));
    await tester.pump();

    expect(find.text('Candidate snapshot rejected safely'), findsOneWidget);
    expect(find.text('Edit customer'), findsOneWidget);

    await tester.tap(find.text('Component catalog'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('catalog-page')), findsOneWidget);
    expect(find.text('ComboBox'), findsOneWidget);
  });

  testWidgets('semantic actions navigate Views and restore editor state', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
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
    expect(find.text('customer.summary · r1'), findsOneWidget);

    final backToEditor = find.text('Back to editor');
    await tester.ensureVisible(backToEditor);
    await tester.tap(backToEditor);
    await tester.pumpAndSettle();

    expect(find.text('Edit customer'), findsOneWidget);
    final restored = tester.widget<TextField>(nameField);
    expect(restored.controller!.text, 'Preserved name');
    expect(find.text('customer.edit · r6'), findsOneWidget);
    expect(find.text('customer.summary · r1'), findsNothing);
  });

  testWidgets(
    'Component Lab exposes the full catalog and restores the editor',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 1000);
      addTearDown(tester.view.reset);

      final labSource = File(
        'assets/views/component-lab.genux.json',
      ).readAsStringSync();
      final labDocument = jsonDecode(labSource) as Map<String, Object?>;
      final nodes = labDocument['nodes']! as List<Object?>;
      final components = nodes
          .cast<Map<String, Object?>>()
          .map((node) => node['component'])
          .whereType<String>()
          .toSet();
      expect(
        components,
        containsAll(<String>{
          'Button',
          'Card',
          'Checkbox',
          'Column',
          'ComboBox',
          'Divider',
          'Form',
          'Row',
          'Text',
          'TextField',
        }),
      );

      await tester.pumpWidget(GenuxShowcaseApp(fixtureSource: fixture));
      await tester.pumpAndSettle();

      final nameField = find.descendant(
        of: find.byKey(const ValueKey('genux:customerName')),
        matching: find.byType(TextField),
      );
      await tester.enterText(nameField, 'Survives the lab');
      await tester.pump();

      final openLab = find.text('Open Component Lab');
      await tester.ensureVisible(openLab);
      await tester.tap(openLab);
      await _pumpUntilFound(tester, find.text('Component Lab'));

      expect(find.text('Component Lab'), findsOneWidget);
      expect(find.textContaining('component.lab · r'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('genux:labForm:errors')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('genux:busyDemoForm:busy')),
        findsOneWidget,
      );

      final liveField = find.descendant(
        of: find.byKey(const ValueKey('genux:normalTextField')),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(liveField);
      await tester.enterText(liveField, 'Live lab edit');
      await tester.pump();
      await _pumpUntilFound(
        tester,
        find.text('demo.event dispatched locally.'),
      );
      expect(
        tester.widget<TextField>(liveField).controller!.text,
        'Live lab edit',
      );

      final liveCheckbox = find.byKey(
        const ValueKey('genux:interactiveCheckbox'),
      );
      await tester.ensureVisible(liveCheckbox);
      await tester.tap(liveCheckbox);
      await tester.pump();
      expect(tester.widget<CheckboxListTile>(liveCheckbox).value, isTrue);

      final disabledField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('genux:disabledTextField')),
          matching: find.byType(TextField),
        ),
      );
      expect(disabledField.enabled, isFalse);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('genux:busyButton')),
            )
            .onPressed,
        isNull,
      );

      final backToEditor = find.text('Back to editor');
      await tester.ensureVisible(backToEditor);
      await tester.tap(backToEditor);
      await _pumpUntilFound(tester, find.text('Edit customer'));

      expect(find.text('Edit customer'), findsOneWidget);
      expect(
        tester.widget<TextField>(nameField).controller!.text,
        'Survives the lab',
      );
      expect(find.text('customer.edit · r6'), findsOneWidget);
      expect(find.textContaining('component.lab · r'), findsNothing);
    },
  );

  testWidgets('Component Lab remains overflow-free at a narrow native width', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(GenuxShowcaseApp(fixtureSource: fixture));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final labSource = File(
      'assets/views/component-lab.genux.json',
    ).readAsStringSync();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspacePage(
            runtime: ShowcaseRuntime.standard(),
            initialViewCode: 'component.lab',
            initialInstanceKey: 'component.lab:narrow-test',
            initialSource: labSource,
          ),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('Component Lab'));

    expect(find.text('Component Lab'), findsOneWidget);
  });

  testWidgets('failed secondary load keeps the active surface visible', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspacePage(
            runtime: ShowcaseRuntime.standard(),
            initialSource: fixture,
            sourceLoader: (target) =>
                throw StateError('QueryHub unavailable for ${target.viewCode}'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final openSummary = find.text('Open customer summary');
    await tester.ensureVisible(openSummary);
    await tester.tap(openSummary);
    await tester.pumpAndSettle();

    expect(find.text('Edit customer'), findsOneWidget);
    expect(
      find.text('View open failed at load; current View retained.'),
      findsOneWidget,
    );
    expect(find.textContaining('Unable to load demo'), findsNothing);
  });

  testWidgets('superseded open cannot clear a newer navigation busy state', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1000);
    addTearDown(tester.view.reset);
    final summary = File(
      'assets/views/customer-summary.genux.json',
    ).readAsStringSync();
    final firstLoad = Completer<String>();
    final secondLoad = Completer<String>();
    var summaryLoads = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkspacePage(
            runtime: ShowcaseRuntime.standard(),
            initialSource: fixture,
            sourceLoader: (target) {
              if (target.viewCode != 'customer.summary') {
                throw StateError('Unexpected View ${target.viewCode}');
              }
              summaryLoads += 1;
              return summaryLoads == 1 ? firstLoad.future : secondLoad.future;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final openSummary = find.text('Open customer summary');
    await tester.ensureVisible(openSummary);
    await tester.tap(openSummary);
    await tester.pump();
    await tester.tap(openSummary);
    await tester.pump();
    expect(summaryLoads, 2);

    firstLoad.complete(summary);
    await tester.pump();
    await tester.pump();

    expect(find.text('Edit customer'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    secondLoad.complete(summary);
    await tester.pumpAndSettle();

    expect(find.text('Customer summary'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int attempts = 30,
}) async {
  for (var attempt = 0; attempt < attempts; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for $finder.');
}
