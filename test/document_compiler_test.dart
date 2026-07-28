import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  late GenuxCatalog catalog;
  late GenuxDocumentCompiler compiler;
  late String fixture;

  setUpAll(() {
    fixture = File('assets/views/customer-edit.genux.json').readAsStringSync();
  });

  setUp(() {
    catalog = createGenuxCoreCatalog();
    compiler = GenuxDocumentCompiler(
      catalog: catalog,
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
    );
  });

  test('compiles a valid ComboBox surface into resolved runtime handles', () {
    final result = compiler.compileJson(fixture);

    expect(result, isA<GenuxCompileSuccess>());
    final document = (result as GenuxCompileSuccess).document;
    final comboBox = document.nodes['customerType']!;

    expect(document.root.component.code, 'Form');
    expect(comboBox.component, same(catalog.component('ComboBox')));
    expect(
      comboBox.bindings['value']!.definition.direction,
      GenuxChannelDirection.state,
    );
    expect(comboBox.bindings['value']!.isWritable, isTrue);
    expect(comboBox.bindings['value']!.read(document.state), 2);
    expect(document.actions['saveCustomer']!.resolveArgs(document.state), {
      'customer': {'name': 'Mya', 'customerType': 2, 'marketingOptIn': false},
    });
    expect(
      () => document.actions['saveCustomer']!.resolveArgs(const {}),
      throwsStateError,
    );
  });

  test(
    'rejects an unknown component without producing a compiled document',
    () {
      final source = fixture.replaceFirst('"ComboBox"', '"MysteryBox"');

      final result = compiler.compileJson(source);

      expect(result, isA<GenuxCompileFailure>());
      final diagnostics = (result as GenuxCompileFailure).diagnostics;
      expect(
        diagnostics.map((item) => item.code),
        contains('component.unknown'),
      );
    },
  );

  test('rejects a missing state path', () {
    final source = fixture.replaceFirst(
      '"value": "/draft/customerType"',
      '"value": "/draft/missingType"',
    );

    final result = compiler.compileJson(source);

    expect(result, isA<GenuxCompileFailure>());
    final diagnostics = (result as GenuxCompileFailure).diagnostics;
    expect(
      diagnostics.map((item) => item.code),
      contains('binding.missingValue'),
    );
  });

  test('enforces the local semantic capability allowlist', () {
    final source = fixture.replaceFirst('customer.save', 'system.execute');

    final result = compiler.compileJson(source);

    expect(result, isA<GenuxCompileFailure>());
    final diagnostics = (result as GenuxCompileFailure).diagnostics;
    expect(
      diagnostics.map((item) => item.code),
      contains('action.capabilityDenied'),
    );
  });

  test('validates semantic capability argument contracts', () {
    final source = fixture.replaceFirst('{"\$bind": "/draft"}', '42');

    final result = compiler.compileJson(source);

    expect(result, isA<GenuxCompileFailure>());
    expect(
      (result as GenuxCompileFailure).diagnostics.map((item) => item.code),
      contains('action.argumentType'),
    );
  });

  test('requires the exact catalog checksum', () {
    final source = fixture.replaceFirst(catalog.checksum, 'sha256:wrong');

    final result = compiler.compileJson(source);

    expect(result, isA<GenuxCompileFailure>());
    expect(
      (result as GenuxCompileFailure).diagnostics.map((item) => item.code),
      contains('catalog.checksumMismatch'),
    );
  });

  test('rejects duplicate ComboBox choice keys before rendering', () {
    final source = fixture.replaceFirst(
      '{"key": 2, "label": "Business"}',
      '{"key": 1.0, "label": "Business"}',
    );

    final result = compiler.compileJson(source);

    expect(result, isA<GenuxCompileFailure>());
    expect(
      (result as GenuxCompileFailure).diagnostics.map((item) => item.code),
      contains('binding.type'),
    );
  });

  test('writable state bindings reject fallback and root replacement', () {
    final fallbackSource = fixture.replaceFirst(
      '"value": "/draft/customerType"',
      '"value": {"path": "/draft/customerType", "fallback": 1}',
    );
    final rootSource = fixture.replaceFirst(
      '"value": "/draft/customerType"',
      '"value": ""',
    );

    final fallbackResult = compiler.compileJson(fallbackSource);
    final rootResult = compiler.compileJson(rootSource);

    expect(
      (fallbackResult as GenuxCompileFailure).diagnostics.map(
        (item) => item.code,
      ),
      contains('binding.stateFallback'),
    );
    expect(
      (rootResult as GenuxCompileFailure).diagnostics.map((item) => item.code),
      contains('binding.rootWrite'),
    );
  });

  test('malformed JSON becomes a diagnostic instead of escaping', () {
    final result = compiler.compileJson('{not json');

    expect(result, isA<GenuxCompileFailure>());
    expect(
      (result as GenuxCompileFailure).diagnostics.single.code,
      'syntax.invalid',
    );
  });

  test('non-JSON programmatic values become diagnostics', () {
    final source = jsonDecode(fixture) as Map<String, Object?>;
    final state = source['state']! as Map<String, Object?>;
    state['invalid'] = DateTime(2026);

    final result = compiler.compileObject(source);

    expect(result, isA<GenuxCompileFailure>());
    expect(
      (result as GenuxCompileFailure).diagnostics.map((item) => item.code),
      contains('syntax.nonJsonValue'),
    );
  });
}
