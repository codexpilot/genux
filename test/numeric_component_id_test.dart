import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  group('Numeric Component IDs', () {
    late GenuxCatalog catalog;
    late GenuxCapabilityRegistry capabilities;

    setUp(() {
      catalog = createGenuxCoreV2Catalog();
      capabilities = GenuxCapabilityRegistry([]);
    });

    test('catalog components have numeric IDs', () {
      expect(catalog.component('Column')?.id, equals(1));
      expect(catalog.component('Text')?.id, equals(2));
      expect(catalog.component('TextField')?.id, equals(3));
      expect(catalog.component('Checkbox')?.id, equals(4));
      expect(catalog.component('ComboBox')?.id, equals(5));
      expect(catalog.component('Button')?.id, equals(6));
      expect(catalog.component('Form')?.id, equals(7));
      expect(catalog.component('Row')?.id, equals(8));
      expect(catalog.component('Card')?.id, equals(9));
      expect(catalog.component('Divider')?.id, equals(10));
      expect(catalog.component('CollectionView')?.id, equals(11));
      expect(catalog.component('Expanded')?.id, equals(12));
    });

    test('can lookup component by numeric ID', () {
      expect(catalog.componentById(1)?.code, equals('Column'));
      expect(catalog.componentById(2)?.code, equals('Text'));
      expect(catalog.componentById(6)?.code, equals('Button'));
      expect(catalog.componentById(11)?.code, equals('CollectionView'));
      expect(catalog.componentById(999), isNull);
    });

    test('document with componentId compiles successfully', () {
      final json = {
        'schema': 'aix.genux/1.0',
        'view': {
          'id': '1',
          'code': 'test.view',
          'revision': 1,
          'kind': 'view',
        },
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'root',
        'state': {},
        'nodes': [
          {
            'id': 'root',
            'component': 'Text',
            'componentId': 2, // Use numeric ID
            'version': 1,
            'props': {'text': 'Hello World'},
          },
        ],
      };

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      );

      final result = compiler.compileJson(jsonEncode(json));
      expect(result, isA<GenuxCompileSuccess>());

      final doc = (result as GenuxCompileSuccess).document;
      expect(doc.nodes['root']?.component.code, equals('Text'));
    });

    test('componentId takes precedence over component name', () {
      final json = {
        'schema': 'aix.genux/1.0',
        'view': {
          'id': '1',
          'code': 'test.view',
          'revision': 1,
          'kind': 'view',
        },
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'root',
        'state': {},
        'nodes': [
          {
            'id': 'root',
            'component': 'Text', // Name says Text
            'componentId': 6, // ID says Button
            'version': 1,
            'bind': {'label': '/label'},
          },
        ],
      };

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      );

      final result = compiler.compileJson(jsonEncode(json));

      // Should fail validation because ID and name don't match
      expect(result, isA<GenuxCompileFailure>());
      final failure = result as GenuxCompileFailure;
      expect(
        failure.diagnostics.any((d) => d.code == 'component.mismatch'),
        isTrue,
      );
    });

    test('invalid componentId is rejected', () {
      final json = {
        'schema': 'aix.genux/1.0',
        'view': {
          'id': '1',
          'code': 'test.view',
          'revision': 1,
          'kind': 'view',
        },
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'root',
        'state': {},
        'nodes': [
          {
            'id': 'root',
            'component': 'Unknown',
            'componentId': 999, // Non-existent ID
            'version': 1,
          },
        ],
      };

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      );

      final result = compiler.compileJson(jsonEncode(json));
      expect(result, isA<GenuxCompileFailure>());

      final failure = result as GenuxCompileFailure;
      expect(
        failure.diagnostics.any((d) => d.code == 'component.unknown'),
        isTrue,
      );
    });

    test('backward compatibility - component name still works', () {
      final json = {
        'schema': 'aix.genux/1.0',
        'view': {
          'id': '1',
          'code': 'test.view',
          'revision': 1,
          'kind': 'view',
        },
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'root',
        'state': {},
        'nodes': [
          {
            'id': 'root',
            'component': 'Text', // Only name, no componentId
            'version': 1,
            'props': {'text': 'Hello'},
          },
        ],
      };

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      );

      final result = compiler.compileJson(jsonEncode(json));
      expect(result, isA<GenuxCompileSuccess>());
    });
  });
}
