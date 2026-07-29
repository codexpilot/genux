import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  group('Document validator hardening', () {
    late GenuxCatalog catalog;
    late GenuxCapabilityRegistry capabilities;
    late GenuxDocumentValidator validator;

    setUp(() {
      catalog = createGenuxCoreV2Catalog();
      capabilities = GenuxCapabilityRegistry([]);
      validator = const GenuxDocumentValidator();
    });

    test('cycle returns graph.cycle without throwing', () {
      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'a',
        'state': {},
        'nodes': [
          {
            'id': 'a',
            'component': 'Column',
            'version': 1,
            'slots': {
              'children': ['b']
            }
          },
          {
            'id': 'b',
            'component': 'Column',
            'version': 1,
            'slots': {
              'children': ['a']
            }
          }
        ]
      });

      final result = validator.validate(document, catalog, capabilities: capabilities);
      expect(result.isValid, false);
      expect(
        result.diagnostics.any((d) => d.code == 'graph.cycle'),
        true,
      );
    });

    test('self-cycle returns graph.cycle without throwing', () {
      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'a',
        'state': {},
        'nodes': [
          {
            'id': 'a',
            'component': 'Column',
            'version': 1,
            'slots': {
              'children': ['a']
            }
          }
        ]
      });

      final result = validator.validate(document, catalog, capabilities: capabilities);
      expect(result.isValid, false);
      expect(
        result.diagnostics.any((d) => d.code == 'graph.cycle'),
        true,
      );
    });

    test('graph beyond maxDepth returns limit.depth without throwing', () {
      const maxDepth = 10;
      final validator = const GenuxDocumentValidator(
        limits: GenuxValidationLimits(maxDepth: maxDepth),
      );

      // Build a linear chain exceeding maxDepth
      final nodes = <Map<String, Object?>>[];
      for (var i = 0; i <= maxDepth + 2; i++) {
        nodes.add({
          'id': 'node$i',
          'component': 'Column',
          'version': 1,
          if (i < maxDepth + 2)
            'slots': {
              'children': ['node${i + 1}']
            }
        });
      }

      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'node0',
        'state': {},
        'nodes': nodes,
      });

      final result = validator.validate(document, catalog, capabilities: capabilities);
      expect(result.isValid, false);
      expect(
        result.diagnostics.any((d) => d.code == 'limit.depth'),
        true,
      );
    });

    test('item binding inside itemTemplate compiles', () {
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
            {'id': '1', 'name': 'Test'}
          ]
        },
        'nodes': [
          {
            'id': 'collection',
            'component': 'CollectionView',
            'version': 1,
            'props': {'itemKey': 'id', 'layout': 'list'},
            'bind': {'items': '/items'},
            'slots': {
              'itemTemplate': ['itemText']
            }
          },
          {
            'id': 'itemText',
            'component': 'Text',
            'version': 1,
            'bind': {
              'text': {'source': 'item', 'path': '/data/name'}
            }
          }
        ]
      });

      final result = validator.validate(document, catalog, capabilities: capabilities);
      expect(result.isValid, true);
    });

    test('item binding reached through both normal and item-introducing parents fails', () {
      // This creates an invalid graph with multiple parents, but context analysis must terminate
      final document = GenuxDocument.fromJson({
        'schema': 'aix.genux/1.0',
        'view': {'id': 'test', 'code': 'test', 'revision': 1, 'kind': 'view'},
        'catalog': {
          'id': 'aix.core',
          'version': 2,
          'checksum': catalog.checksum,
        },
        'root': 'root',
        'state': {
          'items': [
            {'id': '1', 'name': 'Test'}
          ]
        },
        'nodes': [
          {
            'id': 'root',
            'component': 'Column',
            'version': 1,
            'slots': {
              'children': ['collection', 'sharedChild']
            }
          },
          {
            'id': 'collection',
            'component': 'CollectionView',
            'version': 1,
            'props': {'itemKey': 'id', 'layout': 'list'},
            'bind': {'items': '/items'},
            'slots': {
              'itemTemplate': ['sharedChild']
            }
          },
          {
            'id': 'sharedChild',
            'component': 'Text',
            'version': 1,
            'bind': {
              'text': {'source': 'item', 'path': '/data/name'}
            }
          }
        ]
      });

      final result = validator.validate(document, catalog, capabilities: capabilities);
      expect(result.isValid, false);
      // Should have graph.parentCount error (multiple parents)
      expect(
        result.diagnostics.any((d) => d.code == 'graph.parentCount'),
        true,
      );
      // Item binding validation must not crash or hang
    });
  });
}
