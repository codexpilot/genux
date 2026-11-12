import 'dart:convert';
import 'dart:io';

import 'package:genux/genux.dart';
import 'package:flutter_test/flutter_test.dart';

String jsonDocument(Object? root) =>
    jsonEncode({'schemaVersion': 1, 'root': root});

Map<String, Object> textNode(String text) => {'type': 'text', 'text': text};

void main() {
  test(
    'example parses and serializes deterministically through a round trip',
    () {
      final source = File('examples/dashboard.json').readAsStringSync();
      final document = GenuxPresentationDocument.parse(source);
      final normalized = document.toJsonString();
      expect(
        GenuxPresentationDocument.parse(normalized).toJsonString(),
        normalized,
      );
      expect(document.root, isA<GenuxWorkspaceNode>());
      final workspace = document.root as GenuxWorkspaceNode;
      final column = workspace.body as GenuxColumnNode;
      expect(column.children, hasLength(2));
      expect(() => column.children.add(column), throwsUnsupportedError);
      final detached = document.toJson();
      detached['root'] = null;
      expect(document.toJsonString(), normalized);
    },
  );

  test('accepts and rejects the shared JSON Schema conformance fixtures', () {
    final cases = jsonDecode(
      File('test/fixtures/presentation_contract_cases.json').readAsStringSync(),
    ) as List;
    for (final rawCase in cases) {
      final item = rawCase as Map<String, dynamic>;
      final source = jsonEncode(item['document']);
      if (item['valid'] == true) {
        expect(
          () => GenuxPresentationDocument.parse(source),
          returnsNormally,
          reason: source,
        );
      } else {
        expect(
          () => GenuxPresentationDocument.parse(source),
          throwsA(isA<GenuxFormatException>()),
          reason: source,
        );
      }
    }
  });

  test('documents near the byte limit round-trip or fail during parsing', () {
    String nearLimit(int target) {
      final children = [
        for (var i = 0; i < 63; i++) textNode('a' * 4096),
        textNode(''),
      ];
      var source = jsonDocument({'type': 'column', 'children': children});
      final remaining = target - utf8.encode(source).length;
      expect(remaining, inInclusiveRange(0, 4096));
      children.last['text'] = 'a' * remaining;
      source = jsonDocument({'type': 'column', 'children': children});
      expect(utf8.encode(source).length, target);
      return source;
    }

    final accepted = GenuxPresentationDocument.parse(nearLimit(262100));
    final normalized = accepted.toJsonString();
    expect(utf8.encode(normalized).length, lessThanOrEqualTo(262144));
    expect(
      GenuxPresentationDocument.parse(normalized).toJsonString(),
      normalized,
    );
    expect(
      () => GenuxPresentationDocument.parse(nearLimit(262143)),
      throwsA(
        isA<GenuxFormatException>().having(
          (e) => e.message,
          'message',
          'Normalized JSON exceeds 262144 UTF-8 bytes',
        ),
      ),
    );
  });

  test('reports stable paths for malformed, missing and unsafe properties', () {
    void error(String input, String path) {
      expect(
        () => GenuxPresentationDocument.parse(input),
        throwsA(
          isA<GenuxFormatException>().having((e) => e.path, 'path', path),
        ),
      );
    }

    error('{', r'$');
    error('{"schemaVersion":1}', r'$.root');
    error(
      '{"schemaVersion":1,"root":{"type":"text","text":"x","action":"go"}}',
      r'$.root["action"]',
    );
    error(
      '{"schemaVersion":1,"root":{"type":"column","children":[{"type":"text","text":3}]}}',
      r'$.root.children[0].text',
    );
    error(
      '{"schemaVersion":1,"root":{"type":"text","text":"x","z":1,"a":2}}',
      r'$.root["a"]',
    );
    error(
      '{"schemaVersion":1,"root":{"type":"column","children":[],"spacing":1e999}}',
      r'$.root.spacing',
    );
  });

  test('enforces string, list, byte, total node and tree depth limits', () {
    expect(
      () =>
          GenuxPresentationDocument.parse(jsonDocument(textNode('😀' * 4096))),
      returnsNormally,
    );
    expect(
      () => GenuxPresentationDocument.parse(jsonDocument(textNode('a' * 4097))),
      throwsA(
        isA<GenuxFormatException>().having(
          (e) => e.path,
          'path',
          r'$.root.text',
        ),
      ),
    );
    expect(
      () => GenuxPresentationDocument.parse(' ' * 262145),
      throwsA(isA<GenuxFormatException>()),
    );
    expect(
      () => GenuxPresentationDocument.parse(
        jsonDocument({
          'type': 'column',
          'children': List.generate(101, (_) => textNode('a')),
        }),
      ),
      throwsA(isA<GenuxFormatException>()),
    );
    final many = {
      'type': 'column',
      'children': List.generate(
        6,
        (_) => {
          'type': 'column',
          'children': List.generate(100, (_) => textNode('a')),
        },
      ),
    };
    expect(
      () => GenuxPresentationDocument.parse(jsonDocument(many)),
      throwsA(isA<GenuxFormatException>()),
    );
    Object nested = textNode('end');
    for (var i = 0; i < 31; i++) {
      nested = {
        'type': 'column',
        'children': [nested],
      };
    }
    expect(
      () => GenuxPresentationDocument.parse(jsonDocument(nested)),
      returnsNormally,
    );
    nested = {
      'type': 'column',
      'children': [nested],
    };
    expect(
      () => GenuxPresentationDocument.parse(jsonDocument(nested)),
      throwsA(isA<GenuxFormatException>()),
    );
    expect(
      () => GenuxPresentationDocument.parse('[' * 1000),
      throwsA(isA<GenuxFormatException>()),
    );
  });
}
