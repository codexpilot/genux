import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux_flutter.dart';

void main() {
  late GenuxCatalog catalog;
  late GenuxCompiledDocument document;
  late GenuxFlutterCatalog flutterCatalog;

  setUp(() {
    catalog = createGenuxCoreCatalog();
    final capabilities = GenuxCapabilityRegistry([
      GenuxCapabilityDefinition(
        code: 'test.text.changed',
        arguments: const {
          'value': GenuxArgumentDefinition(
            type: GenuxValueType.string,
            required: true,
          ),
        },
      ),
      GenuxCapabilityDefinition(
        code: 'test.text.submitted',
        arguments: const {
          'value': GenuxArgumentDefinition(
            type: GenuxValueType.string,
            required: true,
          ),
        },
      ),
      GenuxCapabilityDefinition(
        code: 'test.checkbox.changed',
        arguments: const {
          'value': GenuxArgumentDefinition(
            type: GenuxValueType.boolean,
            required: true,
          ),
        },
      ),
      GenuxCapabilityDefinition(code: 'test.form.submitted'),
      GenuxCapabilityDefinition(code: 'test.form.cancelled'),
    ]);
    final result = GenuxDocumentCompiler(
      catalog: catalog,
      capabilities: capabilities,
    ).compileObject(_formDocument(catalog));
    if (result case GenuxCompileFailure(:final diagnostics)) {
      fail(
        diagnostics
            .map((diagnostic) => '${diagnostic.code} ${diagnostic.location}')
            .join('\n'),
      );
    }
    document = (result as GenuxCompileSuccess).document;
    flutterCatalog = createGenuxMaterialCatalog(catalog);
  });

  testWidgets(
    'form controls commit before dispatch and preserve text editing',
    (tester) async {
      final invocations = <GenuxActionInvocation>[];
      final session = GenuxSurfaceSession.activate(
        document,
        dispatcher: invocations.add,
      );

      await tester.pumpWidget(_testApp(session, flutterCatalog));

      final textField = find.descendant(
        of: find.byKey(const ValueKey('genux:name')),
        matching: find.byType(TextField),
      );
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Maya');
      await tester.pump();

      expect(
        session.store.read(GenuxJsonPointer.parse('/form/name')).value,
        'Maya',
      );
      expect(invocations, hasLength(1));
      expect(invocations.single.event, 'changed');
      expect(invocations.single.payload, 'Maya');
      expect(invocations.single.arguments, {'value': 'Maya'});
      expect(invocations.single.stateVersion, 1);

      var renderedTextField = tester.widget<TextField>(textField);
      renderedTextField.controller!.selection = const TextSelection.collapsed(
        offset: 2,
      );
      expect(renderedTextField.focusNode!.hasFocus, isTrue);

      final externalUpdate = session.store.transact((transaction) {
        transaction.setPath('/form/name', 'Mya Zin');
        return null;
      });
      expect(externalUpdate.committed, isTrue);
      await tester.pump();

      renderedTextField = tester.widget<TextField>(textField);
      expect(renderedTextField.controller!.text, 'Mya Zin');
      expect(renderedTextField.controller!.selection.baseOffset, 2);
      expect(renderedTextField.focusNode!.hasFocus, isTrue);

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(invocations, hasLength(2));
      expect(invocations.last.event, 'submitted');
      expect(invocations.last.payload, 'Mya Zin');
      expect(invocations.last.arguments, {'value': 'Mya Zin'});
      expect(invocations.last.stateVersion, 2);

      await tester.tap(find.text('Active'));
      await tester.pump();

      expect(
        session.store.read(GenuxJsonPointer.parse('/form/active')).value,
        isTrue,
      );
      expect(invocations, hasLength(3));
      expect(invocations.last.event, 'changed');
      expect(invocations.last.payload, isTrue);
      expect(invocations.last.arguments, {'value': true});
      expect(invocations.last.stateVersion, 3);
    },
  );

  testWidgets('layout components map their validated properties to Material', (
    tester,
  ) async {
    final session = GenuxSurfaceSession.activate(document, dispatcher: (_) {});

    await tester.pumpWidget(_testApp(session, flutterCatalog));

    final row = tester.widget<Row>(
      find.byKey(const ValueKey('genux:summaryRow')),
    );
    expect(row.mainAxisSize, MainAxisSize.min);
    expect(row.crossAxisAlignment, CrossAxisAlignment.center);
    expect(row.children.whereType<SizedBox>().single.width, 8);

    final cardFinder = find.byKey(const ValueKey('genux:card'));
    expect(cardFinder, findsOneWidget);
    final configuredPadding = find.descendant(
      of: cardFinder,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Padding && widget.padding == const EdgeInsets.all(20),
      ),
    );
    expect(configuredPadding, findsOneWidget);

    final divider = tester.widget<Divider>(
      find.byKey(const ValueKey('genux:divider')),
    );
    expect(divider.thickness, 2);
    expect(divider.indent, 4);
    expect(divider.endIndent, 6);
  });

  testWidgets('form renders status and dispatches keyboard lifecycle events', (
    tester,
  ) async {
    final invocations = <GenuxActionInvocation>[];
    final session = GenuxSurfaceSession.activate(
      document,
      dispatcher: invocations.add,
    );

    await tester.pumpWidget(_testApp(session, flutterCatalog));

    expect(find.text('Please review this form'), findsOneWidget);
    expect(
      find.text('name: Example server validation message'),
      findsOneWidget,
    );

    final textField = find.descendant(
      of: find.byKey(const ValueKey('genux:name')),
      matching: find.byType(TextField),
    );
    await tester.tap(textField);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(
      invocations.where(
        (invocation) =>
            invocation.sourceNodeId == 'demoForm' &&
            invocation.event == 'submitted',
      ),
      hasLength(1),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(
      invocations.where(
        (invocation) =>
            invocation.sourceNodeId == 'demoForm' &&
            invocation.event == 'cancelled',
      ),
      hasLength(1),
    );

    session.store.transact(
      (transaction) => transaction.setPath('/ui/busy', true),
      origin: GenuxTransactionOrigin.system,
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('genux:demoForm:busy')), findsOneWidget);
    final absorber = tester.widget<AbsorbPointer>(
      find.descendant(
        of: find.byKey(const ValueKey('genux:demoForm')),
        matching: find.byType(AbsorbPointer),
      ),
    );
    expect(absorber.absorbing, isTrue);
    expect(tester.widget<TextField>(textField).focusNode!.hasFocus, isFalse);

    final nameBeforeBlockedInput = session.store
        .read(GenuxJsonPointer.parse('/form/name'))
        .value;
    final invocationCountBeforeBlockedInput = invocations.length;
    await tester.sendKeyEvent(LogicalKeyboardKey.keyX);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(
      session.store.read(GenuxJsonPointer.parse('/form/name')).value,
      nameBeforeBlockedInput,
    );
    expect(invocations, hasLength(invocationCountBeforeBlockedInput));
  });
}

Widget _testApp(
  GenuxSurfaceSession session,
  GenuxFlutterCatalog flutterCatalog,
) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GenuxSurfaceHost(session: session, catalog: flutterCatalog),
      ),
    ),
  );
}

Map<String, Object?> _formDocument(GenuxCatalog catalog) => {
  'schema': 'aix.genux/1.0',
  'view': {
    'id': 'form-components',
    'code': 'test.form-components',
    'revision': 1,
    'kind': 'view',
  },
  'catalog': {
    'id': catalog.id,
    'version': catalog.version,
    'checksum': catalog.checksum,
  },
  'root': 'root',
  'state': {
    'form': {'name': 'Mya', 'active': false},
    'ui': {'enabled': true, 'readOnly': false, 'busy': false},
    'errors': {'name': null},
    'formErrors': {'name': 'Example server validation message'},
  },
  'actions': {
    'nameChanged': {
      'capability': 'test.text.changed',
      'args': {
        'value': {r'$bind': '/form/name'},
      },
    },
    'nameSubmitted': {
      'capability': 'test.text.submitted',
      'args': {
        'value': {r'$bind': '/form/name'},
      },
    },
    'activeChanged': {
      'capability': 'test.checkbox.changed',
      'args': {
        'value': {r'$bind': '/form/active'},
      },
    },
    'formSubmitted': {'capability': 'test.form.submitted'},
    'formCancelled': {'capability': 'test.form.cancelled'},
  },
  'nodes': [
    {
      'id': 'root',
      'component': 'Column',
      'version': 1,
      'props': {'mainAxisSize': 'min', 'crossAxisAlignment': 'stretch'},
      'slots': {
        'children': ['demoForm', 'divider', 'summaryRow'],
      },
    },
    {
      'id': 'demoForm',
      'component': 'Form',
      'version': 1,
      'bind': {'busy': '/ui/busy', 'errors': '/formErrors'},
      'events': {'submitted': 'formSubmitted', 'cancelled': 'formCancelled'},
      'slots': {
        'content': ['card'],
      },
    },
    {
      'id': 'card',
      'component': 'Card',
      'version': 1,
      'props': {'padding': 20},
      'slots': {
        'content': ['fields'],
      },
    },
    {
      'id': 'fields',
      'component': 'Column',
      'version': 1,
      'props': {'mainAxisSize': 'min', 'crossAxisAlignment': 'stretch'},
      'slots': {
        'children': ['name', 'active'],
      },
    },
    {
      'id': 'name',
      'component': 'TextField',
      'version': 1,
      'props': {'label': 'Name', 'hint': 'Customer name', 'maxLines': 1},
      'bind': {
        'value': '/form/name',
        'enabled': '/ui/enabled',
        'readOnly': '/ui/readOnly',
        'errorText': '/errors/name',
      },
      'events': {'changed': 'nameChanged', 'submitted': 'nameSubmitted'},
    },
    {
      'id': 'active',
      'component': 'Checkbox',
      'version': 1,
      'props': {'label': 'Active'},
      'bind': {'value': '/form/active', 'enabled': '/ui/enabled'},
      'events': {'changed': 'activeChanged'},
    },
    {
      'id': 'divider',
      'component': 'Divider',
      'version': 1,
      'props': {'thickness': 2, 'indent': 4, 'endIndent': 6},
    },
    {
      'id': 'summaryRow',
      'component': 'Row',
      'version': 1,
      'props': {
        'gap': 8,
        'mainAxisSize': 'min',
        'crossAxisAlignment': 'center',
      },
      'slots': {
        'children': ['left', 'right'],
      },
    },
    {
      'id': 'left',
      'component': 'Text',
      'version': 1,
      'props': {'text': 'Left'},
    },
    {
      'id': 'right',
      'component': 'Text',
      'version': 1,
      'props': {'text': 'Right'},
    },
  ],
};
