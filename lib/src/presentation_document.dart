import 'dart:convert';

/// A problem in a Gux static presentation document.
class GuxFormatException implements Exception {
  const GuxFormatException(this.path, this.message);

  /// Location in the document, expressed as a JSON path.
  final String path;
  final String message;

  @override
  String toString() => 'GuxFormatException at $path: $message';
}

/// A validated, experimental internal static presentation document.
///
/// This format only describes presentation. It does not define actions, data
/// bindings, arbitrary widget constructors, or any external resource access.
/// This format is not an A2UI protocol or a runtime binding artifact.
class GuxPresentationDocument {
  GuxPresentationDocument._(this.root);

  static const int schemaVersion = 1;
  static const int maxInputBytes = 262144;
  static const int maxDepth = 32;
  static const int maxNodes = 512;
  static const int maxTextLength = 4096;
  static const int maxChildren = 100;

  final GuxNode root;

  /// Parses JSON and validates all limits before returning a renderable tree.
  ///
  /// The only input entry point takes JSON text, so both the byte limit and the
  /// structural nesting preflight apply to every document.
  static GuxPresentationDocument parse(String source) {
    if (source.length > maxInputBytes ||
        utf8.encode(source).length > maxInputBytes) {
      throw const GuxFormatException(
        r'$',
        'Input exceeds 262144 UTF-8 bytes',
      );
    }
    _checkStructuralNesting(source);
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const GuxFormatException(r'$', 'Invalid JSON');
    }
    final document = _object(decoded, r'$');
    _fields(document, const {'schemaVersion', 'root'}, r'$');
    final version = _required(document, 'schemaVersion', r'$');
    if (version is! num || !version.isFinite || version != schemaVersion) {
      throw const GuxFormatException(
        r'$.schemaVersion',
        'Unsupported schema version',
      );
    }
    final parser = _NodeParser();
    final result = GuxPresentationDocument._(
      parser.parse(_required(document, 'root', r'$'), r'$.root', 1),
    );
    // Normalization adds explicit defaults and can expand compact numbers.
    // Reject an expanded document here rather than returning a value whose own
    // serialized form could not subsequently be parsed under the byte limit.
    if (utf8.encode(result.toJsonString()).length > maxInputBytes) {
      throw const GuxFormatException(
        r'$',
        'Normalized JSON exceeds 262144 UTF-8 bytes',
      );
    }
    return result;
  }

  /// Returns fresh JSON-compatible data in a stable key order.
  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'root': root.toJson(),
  };

  /// Serializes the normalized document in a stable key order.
  String toJsonString() => jsonEncode(toJson());
}

/// Base class for validated presentation nodes.
sealed class GuxNode {
  const GuxNode._();

  /// Produces a fresh JSON-compatible representation.
  Map<String, Object?> toJson();
}

final class GuxTextNode extends GuxNode {
  const GuxTextNode._(this.text) : super._();
  final String text;

  @override
  Map<String, Object?> toJson() => {'type': 'text', 'text': text};
}

final class GuxColumnNode extends GuxNode {
  GuxColumnNode._(List<GuxNode> children, this.spacing)
    : children = List.unmodifiable(children),
      super._();
  final List<GuxNode> children;
  final double spacing;

  @override
  Map<String, Object?> toJson() => {
    'type': 'column',
    'children': children.map((child) => child.toJson()).toList(),
    'spacing': spacing,
  };
}

final class GuxSummaryLinesNode extends GuxNode {
  const GuxSummaryLinesNode._(
    this.primary,
    this.secondary,
    this.tertiary,
    this.spacing,
  ) : super._();
  final String primary;
  final String secondary;
  final String tertiary;
  final double spacing;

  @override
  Map<String, Object?> toJson() => {
    'type': 'summaryLines',
    'primary': primary,
    'secondary': secondary,
    'tertiary': tertiary,
    'spacing': spacing,
  };
}

final class GuxWorkspaceNode extends GuxNode {
  const GuxWorkspaceNode._({
    required this.body,
    required this.topBar,
    required this.bottomBar,
    required this.sideBar,
    required this.topBarHeight,
    required this.bottomBarHeight,
    required this.sideBarWidth,
  }) : super._();
  final GuxNode body;
  final GuxNode? topBar;
  final GuxNode? bottomBar;
  final GuxNode? sideBar;
  final double topBarHeight;
  final double bottomBarHeight;
  final double sideBarWidth;

  @override
  Map<String, Object?> toJson() => {
    'type': 'workspace',
    'body': body.toJson(),
    if (topBar != null) 'topBar': topBar!.toJson(),
    if (bottomBar != null) 'bottomBar': bottomBar!.toJson(),
    if (sideBar != null) 'sideBar': sideBar!.toJson(),
    'topBarHeight': topBarHeight,
    'bottomBarHeight': bottomBarHeight,
    'sideBarWidth': sideBarWidth,
  };
}

class _NodeParser {
  int _count = 0;

  GuxNode parse(Object? value, String path, int depth) {
    if (depth > GuxPresentationDocument.maxDepth) {
      throw GuxFormatException(path, 'Node depth exceeds 32');
    }
    if (++_count > GuxPresentationDocument.maxNodes) {
      throw GuxFormatException(path, 'Node count exceeds 512');
    }
    final object = _object(value, path);
    final type = _required(object, 'type', path);
    if (type is! String) {
      throw GuxFormatException('$path.type', 'Expected a string');
    }
    switch (type) {
      case 'text':
        _fields(object, const {'type', 'text'}, path);
        return GuxTextNode._(_text(object, 'text', path));
      case 'column':
        _fields(object, const {'type', 'children', 'spacing'}, path);
        final childrenValue = _required(object, 'children', path);
        if (childrenValue is! List) {
          throw GuxFormatException('$path.children', 'Expected an array');
        }
        if (childrenValue.length > GuxPresentationDocument.maxChildren) {
          throw GuxFormatException(
            '$path.children',
            'Array exceeds 100 items',
          );
        }
        return GuxColumnNode._([
          for (var i = 0; i < childrenValue.length; i++)
            parse(childrenValue[i], '$path.children[$i]', depth + 1),
        ], _number(object, 'spacing', path, 0, 200));
      case 'summaryLines':
        _fields(object, const {
          'type',
          'primary',
          'secondary',
          'tertiary',
          'spacing',
        }, path);
        return GuxSummaryLinesNode._(
          _text(object, 'primary', path),
          _text(object, 'secondary', path),
          _text(object, 'tertiary', path),
          _number(object, 'spacing', path, 4, 200),
        );
      case 'workspace':
        _fields(object, const {
          'type',
          'body',
          'topBar',
          'bottomBar',
          'sideBar',
          'topBarHeight',
          'bottomBarHeight',
          'sideBarWidth',
        }, path);
        GuxNode? optionalNode(String key) => object.containsKey(key)
            ? parse(object[key], '$path.$key', depth + 1)
            : null;
        return GuxWorkspaceNode._(
          body: parse(_required(object, 'body', path), '$path.body', depth + 1),
          topBar: optionalNode('topBar'),
          bottomBar: optionalNode('bottomBar'),
          sideBar: optionalNode('sideBar'),
          topBarHeight: _number(object, 'topBarHeight', path, 44, 1000),
          bottomBarHeight: _number(object, 'bottomBarHeight', path, 26, 1000),
          sideBarWidth: _number(object, 'sideBarWidth', path, 44, 1000),
        );
      default:
        throw GuxFormatException('$path.type', 'Unknown widget type');
    }
  }
}

Map<String, dynamic> _object(Object? value, String path) {
  if (value is! Map<String, dynamic>) {
    throw GuxFormatException(path, 'Expected an object');
  }
  return value;
}

Object? _required(Map<String, dynamic> object, String key, String path) {
  if (!object.containsKey(key)) {
    throw GuxFormatException('$path.$key', 'Required field is missing');
  }
  return object[key];
}

void _fields(Map<String, dynamic> object, Set<String> allowed, String path) {
  final unknown = object.keys.where((key) => !allowed.contains(key)).toList()
    ..sort();
  if (unknown.isNotEmpty) {
    // Bracket notation keeps arbitrary input keys unambiguous.
    throw GuxFormatException(
      '$path[${jsonEncode(unknown.first)}]',
      'Unknown field',
    );
  }
}

String _text(Map<String, dynamic> object, String key, String path) {
  final value = _required(object, key, path);
  if (value is! String) {
    throw GuxFormatException('$path.$key', 'Expected a string');
  }
  if (value.runes.length > GuxPresentationDocument.maxTextLength) {
    throw GuxFormatException('$path.$key', 'String exceeds 4096 characters');
  }
  return value;
}

double _number(
  Map<String, dynamic> object,
  String key,
  String path,
  double fallback,
  double max,
) {
  if (!object.containsKey(key)) return fallback;
  final value = object[key];
  if (value is! num || !value.isFinite || value < 0 || value > max) {
    throw GuxFormatException(
      '$path.$key',
      'Expected a finite number between 0 and ${max.toInt()}',
    );
  }
  return value.toDouble();
}

// Bound structural depth before calling jsonDecode, including for malformed or
// unknown structures. Quotes and escaped quotes cannot increase the depth.
void _checkStructuralNesting(String source) {
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (final code in source.codeUnits) {
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (code == 0x5c) {
        escaped = true;
      } else if (code == 0x22) {
        inString = false;
      }
    } else if (code == 0x22) {
      inString = true;
    } else if (code == 0x7b || code == 0x5b) {
      if (++depth > GuxPresentationDocument.maxDepth * 2 + 2) {
        throw const GuxFormatException(r'$', 'JSON nesting exceeds limit');
      }
    } else if (code == 0x7d || code == 0x5d) {
      depth--;
    }
  }
}
