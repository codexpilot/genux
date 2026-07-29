import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';
import 'package:genux/src/flutter/material_catalog.dart';
import 'package:genux/src/flutter/surface_host.dart';

void main() {
  group('CollectionView customer-list fixture', () {
    late GenuxCatalog catalog;
    late GenuxCapabilityRegistry capabilities;
    late GenuxCompiledDocument document;
    final invocations = <GenuxActionInvocation>[];

    setUpAll(() {
      catalog = createGenuxCoreV2Catalog();
      capabilities = GenuxCapabilityRegistry([
        GenuxCapabilityDefinition(
          code: 'customer.select',
          arguments: {
            'customerId': const GenuxArgumentDefinition(
              type: GenuxValueType.string,
              required: true,
            ),
            'customerName': const GenuxArgumentDefinition(
              type: GenuxValueType.string,
              required: true,
            ),
          },
        ),
      ]);

      final source = File('assets/views/customer-list.genux.json').readAsStringSync();
      final result = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      ).compileJson(source);

      if (result is! GenuxCompileSuccess) {
        final failure = result as GenuxCompileFailure;
        fail('Compilation failed:\n${failure.diagnostics.join('\n')}');
      }

      document = result.document;
    });

    setUp(() {
      invocations.clear();
    });

    testWidgets('customer-list compiles and renders without errors', (tester) async {
      final session = GenuxSurfaceSession.activate(
        document,
        dispatcher: (invocation) {
          invocations.add(invocation);
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: GenuxSurfaceHost(
                session: session,
                catalog: createGenuxMaterialCatalog(catalog),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Customer Directory'), findsOneWidget);
      expect(find.text('Mya Chen'), findsOneWidget);
    });

    testWidgets('tap on Mya Chen dispatches customer.select with correct arguments', (tester) async {
      final session = GenuxSurfaceSession.activate(
        document,
        dispatcher: (invocation) {
          invocations.add(invocation);
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: GenuxSurfaceHost(
                session: session,
                catalog: createGenuxMaterialCatalog(catalog),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Mya Chen'));
      await tester.pump();

      expect(invocations.length, 1);
      expect(invocations[0].action.capability, 'customer.select');
      expect(invocations[0].arguments['customerId'], '1001');
      expect(invocations[0].arguments['customerName'], 'Mya Chen');
      final payload = invocations[0].payload as Map;
      expect(payload['key'], '1001');
      expect(payload['index'], 0);
      expect((payload['data'] as Map)['id'], '1001');
      expect((payload['data'] as Map)['name'], 'Mya Chen');
    });

    testWidgets('keyboard Enter activates item exactly once', (tester) async {
      final session = GenuxSurfaceSession.activate(
        document,
        dispatcher: (invocation) {
          invocations.add(invocation);
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: GenuxSurfaceHost(
                session: session,
                catalog: createGenuxMaterialCatalog(catalog),
              ),
            ),
          ),
        ),
      );

      // Find the first item and focus it
      final firstItem = find.text('Mya Chen');
      expect(firstItem, findsOneWidget);

      // Tap to focus
      await tester.tap(firstItem);
      await tester.pumpAndSettle();

      // Ensure focus is on the item by finding and focusing the Focus widget
      final focusWidget = find.ancestor(
        of: firstItem,
        matching: find.byType(Focus),
      ).first;
      final focusElement = tester.element(focusWidget);
      Focus.of(focusElement).requestFocus();
      await tester.pumpAndSettle();

      invocations.clear();

      // Send Enter key
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(invocations.length, 1);
      expect(invocations[0].arguments['customerId'], '1001');
    });

    testWidgets('keyboard Space activates item exactly once', (tester) async {
      final session = GenuxSurfaceSession.activate(
        document,
        dispatcher: (invocation) {
          invocations.add(invocation);
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: GenuxSurfaceHost(
                session: session,
                catalog: createGenuxMaterialCatalog(catalog),
              ),
            ),
          ),
        ),
      );

      final firstItem = find.text('Mya Chen');
      await tester.tap(firstItem);
      await tester.pumpAndSettle();

      // Ensure focus is on the item
      final focusWidget = find.ancestor(
        of: firstItem,
        matching: find.byType(Focus),
      ).first;
      final focusElement = tester.element(focusWidget);
      Focus.of(focusElement).requestFocus();
      await tester.pumpAndSettle();

      invocations.clear();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(invocations.length, 1);
      expect(invocations[0].arguments['customerId'], '1001');
    });
  });
}
