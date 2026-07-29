import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  late GenuxCatalog catalog;
  late GenuxCapabilityRegistry capabilities;

  setUp(() {
    catalog = createGenuxCoreV2Catalog();
    capabilities = GenuxCapabilityRegistry([
      GenuxCapabilityDefinition(
        code: 'test.action',
        arguments: {
          'value': const GenuxArgumentDefinition(
            type: GenuxValueType.nullableString,
            required: true,
          ),
          'count': const GenuxArgumentDefinition(
            type: GenuxValueType.integer,
            required: false,
          ),
        },
      ),
    ]);
  });

  group('A2: Action context requirements at use sites', () {
    test('item binding in action outside item template fails', () {
      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'button',
        'state': {},
        'actions': {
          'testAction': {
            'capability': 'test.action',
            'args': {
              'value': {
                r'$bind': {'source': 'item', 'path': '/data/name'}
              }
            }
          }
        },
        'nodes': [
          {
            'id': 'button',
            'component': 'Button',
            'version': 1,
            'props': {'label': 'Test'},
            'events': {'pressed': 'testAction'}
          }
        ]
      });

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      );
      final result = compiler.compileObject(document.toJson());

      expect(result, isA<GenuxCompileFailure>());
      final failure = result as GenuxCompileFailure;
      expect(
        failure.diagnostics.any((d) =>
            d.code == 'action.contextUnavailable' &&
            d.location == '/nodes/button/events/pressed'),
        isTrue,
        reason: 'Should report action.contextUnavailable at event location',
      );
    });

    test('item binding in action inside item template compiles', () {
      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'collection',
        'state': {
          'items': [
            {'id': '1', 'name': 'Item 1'}
          ]
        },
        'actions': {
          'selectItem': {
            'capability': 'test.action',
            'args': {
              'value': {
                r'$bind': {'source': 'item', 'path': '/data/name'}
              }
            }
          }
        },
        'nodes': [
          {
            'id': 'collection',
            'component': 'CollectionView',
            'version': 1,
            'bind': {
              'items': '/items'
            },
            'props': {'itemKey': 'id', 'layout': 'list', 'itemHeight': 80},
            'slots': {
              'itemTemplate': ['itemButton']
            },
            'events': {}
          },
          {
            'id': 'itemButton',
            'component': 'Button',
            'version': 1,
            'bind': {
              'label': {'source': 'item', 'path': '/data/name'}
            },
            'events': {'pressed': 'selectItem'}
          }
        ]
      });

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      );
      final result = compiler.compileObject(document.toJson());

      expect(result, isA<GenuxCompileSuccess>());
    });

    test('event binding always available at event sites', () {
      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'button',
        'state': {},
        'actions': {
          'testAction': {
            'capability': 'test.action',
            'args': {
              'value': {
                r'$bind': {'source': 'event', 'path': '/data'}
              }
            }
          }
        },
        'nodes': [
          {
            'id': 'button',
            'component': 'Button',
            'version': 1,
            'props': {'label': 'Test'},
            'events': {'pressed': 'testAction'}
          }
        ]
      });

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      );
      final result = compiler.compileObject(document.toJson());

      expect(result, isA<GenuxCompileSuccess>());
    });
  });

  group('A3: Static vs deferred resolution', () {
    test('explicit null is type-checked', () {
      final capabilitiesNonNullable = GenuxCapabilityRegistry([
        GenuxCapabilityDefinition(
          code: 'test.action',
          arguments: {
            'value': const GenuxArgumentDefinition(
              type: GenuxValueType.string, // Non-nullable
              required: true,
            ),
          },
        ),
      ]);

      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'button',
        'state': {},
        'actions': {
          'testAction': {
            'capability': 'test.action',
            'args': {'value': null}
          }
        },
        'nodes': [
          {
            'id': 'button',
            'component': 'Button',
            'version': 1,
            'props': {'label': 'Test'},
            'events': {'pressed': 'testAction'}
          }
        ]
      });

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilitiesNonNullable,
      );
      final result = compiler.compileObject(document.toJson());

      expect(result, isA<GenuxCompileFailure>());
      final failure = result as GenuxCompileFailure;
      expect(
        failure.diagnostics.any((d) =>
            d.code == 'action.argumentType' &&
            d.location == '/actions/testAction/args/value'),
        isTrue,
        reason: 'Should reject explicit null for non-nullable argument',
      );
    });

    test('state binding resolved to null is type-checked', () {
      final capabilitiesNonNullable = GenuxCapabilityRegistry([
        GenuxCapabilityDefinition(
          code: 'test.action',
          arguments: {
            'value': const GenuxArgumentDefinition(
              type: GenuxValueType.string, // Non-nullable
              required: true,
            ),
          },
        ),
      ]);

      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'button',
        'state': {'nullValue': null},
        'actions': {
          'testAction': {
            'capability': 'test.action',
            'args': {
              'value': {r'$bind': '/nullValue'}
            }
          }
        },
        'nodes': [
          {
            'id': 'button',
            'component': 'Button',
            'version': 1,
            'props': {'label': 'Test'},
            'events': {'pressed': 'testAction'}
          }
        ]
      });

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilitiesNonNullable,
      );
      final result = compiler.compileObject(document.toJson());

      expect(result, isA<GenuxCompileFailure>());
      final failure = result as GenuxCompileFailure;
      expect(
        failure.diagnostics.any((d) =>
            d.code == 'action.argumentType' &&
            d.location == '/actions/testAction/args/value'),
        isTrue,
        reason: 'Should reject null from state binding for non-nullable argument',
      );
    });

    test('item/event bindings defer type-checking', () {
      final capabilitiesNonNullable = GenuxCapabilityRegistry([
        GenuxCapabilityDefinition(
          code: 'test.action',
          arguments: {
            'value': const GenuxArgumentDefinition(
              type: GenuxValueType.string, // Non-nullable
              required: true,
            ),
          },
        ),
      ]);

      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'button',
        'state': {},
        'actions': {
          'testAction': {
            'capability': 'test.action',
            'args': {
              'value': {
                r'$bind': {'source': 'event', 'path': '/data'}
              }
            }
          }
        },
        'nodes': [
          {
            'id': 'button',
            'component': 'Button',
            'version': 1,
            'props': {'label': 'Test'},
            'events': {'pressed': 'testAction'}
          }
        ]
      });

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilitiesNonNullable,
      );
      final result = compiler.compileObject(document.toJson());

      // Should compile successfully - type checking deferred to runtime
      expect(result, isA<GenuxCompileSuccess>());
    });
  });

  group('A4: Independent fallback validation', () {
    test('fallback with wrong type is rejected', () {
      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'button',
        'state': {},
        'actions': {
          'testAction': {
            'capability': 'test.action',
            'args': {
              'count': {
                r'$bind': '/missingPath',
                'fallback': 'not a number',
              }
            }
          }
        },
        'nodes': [
          {
            'id': 'button',
            'component': 'Button',
            'version': 1,
            'props': {'label': 'Test'},
            'events': {'pressed': 'testAction'}
          }
        ]
      });

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      );
      final result = compiler.compileObject(document.toJson());

      expect(result, isA<GenuxCompileFailure>());
      final failure = result as GenuxCompileFailure;
      expect(
        failure.diagnostics.any((d) =>
            d.code == 'action.argumentType' &&
            d.location.contains('fallback')),
        isTrue,
        reason: 'Should reject fallback with wrong type',
      );
    });

    test('fallback with binding is rejected', () {
      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'button',
        'state': {'backup': 'value'},
        'actions': {
          'testAction': {
            'capability': 'test.action',
            'args': {
              'value': {
                r'$bind': '/missingPath',
                'fallback': {r'$bind': '/backup'},
              }
            }
          }
        },
        'nodes': [
          {
            'id': 'button',
            'component': 'Button',
            'version': 1,
            'props': {'label': 'Test'},
            'events': {'pressed': 'testAction'}
          }
        ]
      });

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      );
      final result = compiler.compileObject(document.toJson());

      expect(result, isA<GenuxCompileFailure>());
      final failure = result as GenuxCompileFailure;
      expect(
        failure.diagnostics.any((d) => d.code == 'action.bindingFallback'),
        isTrue,
        reason: 'Should reject fallback containing binding',
      );
    });

    test('fallback validated even when primary path exists', () {
      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'button',
        'state': {'existingPath': 'value'},
        'actions': {
          'testAction': {
            'capability': 'test.action',
            'args': {
              'count': {
                r'$bind': '/existingPath',
                'fallback': 'not a number', // Wrong type
              }
            }
          }
        },
        'nodes': [
          {
            'id': 'button',
            'component': 'Button',
            'version': 1,
            'props': {'label': 'Test'},
            'events': {'pressed': 'testAction'}
          }
        ]
      });

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      );
      final result = compiler.compileObject(document.toJson());

      expect(result, isA<GenuxCompileFailure>());
      final failure = result as GenuxCompileFailure;
      expect(
        failure.diagnostics.any((d) =>
            d.code == 'action.argumentType' &&
            d.location.contains('fallback')),
        isTrue,
        reason: 'Should validate fallback even when primary path exists',
      );
    });

    test('valid fallback with missing primary compiles', () {
      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'button',
        'state': {},
        'actions': {
          'testAction': {
            'capability': 'test.action',
            'args': {
              'value': 'test',
              'count': {
                r'$bind': '/missingPath',
                'fallback': 42,
              }
            }
          }
        },
        'nodes': [
          {
            'id': 'button',
            'component': 'Button',
            'version': 1,
            'props': {'label': 'Test'},
            'events': {'pressed': 'testAction'}
          }
        ]
      });

      final compiler = GenuxDocumentCompiler(
        catalog: catalog,
        capabilities: capabilities,
      );
      final result = compiler.compileObject(document.toJson());

      expect(result, isA<GenuxCompileSuccess>());
    });
  });
}
