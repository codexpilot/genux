import 'dart:collection';
import 'dart:convert';

import '../catalog/capability.dart';
import '../catalog/catalog.dart';
import '../model/document.dart';
import '../model/json_pointer.dart';
import '../validation/document_validator.dart';

sealed class GenuxCompileResult {
  const GenuxCompileResult();
}

final class GenuxCompileSuccess extends GenuxCompileResult {
  const GenuxCompileSuccess(this.document);

  final GenuxCompiledDocument document;
}

final class GenuxCompileFailure extends GenuxCompileResult {
  GenuxCompileFailure(Iterable<GenuxDiagnostic> diagnostics)
    : diagnostics = List.unmodifiable(diagnostics);

  final List<GenuxDiagnostic> diagnostics;
}

sealed class GenuxCompiledValue {
  const GenuxCompiledValue();

  Object? resolve(Map<String, Object?> state);
}

final class GenuxLiteralValue extends GenuxCompiledValue {
  const GenuxLiteralValue(this.value);

  final Object? value;

  @override
  Object? resolve(Map<String, Object?> state) => value;
}

final class GenuxListValue extends GenuxCompiledValue {
  GenuxListValue(Iterable<GenuxCompiledValue> items)
    : items = List.unmodifiable(items);

  final List<GenuxCompiledValue> items;

  @override
  Object? resolve(Map<String, Object?> state) =>
      List<Object?>.unmodifiable(items.map((item) => item.resolve(state)));
}

final class GenuxObjectValue extends GenuxCompiledValue {
  GenuxObjectValue(Map<String, GenuxCompiledValue> fields)
    : fields = UnmodifiableMapView(fields);

  final Map<String, GenuxCompiledValue> fields;

  @override
  Object? resolve(Map<String, Object?> state) =>
      Map<String, Object?>.unmodifiable({
        for (final entry in fields.entries)
          entry.key: entry.value.resolve(state),
      });
}

final class GenuxStateValue extends GenuxCompiledValue {
  const GenuxStateValue({
    required this.pointer,
    this.fallback,
    this.hasFallback = false,
  });

  final GenuxJsonPointer pointer;
  final Object? fallback;
  final bool hasFallback;

  @override
  Object? resolve(Map<String, Object?> state) {
    final result = pointer.read(state);
    if (result.exists) {
      return result.value;
    }
    if (hasFallback) {
      return fallback;
    }
    throw StateError('Required state path ${pointer.source} is missing.');
  }
}

final class GenuxCompiledBinding {
  const GenuxCompiledBinding({
    required this.name,
    required this.definition,
    required this.pointer,
    this.fallback,
    this.hasFallback = false,
  });

  final String name;
  final GenuxChannelDefinition definition;
  final GenuxJsonPointer pointer;
  final Object? fallback;
  final bool hasFallback;

  Object? read(Map<String, Object?> state) {
    final result = pointer.read(state);
    if (result.exists) {
      return result.value;
    }
    if (hasFallback) {
      return fallback;
    }
    throw StateError('Required state path ${pointer.source} is missing.');
  }

  bool get isWritable => definition.direction == GenuxChannelDirection.state;
}

final class GenuxCompiledAction {
  GenuxCompiledAction({
    required this.id,
    required this.definition,
    required Map<String, GenuxCompiledValue> args,
  }) : args = UnmodifiableMapView(args);

  final String id;
  final GenuxCapabilityDefinition definition;
  String get capability => definition.code;
  final Map<String, GenuxCompiledValue> args;

  Map<String, Object?> resolveArgs(Map<String, Object?> state) =>
      Map<String, Object?>.unmodifiable({
        for (final entry in args.entries) entry.key: entry.value.resolve(state),
      });
}

final class GenuxCompiledEvent {
  const GenuxCompiledEvent({
    required this.name,
    required this.definition,
    required this.action,
  });

  final String name;
  final GenuxEventDefinition definition;
  final GenuxCompiledAction action;
}

final class GenuxCompiledSlot {
  GenuxCompiledSlot({
    required this.name,
    required this.definition,
    required Iterable<String> childIds,
  }) : childIds = List.unmodifiable(childIds);

  final String name;
  final GenuxSlotDefinition definition;
  final List<String> childIds;
}

final class GenuxCompiledNode {
  GenuxCompiledNode({
    required this.id,
    required this.component,
    required Map<String, Object?> properties,
    required Map<String, Object?> literalInputs,
    required Map<String, GenuxCompiledBinding> bindings,
    required Map<String, GenuxCompiledEvent> events,
    required Map<String, GenuxCompiledSlot> slots,
  }) : properties = UnmodifiableMapView(properties),
       literalInputs = UnmodifiableMapView(literalInputs),
       bindings = UnmodifiableMapView(bindings),
       events = UnmodifiableMapView(events),
       slots = UnmodifiableMapView(slots);

  final String id;
  final GenuxComponentDefinition component;
  final Map<String, Object?> properties;
  final Map<String, Object?> literalInputs;
  final Map<String, GenuxCompiledBinding> bindings;
  final Map<String, GenuxCompiledEvent> events;
  final Map<String, GenuxCompiledSlot> slots;
}

final class GenuxCompiledDocument {
  GenuxCompiledDocument._({
    required this.view,
    required this.catalog,
    required this.rootId,
    required Map<String, GenuxCompiledNode> nodes,
    required Map<String, Object?> state,
    required Map<String, GenuxCompiledAction> actions,
  }) : nodes = UnmodifiableMapView(nodes),
       state = UnmodifiableMapView(state),
       actions = UnmodifiableMapView(actions);

  final GenuxViewReference view;
  final GenuxCatalogReference catalog;
  final String rootId;
  final Map<String, GenuxCompiledNode> nodes;
  final Map<String, Object?> state;
  final Map<String, GenuxCompiledAction> actions;

  GenuxCompiledNode get root => nodes[rootId]!;
}

final class GenuxDocumentCompiler {
  const GenuxDocumentCompiler({
    required this.catalog,
    required this.capabilities,
    this.validator = const GenuxDocumentValidator(),
  });

  final GenuxCatalog catalog;
  final GenuxCapabilityRegistry capabilities;
  final GenuxDocumentValidator validator;

  GenuxCompileResult compileJson(String source) {
    final byteLength = utf8.encode(source).length;
    if (byteLength > validator.limits.maxDocumentBytes) {
      return GenuxCompileFailure([
        GenuxDiagnostic(
          code: 'limit.documentBytes',
          message:
              'Document is $byteLength bytes; limit is '
              '${validator.limits.maxDocumentBytes}.',
          location: '/',
        ),
      ]);
    }

    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (exception) {
      return _parseFailure(exception.message.toString());
    }
    return compileObject(decoded);
  }

  GenuxCompileResult compileObject(Object? source) {
    try {
      final draft = GenuxDocument.fromJson(_stringMap(source));
      final validation = validator.validate(
        draft,
        catalog,
        capabilities: capabilities,
      );
      if (!validation.isValid) {
        return GenuxCompileFailure(validation.diagnostics);
      }
      return GenuxCompileSuccess(_compile(draft));
    } on FormatException catch (exception) {
      return _parseFailure(exception.message.toString());
    } on TypeError catch (exception) {
      return _parseFailure(exception.toString());
    } on JsonUnsupportedObjectError catch (exception) {
      return _parseFailure(exception.toString());
    }
  }

  GenuxCompileFailure _parseFailure(String message) => GenuxCompileFailure([
    GenuxDiagnostic(code: 'syntax.invalid', message: message, location: '/'),
  ]);

  GenuxCompiledDocument _compile(GenuxDocument draft) {
    final compiledActions = <String, GenuxCompiledAction>{};
    for (final action in draft.actions.entries) {
      compiledActions[action.key] = GenuxCompiledAction(
        id: action.key,
        definition: capabilities.capability(action.value.capability)!,
        args: {
          for (final arg in action.value.args.entries)
            arg.key: _compileValue(arg.value),
        },
      );
    }

    final compiledNodes = <String, GenuxCompiledNode>{};
    for (final node in draft.nodes.values) {
      final component = catalog.component(node.component)!;
      final properties = <String, Object?>{};
      final literalInputs = <String, Object?>{};
      for (final prop in node.props.entries) {
        if (component.properties.containsKey(prop.key)) {
          properties[prop.key] = _freezeJson(prop.value);
        } else {
          literalInputs[prop.key] = _freezeJson(prop.value);
        }
      }

      compiledNodes[node.id] = GenuxCompiledNode(
        id: node.id,
        component: component,
        properties: properties,
        literalInputs: literalInputs,
        bindings: {
          for (final binding in node.bindings.entries)
            binding.key: GenuxCompiledBinding(
              name: binding.key,
              definition: component.channels[binding.key]!,
              pointer: GenuxJsonPointer.parse(binding.value.path),
              fallback: _freezeJson(binding.value.fallback),
              hasFallback: binding.value.hasFallback,
            ),
        },
        events: {
          for (final event in node.events.entries)
            event.key: GenuxCompiledEvent(
              name: event.key,
              definition: component.events[event.key]!,
              action: compiledActions[event.value]!,
            ),
        },
        slots: {
          for (final slot in node.slots.entries)
            slot.key: GenuxCompiledSlot(
              name: slot.key,
              definition: component.slots[slot.key]!,
              childIds: slot.value,
            ),
        },
      );
    }

    return GenuxCompiledDocument._(
      view: draft.view,
      catalog: draft.catalog,
      rootId: draft.root,
      nodes: compiledNodes,
      state: _freezeObject(draft.state),
      actions: compiledActions,
    );
  }
}

GenuxCompiledValue _compileValue(Object? value) {
  if (value is List) {
    return GenuxListValue(value.map(_compileValue));
  }
  if (value is Map) {
    if (value.containsKey(r'$bind')) {
      return GenuxStateValue(
        pointer: GenuxJsonPointer.parse(value[r'$bind']! as String),
        fallback: _freezeJson(value['fallback']),
        hasFallback: value.containsKey('fallback'),
      );
    }
    return GenuxObjectValue({
      for (final entry in value.entries)
        entry.key! as String: _compileValue(entry.value),
    });
  }
  return GenuxLiteralValue(value);
}

Map<String, Object?> _stringMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('Document root must be an object.');
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      throw const FormatException('Document object keys must be strings.');
    }
    result[key] = entry.value;
  }
  return result;
}

Map<String, Object?> _freezeObject(Map<String, Object?> value) =>
    Map<String, Object?>.unmodifiable({
      for (final entry in value.entries) entry.key: _freezeJson(entry.value),
    });

Object? _freezeJson(Object? value) {
  if (value is List) {
    return List<Object?>.unmodifiable(value.map(_freezeJson));
  }
  if (value is Map) {
    return Map<String, Object?>.unmodifiable({
      for (final entry in value.entries)
        entry.key! as String: _freezeJson(entry.value),
    });
  }
  return value;
}
