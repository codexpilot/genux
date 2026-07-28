import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  late GenuxCompiledDocument document;

  setUpAll(() {
    final source = File(
      'assets/views/customer-edit.genux.json',
    ).readAsStringSync();
    final result = GenuxDocumentCompiler(
      catalog: createGenuxCoreCatalog(),
      capabilities: GenuxCapabilityRegistry([
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
      ]),
    ).compileJson(source);
    document = (result as GenuxCompileSuccess).document;
  });

  test(
    'dispatcher failures become inspectable results, not async errors',
    () async {
      final session = GenuxSurfaceSession.activate(
        document,
        dispatcher: (_) => throw StateError('QueryHub unavailable'),
      );

      final result = await session.emit(nodeId: 'saveButton', event: 'pressed');

      expect(result, isA<GenuxActionDispatchFailed>());
      final failure = result as GenuxActionDispatchFailed;
      expect(failure.action?.capability, 'customer.save');
      expect(failure.error, isA<StateError>());
    },
  );

  test('successful dispatch returns the resolved invocation', () async {
    final session = GenuxSurfaceSession.activate(document, dispatcher: (_) {});

    final result = await session.emit(nodeId: 'saveButton', event: 'pressed');

    expect(result.dispatched, isTrue);
    final invocation = (result as GenuxActionDispatched).invocation;
    expect(invocation.session, same(session));
    expect(invocation.action.capability, 'customer.save');
    expect(invocation.arguments['customer'], {
      'name': 'Mya',
      'customerType': 2,
      'marketingOptIn': false,
    });
  });

  test('an event with no binding is an explicit no-op result', () async {
    final session = GenuxSurfaceSession.activate(
      document,
      dispatcher: (_) => fail('Dispatcher must not run.'),
    );

    final result = await session.emit(nodeId: 'heading', event: 'pressed');

    expect(result, isA<GenuxActionNotBound>());
    expect(result.dispatched, isFalse);
  });
}
