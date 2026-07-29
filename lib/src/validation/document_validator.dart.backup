import 'dart:convert';

import '../catalog/capability.dart';
import '../catalog/catalog.dart';
import '../model/document.dart';
import '../model/json_pointer.dart';

enum GenuxDiagnosticSeverity { error, warning }

final class GenuxDiagnostic {
  const GenuxDiagnostic({
    required this.code,
    required this.message,
    required this.location,
    this.severity = GenuxDiagnosticSeverity.error,
  });

  final String code;
  final String message;
  final String location;
  final GenuxDiagnosticSeverity severity;

  @override
  String toString() => '${severity.name}: $code at $location: $message';
}

final class GenuxValidationResult {
  GenuxValidationResult(Iterable<GenuxDiagnostic> diagnostics)
    : diagnostics = List.unmodifiable(diagnostics);

  final List<GenuxDiagnostic> diagnostics;

  bool get isValid => diagnostics.every(
    (diagnostic) => diagnostic.severity != GenuxDiagnosticSeverity.error,
  );
}

final class GenuxValidationLimits {
  const GenuxValidationLimits({
    this.maxDocumentBytes = 1024 * 1024,
    this.maxNodes = 2000,
    this.maxActions = 256,
    this.maxDepth = 64,
    this.maxChildrenPerSlot = 1000,
    this.maxValueDepth = 64,
    this.maxCollectionItems = 10000,
    this.maxStringLength = 65536,
  });

  final int maxDocumentBytes;
  final int maxNodes;
  final int maxActions;
  final int maxDepth;
  final int maxChildrenPerSlot;
  final int maxValueDepth;
  final int maxCollectionItems;
  final int maxStringLength;
}

final class GenuxDocumentValidator {
  const GenuxDocumentValidator({this.limits = const GenuxValidationLimits()});

  final GenuxValidationLimits limits;

  GenuxValidationResult validate(
    GenuxDocument document,
    GenuxCatalog catalog, {
    required GenuxCapabilityRegistry capabilities,
  }) {
    final diagnostics = <GenuxDiagnostic>[];

    void error(String code, String message, String location) {
      diagnostics.add(
        GenuxDiagnostic(code: code, message: message, location: location),
      );
    }

    if (document.schema != GenuxDocument.supportedSchema) {
      error(
        'schema.unsupported',
        'Expected ${GenuxDocument.supportedSchema}, got ${document.schema}.',
        '/schema',
      );
    }
    if (!_validIdentifier(document.view.id)) {
      error(
        'view.invalidId',
        'View ID must be a 1-128 character safe identifier.',
        '/view/id',
      );
    }
    if (!_validIdentifier(document.view.code)) {
      error(
        'view.invalidCode',
        'View code must be a 1-128 character safe identifier.',
        '/view/code',
      );
    }
    if (document.view.revision < 1) {
      error(
        'view.invalidRevision',
        'View revision must be positive.',
        '/view/revision',
      );
    }
    if (!_validIdentifier(document.root)) {
      error(
        'graph.invalidRootId',
        'Root ID must be a 1-128 character safe identifier.',
        '/root',
      );
    }
    if (document.catalog.version < 1) {
      error(
        'catalog.invalidVersion',
        'Catalog release version must be positive.',
        '/catalog/version',
      );
    }
    if (document.catalog.id != catalog.id ||
        document.catalog.version > catalog.version) {
      error(
        'catalog.mismatch',
        'Document requires ${document.catalog.id}@${document.catalog.version}; '
            'runtime supplied ${catalog.id}@${catalog.version}.',
        '/catalog',
      );
    }
    if (document.catalog.version == catalog.version &&
        document.catalog.checksum != catalog.checksum) {
      error(
        'catalog.checksumMismatch',
        'The catalog checksum does not match the runtime catalog.',
        '/catalog/checksum',
      );
    }

    final valuesAreSafe = _validateJsonTree(
      document.toJson(),
      '/',
      0,
      limits,
      diagnostics,
    );
    if (!valuesAreSafe) {
      return GenuxValidationResult(diagnostics);
    }

    try {
      final encodedBytes = utf8.encode(jsonEncode(document.toJson())).length;
      if (encodedBytes > limits.maxDocumentBytes) {
        error(
          'limit.documentBytes',
          'Document is $encodedBytes bytes; limit is '
              '${limits.maxDocumentBytes}.',
          '/',
        );
      }
    } on JsonUnsupportedObjectError catch (exception) {
      error('syntax.nonJsonValue', exception.toString(), '/');
    }
    if (document.nodes.length > limits.maxNodes) {
      error(
        'limit.nodes',
        'Document has ${document.nodes.length} nodes; limit is ${limits.maxNodes}.',
        '/nodes',
      );
    }
    if (document.actions.length > limits.maxActions) {
      error(
        'limit.actions',
        'Document has ${document.actions.length} actions; '
            'limit is ${limits.maxActions}.',
        '/actions',
      );
    }

    if (!document.nodes.containsKey(document.root)) {
      error(
        'graph.missingRoot',
        'Root node ${document.root} does not exist.',
        '/root',
      );
    }

    final parents = <String, int>{
      for (final nodeId in document.nodes.keys) nodeId: 0,
    };
    final adjacency = <String, List<String>>{
      for (final nodeId in document.nodes.keys) nodeId: <String>[],
    };

    for (final node in document.nodes.values) {
      final location = '/nodes/${_escapePointerSegment(node.id)}';
      if (!_validIdentifier(node.id)) {
        error(
          'node.invalidId',
          'Node ID must be a 1-128 character safe identifier.',
          '$location/id',
        );
      }
      if (node.version < 1) {
        error(
          'component.invalidVersion',
          'Component version must be positive.',
          '$location/version',
        );
      }
      final component = catalog.component(node.component);
      if (component == null) {
        error(
          'component.unknown',
          'Component ${node.component} is not in the catalog.',
          '$location/component',
        );
        continue;
      }
      if (node.version != component.version) {
        error(
          'component.versionMismatch',
          'Node requires ${node.component}@${node.version}; catalog provides '
              '${component.code}@${component.version}.',
          '$location/version',
        );
      }

      for (final prop in node.props.entries) {
        final propertyDefinition = component.properties[prop.key];
        final channelDefinition = component.channels[prop.key];
        if (propertyDefinition != null) {
          if (!propertyDefinition.type.accepts(prop.value)) {
            error(
              'property.type',
              'Expected ${propertyDefinition.type.displayName}.',
              '$location/props/${prop.key}',
            );
          } else if (propertyDefinition.constraint.violation(prop.value)
              case final violation?) {
            error(
              'property.constraint',
              violation,
              '$location/props/${prop.key}',
            );
          }
          continue;
        }
        if (channelDefinition != null && channelDefinition.acceptsLiteral) {
          if (node.bindings.containsKey(prop.key)) {
            error(
              'channel.multipleSources',
              'An input channel cannot have both a literal and a binding.',
              '$location/props/${prop.key}',
            );
          }
          if (!channelDefinition.type.accepts(prop.value)) {
            error(
              'channel.literalType',
              'Expected ${channelDefinition.type.displayName}.',
              '$location/props/${prop.key}',
            );
          } else if (channelDefinition.constraint.violation(prop.value)
              case final violation?) {
            error(
              'channel.constraint',
              violation,
              '$location/props/${prop.key}',
            );
          }
          continue;
        }
        error(
          'property.unknown',
          'Property or literal input ${prop.key} is not supported.',
          '$location/props/${prop.key}',
        );
      }

      for (final property in component.properties.entries) {
        if (property.value.required && !node.props.containsKey(property.key)) {
          error(
            'property.required',
            'Required property ${property.key} is missing.',
            '$location/props',
          );
        }
      }

      // Bindings are validated in a second pass after context is established

      for (final channel in component.channels.entries) {
        final isAssigned =
            node.bindings.containsKey(channel.key) ||
            (channel.value.acceptsLiteral &&
                node.props.containsKey(channel.key));
        if (channel.value.required && !isAssigned) {
          error(
            'channel.required',
            'Required channel ${channel.key} is not assigned.',
            '$location/bind',
          );
        }
      }

      for (final event in node.events.entries) {
        if (!component.events.containsKey(event.key)) {
          error(
            'event.unknown',
            'Event ${event.key} is not supported by ${component.code}.',
            '$location/events/${event.key}',
          );
        }
        if (!document.actions.containsKey(event.value)) {
          error(
            'event.missingAction',
            'Action ${event.value} does not exist.',
            '$location/events/${event.key}',
          );
        }
      }

      for (final slot in node.slots.entries) {
        final definition = component.slots[slot.key];
        if (definition == null) {
          error(
            'slot.unknown',
            'Slot ${slot.key} is not supported by ${component.code}.',
            '$location/slots/${slot.key}',
          );
          continue;
        }
        if (slot.value.length < definition.minChildren ||
            (definition.maxChildren != null &&
                slot.value.length > definition.maxChildren!)) {
          error(
            'slot.cardinality',
            'Slot ${slot.key} accepts ${definition.minChildren}..'
                '${definition.maxChildren ?? 'many'} children.',
            '$location/slots/${slot.key}',
          );
        }
        if (slot.value.length > limits.maxChildrenPerSlot) {
          error(
            'limit.slotChildren',
            'Slot has ${slot.value.length} children; limit is '
                '${limits.maxChildrenPerSlot}.',
            '$location/slots/${slot.key}',
          );
        }
        for (final child in slot.value) {
          if (!document.nodes.containsKey(child)) {
            error(
              'graph.missingChild',
              'Child node $child does not exist.',
              '$location/slots/${slot.key}',
            );
            continue;
          }
          final accepted = definition.acceptedComponents;
          final childComponent = document.nodes[child]!.component;
          if (accepted != null && !accepted.contains(childComponent)) {
            error(
              'slot.childType',
              'Slot ${slot.key} does not accept $childComponent.',
              '$location/slots/${slot.key}',
            );
          }
          adjacency[node.id]!.add(child);
          parents[child] = parents[child]! + 1;
        }
      }

      for (final slot in component.slots.entries) {
        final count = node.slots[slot.key]?.length ?? 0;
        if (count < slot.value.minChildren) {
          error(
            'slot.required',
            'Slot ${slot.key} requires at least '
                '${slot.value.minChildren} children.',
            '$location/slots',
          );
        }
      }
    }

    for (final entry in parents.entries) {
      final expected = entry.key == document.root ? 0 : 1;
      if (entry.value != expected) {
        error(
          'graph.parentCount',
          'Node ${entry.key} has ${entry.value} parents; expected $expected.',
          '/nodes/${_escapePointerSegment(entry.key)}',
        );
      }
    }

    _validateGraph(document.root, adjacency, diagnostics, limits.maxDepth);

    // Second pass: validate bindings with lexical context tracking
    _validateBindingsWithContext(
      document,
      catalog,
      adjacency,
      diagnostics,
    );

    final capabilityPattern = RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$');
    for (final action in document.actions.entries) {
      final location = '/actions/${_escapePointerSegment(action.key)}';
      if (!_validIdentifier(action.key)) {
        error(
          'action.invalidId',
          'Action IDs must be 1-128 safe identifier characters.',
          location,
        );
      }
      if (!capabilityPattern.hasMatch(action.value.capability)) {
        error(
          'action.capabilityFormat',
          'Capabilities use lowercase dotted semantic names.',
          '$location/capability',
        );
      }
      final capability = capabilities.capability(action.value.capability);
      if (capability == null) {
        error(
          'action.capabilityDenied',
          'Capability ${action.value.capability} is not registered.',
          '$location/capability',
        );
      }
      for (final arg in action.value.args.entries) {
        final diagnosticsBefore = diagnostics.length;
        _validateActionValue(
          arg.value,
          '$location/args/${arg.key}',
          document.state,
          diagnostics,
        );
        final argumentDefinition = capability?.arguments[arg.key];
        if (capability != null && argumentDefinition == null) {
          error(
            'action.unknownArgument',
            'Capability ${capability.code} does not accept ${arg.key}.',
            '$location/args/${arg.key}',
          );
        } else if (argumentDefinition != null &&
            diagnostics.length == diagnosticsBefore) {
          final resolved = _resolveActionValue(arg.value, document.state);
          // Only type-check if resolved (null means item/event binding at validation time)
          if (resolved != null && !argumentDefinition.type.accepts(resolved)) {
            error(
              'action.argumentType',
              'Expected ${argumentDefinition.type.displayName}.',
              '$location/args/${arg.key}',
            );
          }
        }
      }
      if (capability != null) {
        for (final argument in capability.arguments.entries) {
          if (argument.value.required &&
              !action.value.args.containsKey(argument.key)) {
            error(
              'action.requiredArgument',
              'Capability ${capability.code} requires ${argument.key}.',
              '$location/args',
            );
          }
        }
      }
    }

    return GenuxValidationResult(diagnostics);
  }
}

bool _validIdentifier(String value) =>
    value.length <= 128 &&
    RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:-]*$').hasMatch(value);

void _validateBindingsWithContext(
  GenuxDocument document,
  GenuxCatalog catalog,
  Map<String, List<String>> adjacency,
  List<GenuxDiagnostic> diagnostics,
) {
  void error(String code, String message, String location) {
    diagnostics.add(
      GenuxDiagnostic(code: code, message: message, location: location),
    );
  }

  // Traverse from root and track which nodes have item context
  final nodesWithItemContext = <String>{};

  void traverse(String nodeId, bool hasItemContext) {
    if (hasItemContext) {
      nodesWithItemContext.add(nodeId);
    }

    final node = document.nodes[nodeId];
    if (node == null) return;

    final component = catalog.component(node.component);
    if (component == null) return;

    // Check which slots introduce item context
    for (final slotEntry in node.slots.entries) {
      final slotDef = component.slots[slotEntry.key];
      if (slotDef == null) continue;

      final introducesItem = slotDef.introducesContext == GenuxContextKind.item;
      for (final childId in slotEntry.value) {
        traverse(childId, hasItemContext || introducesItem);
      }
    }
  }

  traverse(document.root, false);

  // Now validate all bindings with context information
  for (final node in document.nodes.values) {
    final location = '/nodes/${_escapePointerSegment(node.id)}';
    final component = catalog.component(node.component);
    if (component == null) continue;

    final hasItemContext = nodesWithItemContext.contains(node.id);

    for (final binding in node.bindings.entries) {
      final channel = component.channels[binding.key];
      if (channel == null) continue; // Already reported as unknown

      final source = binding.value.source ?? 'state';
      final bindingLoc = '$location/bind/${binding.key}';

      // Validate source
      if (source != 'state' && source != 'item' && source != 'event') {
        error(
          'binding.unknownSource',
          'Binding source must be "state", "item", or "event".',
          bindingLoc,
        );
        continue;
      }

      // Validate item source requires item context
      if (source == 'item' && !hasItemContext) {
        error(
          'binding.itemOutsideContext',
          'Item bindings are only valid inside item-template slots.',
          bindingLoc,
        );
        continue;
      }

      // Validate event source not allowed in node bindings
      if (source == 'event') {
        error(
          'binding.eventInNode',
          'Event bindings are only valid in action arguments.',
          bindingLoc,
        );
        continue;
      }

      // Validate writable channels require state source
      final isWritable = channel.direction == GenuxChannelDirection.state;
      if (isWritable && source != 'state') {
        error(
          'binding.nonStateWritable',
          'Writable channels can only bind to state source.',
          bindingLoc,
        );
        continue;
      }

      // Parse pointer
      GenuxJsonPointer pointer;
      try {
        pointer = GenuxJsonPointer.parse(binding.value.path);
      } on FormatException catch (exception) {
        error(
          'binding.path',
          exception.message.toString(),
          bindingLoc,
        );
        continue;
      }

      // Validate state bindings against document state
      if (source == 'state') {
        final resolved = pointer.read(document.state);

        if (isWritable && binding.value.hasFallback) {
          error(
            'binding.stateFallback',
            'Writable state channels cannot use a fallback.',
            bindingLoc,
          );
        }
        if (isWritable && pointer.segments.isEmpty) {
          error(
            'binding.rootWrite',
            'Writable state channels cannot replace the surface state root.',
            bindingLoc,
          );
        }
        if (!resolved.exists && (isWritable || !binding.value.hasFallback)) {
          error(
            'binding.missingValue',
            'State path ${binding.value.path} does not exist and has no fallback.',
            bindingLoc,
          );
        } else {
          final value = resolved.exists
              ? resolved.value
              : binding.value.fallback;
          if (!channel.type.accepts(value)) {
            error(
              'binding.type',
              'State value must be ${channel.type.displayName}.',
              bindingLoc,
            );
          } else if (channel.constraint.violation(value)
              case final violation?) {
            error(
              'binding.constraint',
              violation,
              bindingLoc,
            );
          }
        }
      }
      // Item bindings validated structurally but not against data
      // (item data is runtime-dependent)
    }
  }
}

bool _validateJsonTree(
  Object? value,
  String location,
  int depth,
  GenuxValidationLimits limits,
  List<GenuxDiagnostic> diagnostics,
) {
  void issue(String code, String message) {
    diagnostics.add(
      GenuxDiagnostic(code: code, message: message, location: location),
    );
  }

  if (depth > limits.maxValueDepth) {
    issue('limit.valueDepth', 'JSON value nesting exceeds the limit.');
    return false;
  }
  if (value == null || value is bool || value is int) {
    return true;
  }
  if (value is double) {
    if (!value.isFinite) {
      issue('syntax.nonJsonValue', 'JSON numbers must be finite.');
      return false;
    }
    return true;
  }
  if (value is String) {
    if (value.length > limits.maxStringLength) {
      issue(
        'limit.stringLength',
        'String length exceeds ${limits.maxStringLength}.',
      );
      return false;
    }
    return true;
  }
  if (value is List) {
    if (value.length > limits.maxCollectionItems) {
      issue(
        'limit.collectionItems',
        'List length exceeds ${limits.maxCollectionItems}.',
      );
      return false;
    }
    var valid = true;
    for (var index = 0; index < value.length; index += 1) {
      valid =
          _validateJsonTree(
            value[index],
            '$location/$index',
            depth + 1,
            limits,
            diagnostics,
          ) &&
          valid;
    }
    return valid;
  }
  if (value is Map) {
    if (value.length > limits.maxCollectionItems) {
      issue(
        'limit.collectionItems',
        'Object field count exceeds ${limits.maxCollectionItems}.',
      );
      return false;
    }
    var valid = true;
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        issue('syntax.nonStringKey', 'JSON object keys must be strings.');
        valid = false;
        continue;
      }
      if (key.length > limits.maxStringLength) {
        issue('limit.stringLength', 'JSON object key is too long.');
        valid = false;
        continue;
      }
      valid =
          _validateJsonTree(
            entry.value,
            '$location/${_escapePointerSegment(key)}',
            depth + 1,
            limits,
            diagnostics,
          ) &&
          valid;
    }
    return valid;
  }

  issue('syntax.nonJsonValue', 'Only JSON-compatible values are supported.');
  return false;
}

String _escapePointerSegment(String value) =>
    value.replaceAll('~', '~0').replaceAll('/', '~1');

void _validateGraph(
  String root,
  Map<String, List<String>> adjacency,
  List<GenuxDiagnostic> diagnostics,
  int maxDepth,
) {
  if (!adjacency.containsKey(root)) {
    return;
  }

  final visiting = <String>{};
  final visited = <String>{};

  void visit(String node, int depth) {
    if (depth > maxDepth) {
      diagnostics.add(
        GenuxDiagnostic(
          code: 'limit.depth',
          message: 'Graph depth exceeds $maxDepth.',
          location: '/nodes/${_escapePointerSegment(node)}',
        ),
      );
      return;
    }
    if (visiting.contains(node)) {
      diagnostics.add(
        GenuxDiagnostic(
          code: 'graph.cycle',
          message: 'The node graph contains a cycle at $node.',
          location: '/nodes/${_escapePointerSegment(node)}',
        ),
      );
      return;
    }
    if (visited.contains(node)) {
      return;
    }

    visiting.add(node);
    for (final child in adjacency[node] ?? const <String>[]) {
      visit(child, depth + 1);
    }
    visiting.remove(node);
    visited.add(node);
  }

  visit(root, 1);
  for (final node in adjacency.keys.where((node) => !visited.contains(node))) {
    diagnostics.add(
      GenuxDiagnostic(
        code: 'graph.unreachable',
        message: 'Node $node is not reachable from root $root.',
        location: '/nodes/${_escapePointerSegment(node)}',
      ),
    );
  }
}

void _validateActionValue(
  Object? value,
  String location,
  Map<String, Object?> state,
  List<GenuxDiagnostic> diagnostics,
) {
  if (value == null || value is bool || value is num || value is String) {
    return;
  }
  if (value is List) {
    for (var index = 0; index < value.length; index += 1) {
      _validateActionValue(
        value[index],
        '$location/$index',
        state,
        diagnostics,
      );
    }
    return;
  }
  if (value is! Map) {
    diagnostics.add(
      GenuxDiagnostic(
        code: 'action.nonJsonValue',
        message: 'Action arguments must contain only JSON values.',
        location: location,
      ),
    );
    return;
  }

  if (value.containsKey(r'$bind')) {
    final bindValue = value[r'$bind'];

    // Handle explicit source object: {"$bind": {"source": "...", "path": "..."}}
    if (bindValue is Map) {
      final allowed = {r'$bind', 'fallback'};
      if (value.keys.any((key) => key is! String || !allowed.contains(key))) {
        diagnostics.add(
          GenuxDiagnostic(
            code: 'action.bindingShape',
            message: 'A bound argument only supports \$bind and fallback.',
            location: location,
          ),
        );
        return;
      }

      final source = bindValue['source'];
      final path = bindValue['path'];

      if (source != null && source is! String) {
        diagnostics.add(
          GenuxDiagnostic(
            code: 'action.bindingSource',
            message: 'Binding source must be a string.',
            location: location,
          ),
        );
        return;
      }

      if (source != null && source != 'state' && source != 'item' && source != 'event') {
        diagnostics.add(
          GenuxDiagnostic(
            code: 'action.unknownSource',
            message: 'Binding source must be "state", "item", or "event".',
            location: location,
          ),
        );
        return;
      }

      if (path is! String) {
        diagnostics.add(
          GenuxDiagnostic(
            code: 'action.bindingPath',
            message: 'Binding path must be a JSON Pointer string.',
            location: location,
          ),
        );
        return;
      }

      try {
        GenuxJsonPointer.parse(path);
        // For state bindings, validate against document state
        if (source == 'state' || source == null) {
          final resolved = GenuxJsonPointer.parse(path).read(state);
          if (!resolved.exists && !value.containsKey('fallback')) {
            diagnostics.add(
              GenuxDiagnostic(
                code: 'action.bindingMissing',
                message: 'State path $path does not exist and has no fallback.',
                location: location,
              ),
            );
          }
        }
        // Item and event bindings are validated at runtime
      } on FormatException catch (exception) {
        diagnostics.add(
          GenuxDiagnostic(
            code: 'action.bindingPath',
            message: exception.message.toString(),
            location: location,
          ),
        );
      }
      return;
    }

    // Handle string shorthand: {"$bind": "/path"}
    if (bindValue is String) {
      final allowed = {r'$bind', 'fallback'};
      if (value.keys.any((key) => key is! String || !allowed.contains(key))) {
        diagnostics.add(
          GenuxDiagnostic(
            code: 'action.bindingShape',
            message: 'A bound argument only supports \$bind and fallback.',
            location: location,
          ),
        );
        return;
      }

      try {
        final resolved = GenuxJsonPointer.parse(bindValue).read(state);
        if (!resolved.exists && !value.containsKey('fallback')) {
          diagnostics.add(
            GenuxDiagnostic(
              code: 'action.bindingMissing',
              message: 'State path $bindValue does not exist and has no fallback.',
              location: location,
            ),
          );
        }
      } on FormatException catch (exception) {
        diagnostics.add(
          GenuxDiagnostic(
            code: 'action.bindingPath',
            message: exception.message.toString(),
            location: location,
          ),
        );
      }
      return;
    }

    // Invalid $bind value
    diagnostics.add(
      GenuxDiagnostic(
        code: 'action.bindingPath',
        message: '\$bind must be a JSON Pointer string or source object.',
        location: location,
      ),
    );
    return;
  }

  for (final entry in value.entries) {
    if (entry.key is! String) {
      diagnostics.add(
        GenuxDiagnostic(
          code: 'action.nonStringKey',
          message: 'Action object keys must be strings.',
          location: location,
        ),
      );
      continue;
    }
    _validateActionValue(
      entry.value,
      '$location/${entry.key}',
      state,
      diagnostics,
    );
  }
}

Object? _resolveActionValue(Object? value, Map<String, Object?> state) {
  if (value is List) {
    return [for (final item in value) _resolveActionValue(item, state)];
  }
  if (value is Map) {
    if (value.containsKey(r'$bind')) {
      final bindValue = value[r'$bind'];

      // Handle explicit source object
      if (bindValue is Map) {
        final source = bindValue['source'] as String?;
        final path = bindValue['path'] as String;

        // At validation time, only resolve state bindings
        if (source == 'state' || source == null) {
          final resolved = GenuxJsonPointer.parse(path).read(state);
          return resolved.exists ? resolved.value : value['fallback'];
        }

        // Item and event bindings cannot be resolved at validation time
        return null;
      }

      // Handle string shorthand
      if (bindValue is String) {
        final resolved = GenuxJsonPointer.parse(bindValue).read(state);
        return resolved.exists ? resolved.value : value['fallback'];
      }

      return null;
    }
    return <String, Object?>{
      for (final entry in value.entries)
        entry.key! as String: _resolveActionValue(entry.value, state),
    };
  }
  return value;
}
