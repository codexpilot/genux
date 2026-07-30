import 'dart:collection';

enum GenuxViewKind { view, partial }

extension on GenuxViewKind {
  String get wireName => name;
}

final class GenuxViewReference {
  const GenuxViewReference({
    required this.id,
    required this.code,
    required this.revision,
    required this.kind,
  });

  factory GenuxViewReference.fromJson(Map<String, Object?> json) {
    _expectOnlyKeys(json, const {'id', 'code', 'revision', 'kind'}, 'view');
    final kindName = _requiredString(json, 'kind', 'view');
    final kind = GenuxViewKind.values.where((value) => value.name == kindName);
    if (kind.isEmpty) {
      throw FormatException('view.kind is not supported: $kindName.');
    }

    return GenuxViewReference(
      id: _requiredString(json, 'id', 'view'),
      code: _requiredString(json, 'code', 'view'),
      revision: _requiredInt(json, 'revision', 'view'),
      kind: kind.single,
    );
  }

  final String id;
  final String code;
  final int revision;
  final GenuxViewKind kind;

  Map<String, Object?> toJson() => {
    'id': id,
    'code': code,
    'revision': revision,
    'kind': kind.wireName,
  };
}

final class GenuxCatalogReference {
  const GenuxCatalogReference({
    required this.id,
    required this.version,
    required this.checksum,
  });

  factory GenuxCatalogReference.fromJson(Map<String, Object?> json) {
    _expectOnlyKeys(json, const {'id', 'version', 'checksum'}, 'catalog');
    return GenuxCatalogReference(
      id: _requiredString(json, 'id', 'catalog'),
      version: _requiredInt(json, 'version', 'catalog'),
      checksum: _requiredString(json, 'checksum', 'catalog'),
    );
  }

  final String id;
  final int version;
  final String checksum;

  Map<String, Object?> toJson() => {
    'id': id,
    'version': version,
    'checksum': checksum,
  };
}

final class GenuxBinding {
  const GenuxBinding({
    this.source,
    required this.path,
    this.fallback,
    this.hasFallback = false,
  });

  factory GenuxBinding.fromJson(Object? json, String location) {
    if (json is String) {
      // Shorthand: plain string is a state binding
      return GenuxBinding(path: json);
    }
    final object = _asObjectMap(json, location);
    _expectOnlyKeys(object, const {'source', 'path', 'fallback'}, location);

    final sourceName = object['source'] as String?;
    return GenuxBinding(
      source: sourceName,
      path: _requiredString(object, 'path', location),
      fallback: _freezeJson(object['fallback']),
      hasFallback: object.containsKey('fallback'),
    );
  }

  /// Binding source: 'state', 'item', or 'event'. Null defaults to 'state'.
  final String? source;

  final String path;
  final Object? fallback;
  final bool hasFallback;

  Object toJson() {
    if (source == null && !hasFallback) {
      return path;
    }
    return <String, Object?>{
      'source': source,
      'path': path,
      if (hasFallback) 'fallback': fallback,
    }..removeWhere((key, value) => value == null);
  }
}

final class GenuxNode {
  GenuxNode({
    required this.id,
    required this.component,
    this.componentId,
    required this.version,
    Map<String, Object?> props = const {},
    Map<String, GenuxBinding> bindings = const {},
    Map<String, String> events = const {},
    Map<String, List<String>> slots = const {},
  }) : props = UnmodifiableMapView(_freezeObject(props)),
       bindings = UnmodifiableMapView(Map.of(bindings)),
       events = UnmodifiableMapView(Map.of(events)),
       slots = UnmodifiableMapView({
         for (final entry in slots.entries)
           entry.key: List.unmodifiable(entry.value),
       });

  factory GenuxNode.fromJson(Map<String, Object?> json, int index) {
    final location = 'nodes[$index]';
    _expectOnlyKeys(json, const {
      'id',
      'component',
      'componentId',
      'version',
      'props',
      'bind',
      'events',
      'slots',
    }, location);

    final rawBindings = _optionalObjectMap(json, 'bind', location);
    final rawEvents = _optionalObjectMap(json, 'events', location);
    final rawSlots = _optionalObjectMap(json, 'slots', location);

    final bindings = <String, GenuxBinding>{};
    for (final entry in rawBindings.entries) {
      bindings[entry.key] = GenuxBinding.fromJson(
        entry.value,
        '$location.bind.${entry.key}',
      );
    }

    final events = <String, String>{};
    for (final entry in rawEvents.entries) {
      if (entry.value is! String) {
        throw FormatException(
          '$location.events.${entry.key} must be a string.',
        );
      }
      events[entry.key] = entry.value! as String;
    }

    final slots = <String, List<String>>{};
    for (final entry in rawSlots.entries) {
      if (entry.value is! List) {
        throw FormatException('$location.slots.${entry.key} must be a list.');
      }
      final children = <String>[];
      for (final child in entry.value! as List<Object?>) {
        if (child is! String) {
          throw FormatException(
            '$location.slots.${entry.key} entries must be strings.',
          );
        }
        children.add(child);
      }
      slots[entry.key] = children;
    }

    // Read componentId if present
    final componentId = json['componentId'];
    if (componentId != null && componentId is! int) {
      throw FormatException('$location.componentId must be an integer.');
    }

    return GenuxNode(
      id: _requiredString(json, 'id', location),
      component: _requiredString(json, 'component', location),
      componentId: componentId as int?,
      version: _requiredInt(json, 'version', location),
      props: _optionalObjectMap(json, 'props', location),
      bindings: bindings,
      events: events,
      slots: slots,
    );
  }

  final String id;
  final String component;
  final int? componentId; // Numeric registry ID (preferred)
  final int version;
  final Map<String, Object?> props;
  final Map<String, GenuxBinding> bindings;
  final Map<String, String> events;
  final Map<String, List<String>> slots;

  Map<String, Object?> toJson() => {
    'id': id,
    'component': component,
    if (componentId != null) 'componentId': componentId,
    'version': version,
    if (props.isNotEmpty) 'props': props,
    if (bindings.isNotEmpty)
      'bind': {
        for (final entry in bindings.entries) entry.key: entry.value.toJson(),
      },
    if (events.isNotEmpty) 'events': events,
    if (slots.isNotEmpty) 'slots': slots,
  };
}

final class GenuxAction {
  GenuxAction({required this.capability, Map<String, Object?> args = const {}})
    : args = UnmodifiableMapView(_freezeObject(args));

  factory GenuxAction.fromJson(Map<String, Object?> json, String actionId) {
    final location = 'actions.$actionId';
    _expectOnlyKeys(json, const {'capability', 'args'}, location);
    return GenuxAction(
      capability: _requiredString(json, 'capability', location),
      args: _optionalObjectMap(json, 'args', location),
    );
  }

  final String capability;
  final Map<String, Object?> args;

  Map<String, Object?> toJson() => {
    'capability': capability,
    if (args.isNotEmpty) 'args': args,
  };
}

final class GenuxDocument {
  GenuxDocument({
    required this.schema,
    required this.view,
    required this.catalog,
    required this.root,
    required Iterable<GenuxNode> nodes,
    Map<String, Object?> state = const {},
    Map<String, GenuxAction> actions = const {},
  }) : nodes = UnmodifiableMapView({for (final node in nodes) node.id: node}),
       state = UnmodifiableMapView(_freezeObject(state)),
       actions = UnmodifiableMapView(Map.of(actions)) {
    if (this.nodes.length != nodes.length) {
      throw const FormatException('Node IDs must be unique.');
    }
  }

  factory GenuxDocument.fromJson(Map<String, Object?> json) {
    _expectOnlyKeys(json, const {
      'schema',
      'view',
      'catalog',
      'root',
      'nodes',
      'state',
      'actions',
    }, 'document');

    final rawNodes = json['nodes'];
    if (rawNodes is! List) {
      throw const FormatException('document.nodes must be a list.');
    }
    final nodes = <GenuxNode>[];
    for (var index = 0; index < rawNodes.length; index += 1) {
      nodes.add(
        GenuxNode.fromJson(
          _asObjectMap(rawNodes[index], 'nodes[$index]'),
          index,
        ),
      );
    }

    final rawActions = _optionalObjectMap(json, 'actions', 'document');
    final actions = <String, GenuxAction>{};
    for (final entry in rawActions.entries) {
      actions[entry.key] = GenuxAction.fromJson(
        _asObjectMap(entry.value, 'actions.${entry.key}'),
        entry.key,
      );
    }

    return GenuxDocument(
      schema: _requiredString(json, 'schema', 'document'),
      view: GenuxViewReference.fromJson(
        _asObjectMap(json['view'], 'document.view'),
      ),
      catalog: GenuxCatalogReference.fromJson(
        _asObjectMap(json['catalog'], 'document.catalog'),
      ),
      root: _requiredString(json, 'root', 'document'),
      nodes: nodes,
      state: _optionalObjectMap(json, 'state', 'document'),
      actions: actions,
    );
  }

  static const supportedSchema = 'aix.genux/1.0';

  final String schema;
  final GenuxViewReference view;
  final GenuxCatalogReference catalog;
  final String root;
  final Map<String, GenuxNode> nodes;
  final Map<String, Object?> state;
  final Map<String, GenuxAction> actions;

  Map<String, Object?> toJson() => {
    'schema': schema,
    'view': view.toJson(),
    'catalog': catalog.toJson(),
    'root': root,
    'nodes': [for (final node in nodes.values) node.toJson()],
    'state': state,
    if (actions.isNotEmpty)
      'actions': {
        for (final entry in actions.entries) entry.key: entry.value.toJson(),
      },
  };
}

Map<String, Object?> _optionalObjectMap(
  Map<String, Object?> parent,
  String key,
  String location,
) {
  final value = parent[key];
  if (value == null) {
    return const {};
  }
  return _asObjectMap(value, '$location.$key');
}

Map<String, Object?> _asObjectMap(Object? value, String location) {
  if (value is! Map) {
    throw FormatException('$location must be an object.');
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      throw FormatException('$location keys must be strings.');
    }
    result[key] = entry.value;
  }
  return result;
}

String _requiredString(Map<String, Object?> json, String key, String location) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('$location.$key must be a non-empty string.');
  }
  return value;
}

int _requiredInt(Map<String, Object?> json, String key, String location) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('$location.$key must be an integer.');
  }
  return value;
}

void _expectOnlyKeys(
  Map<String, Object?> json,
  Set<String> allowed,
  String location,
) {
  for (final key in json.keys) {
    if (!allowed.contains(key)) {
      throw FormatException('Unknown field $location.$key.');
    }
  }
}

Map<String, Object?> _freezeObject(Map<String, Object?> value) => {
  for (final entry in value.entries) entry.key: _freezeJson(entry.value),
};

Object? _freezeJson(Object? value, {int depth = 0, Set<Object>? ancestors}) {
  if (depth > 128) {
    throw const FormatException('JSON value nesting exceeds the hard limit.');
  }
  if (value is List) {
    final seen = ancestors ?? Set<Object>.identity();
    if (!seen.add(value)) {
      throw const FormatException('JSON values cannot contain cycles.');
    }
    final result = List<Object?>.unmodifiable(
      value.map((item) => _freezeJson(item, depth: depth + 1, ancestors: seen)),
    );
    seen.remove(value);
    return result;
  }
  if (value is Map) {
    final seen = ancestors ?? Set<Object>.identity();
    if (!seen.add(value)) {
      throw const FormatException('JSON values cannot contain cycles.');
    }
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw const FormatException('JSON object keys must be strings.');
      }
      result[key] = _freezeJson(entry.value, depth: depth + 1, ancestors: seen);
    }
    seen.remove(value);
    return Map<String, Object?>.unmodifiable(result);
  }
  return value;
}
