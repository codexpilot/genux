import 'dart:collection';

import 'value_type.dart';

final class GenuxArgumentDefinition {
  const GenuxArgumentDefinition({required this.type, this.required = false});

  final GenuxValueType type;
  final bool required;
}

final class GenuxCapabilityDefinition {
  GenuxCapabilityDefinition({
    required this.code,
    Map<String, GenuxArgumentDefinition> arguments = const {},
  }) : arguments = UnmodifiableMapView(Map.of(arguments)) {
    if (code.isEmpty) {
      throw ArgumentError('Capability code must be non-empty.');
    }
  }

  final String code;
  final Map<String, GenuxArgumentDefinition> arguments;
}

final class GenuxCapabilityRegistry {
  GenuxCapabilityRegistry(Iterable<GenuxCapabilityDefinition> definitions)
    : definitions = UnmodifiableMapView({
        for (final definition in definitions) definition.code: definition,
      }) {
    if (this.definitions.length != definitions.length) {
      throw ArgumentError('Capability codes must be unique.');
    }
  }

  final Map<String, GenuxCapabilityDefinition> definitions;

  GenuxCapabilityDefinition? capability(String code) => definitions[code];
}
