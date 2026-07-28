import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux_flutter.dart';

void main() {
  late GenuxCatalog catalog;
  late GenuxCapabilityRegistry capabilities;
  late GenuxCompiledDocument document;
  late GenuxFlutterCatalog flutterCatalog;

  setUp(() {
    catalog = createGenuxCoreCatalog();
    capabilities = GenuxCapabilityRegistry([
      GenuxCapabilityDefinition(
        code: 'view.open',
        arguments: const {
          'viewCode': GenuxArgumentDefinition(
            type: GenuxValueType.string,
            required: true,
          ),
        },
      ),
      GenuxCapabilityDefinition(
        code: 'customer.type.changed',
        arguments: const {
          'value': GenuxArgumentDefinition(
            type: GenuxValueType.nullableJsonScalar,
            required: true,
          ),
        },
      ),
      GenuxCapabilityDefinition(
        code: 'customer.save',
        arguments: const {
          'customer': GenuxArgumentDefinition(
            type: GenuxValueType.object,
            required: true,
          ),
        },
      ),
    ]);
    final source = File(
      'assets/views/customer-edit.genux.json',
    ).readAsStringSync();
    final result = GenuxDocumentCompiler(
      catalog: catalog,
      capabilities: capabilities,
    ).compileJson(source);
    document = (result as GenuxCompileSuccess).document;
    flutterCatalog = createGenuxMaterialCatalog(catalog);
  });

  testWidgets('public runtime renders the compiled customer fixture', (
    tester,
  ) async {
    final invocations = <GenuxActionInvocation>[];
    final session = GenuxSurfaceSession.activate(
      document,
      dispatcher: invocations.add,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GenuxSurfaceHost(session: session, catalog: flutterCatalog),
          ),
        ),
      ),
    );

    expect(find.text('Edit customer'), findsOneWidget);
    expect(find.text('Business'), findsOneWidget);
    expect(find.text('Dispatch customer.save'), findsOneWidget);

    final nameField = find.descendant(
      of: find.byKey(const ValueKey('genux:customerName')),
      matching: find.byType(TextField),
    );
    await tester.enterText(nameField, 'Mya Thandar');
    await tester.tap(find.text('Marketing consent'));
    await tester.pump();

    expect(session.store.version, 2);
    expect(invocations, isEmpty);

    await tester.tap(find.text('Business'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retail').last);
    await tester.pumpAndSettle();

    expect(session.store.version, 3);
    expect(
      session.store.read(GenuxJsonPointer.parse('/draft/customerType')).value,
      1,
    );
    expect(invocations, hasLength(1));
    expect(invocations.single.action.capability, 'customer.type.changed');
    expect(invocations.single.arguments, {'value': 1});
    expect(invocations.single.stateVersion, 3);

    await tester.tap(find.text('Dispatch customer.save'));
    await tester.pump();

    expect(invocations, hasLength(2));
    expect(invocations.last.action.capability, 'customer.save');
    expect(invocations.last.arguments, {
      'customer': {
        'name': 'Mya Thandar',
        'customerType': 1,
        'marketingOptIn': true,
      },
    });
  });

  testWidgets('clearable ComboBox commits a null selection before dispatch', (
    tester,
  ) async {
    final source = File('assets/views/customer-edit.genux.json')
        .readAsStringSync()
        .replaceFirst('"clearable": false', '"clearable": true');
    final result = GenuxDocumentCompiler(
      catalog: catalog,
      capabilities: capabilities,
    ).compileJson(source);
    final clearableDocument = (result as GenuxCompileSuccess).document;
    final invocations = <GenuxActionInvocation>[];
    final session = GenuxSurfaceSession.activate(
      clearableDocument,
      dispatcher: invocations.add,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: GenuxSurfaceHost(session: session, catalog: flutterCatalog),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Business'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No selection').last);
    await tester.pumpAndSettle();

    expect(
      session.store.read(GenuxJsonPointer.parse('/draft/customerType')).value,
      isNull,
    );
    expect(invocations.single.arguments, {'value': null});
    expect(invocations.single.stateVersion, 1);
  });

  testWidgets('ComboBox keeps an existing disabled selection visible', (
    tester,
  ) async {
    final source = File(
      'assets/views/customer-edit.genux.json',
    ).readAsStringSync().replaceFirst('"customerType": 2', '"customerType": 3');
    final result = GenuxDocumentCompiler(
      catalog: catalog,
      capabilities: capabilities,
    ).compileJson(source);
    final disabledSelectionDocument = (result as GenuxCompileSuccess).document;
    final session = GenuxSurfaceSession.activate(
      disabledSelectionDocument,
      dispatcher: (_) {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GenuxSurfaceHost(session: session, catalog: flutterCatalog),
        ),
      ),
    );

    expect(find.text('Internal'), findsOneWidget);
    expect(
      session.store.read(GenuxJsonPointer.parse('/draft/customerType')).value,
      3,
    );
  });

  testWidgets('equivalent catalog instances render the compiled document', (
    tester,
  ) async {
    final equivalentFlutterCatalog = createGenuxMaterialCatalog(
      createGenuxCoreCatalog(),
    );
    final session = GenuxSurfaceSession.activate(document, dispatcher: (_) {});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: GenuxSurfaceHost(
              session: session,
              catalog: equivalentFlutterCatalog,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Edit customer'), findsOneWidget);
    expect(find.text('Unable to render Form.'), findsNothing);
  });

  testWidgets('nodes without bindings ignore unrelated state changes', (
    tester,
  ) async {
    final result =
        GenuxDocumentCompiler(
          catalog: catalog,
          capabilities: GenuxCapabilityRegistry(const []),
        ).compileObject({
          'schema': 'aix.genux/1.0',
          'view': {
            'id': 'static-label',
            'code': 'test.static-label',
            'revision': 1,
            'kind': 'view',
          },
          'catalog': {
            'id': catalog.id,
            'version': catalog.version,
            'checksum': catalog.checksum,
          },
          'root': 'label',
          'state': {'counter': 0},
          'nodes': [
            {
              'id': 'label',
              'component': 'Text',
              'version': 1,
              'props': {'text': 'Static label'},
            },
          ],
        });
    final staticDocument = (result as GenuxCompileSuccess).document;
    var builds = 0;
    final registrations = <GenuxFlutterRegistration>[];
    for (final component in catalog.components.values) {
      GenuxComponentBuilder builder = _emptyBuilder;
      if (component.code == 'Text') {
        builder = (context, scope) {
          builds += 1;
          return Text(scope.requireValue<String>('text'));
        };
      }
      registrations.add(
        GenuxFlutterRegistration(
          componentCode: component.code,
          builder: builder,
        ),
      );
    }
    final countingCatalog = GenuxFlutterCatalog(
      catalog: catalog,
      registrations: registrations,
    );
    final session = GenuxSurfaceSession.activate(
      staticDocument,
      dispatcher: (_) {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: GenuxSurfaceHost(session: session, catalog: countingCatalog),
      ),
    );
    expect(builds, 1);

    final commit = session.store.transact((transaction) {
      transaction.setPath('/counter', 1);
      return null;
    });
    expect(commit.committed, isTrue);
    await tester.pump();

    expect(builds, 1);
    expect(find.text('Static label'), findsOneWidget);
  });

  test('Flutter catalog rejects a component version mismatch', () {
    final components = [
      for (final component in catalog.components.values)
        if (component.code == 'Form')
          GenuxComponentDefinition(
            code: component.code,
            version: component.version + 1,
            properties: component.properties,
            channels: component.channels,
            events: component.events,
            slots: component.slots,
          )
        else
          component,
    ];
    final mismatchedCatalog = GenuxCatalog(
      id: catalog.id,
      version: catalog.version,
      checksum: catalog.checksum,
      components: components,
    );
    final mismatchedFlutterCatalog = createGenuxMaterialCatalog(
      mismatchedCatalog,
    );

    expect(
      () => mismatchedFlutterCatalog.builderFor(document.root.component),
      throwsStateError,
    );
  });

  test('Flutter catalog rejects incomplete renderer registration', () {
    expect(
      () => GenuxFlutterCatalog(catalog: catalog, registrations: const []),
      throwsArgumentError,
    );
  });

  test('Flutter catalog rejects duplicate renderer registration', () {
    expect(
      () => GenuxFlutterCatalog(
        catalog: catalog,
        registrations: const [
          GenuxFlutterRegistration(
            componentCode: 'Text',
            builder: _emptyBuilder,
          ),
          GenuxFlutterRegistration(
            componentCode: 'Text',
            builder: _emptyBuilder,
          ),
        ],
      ),
      throwsArgumentError,
    );
  });
}

Widget _emptyBuilder(BuildContext context, GenuxComponentScope scope) =>
    const SizedBox.shrink();
