import 'dart:collection';

import 'value_type.dart';

enum GenuxChannelDirection { input, state }

final class GenuxValueConstraint {
  const GenuxValueConstraint({
    this.allowedValues,
    this.minimum,
    this.maximum,
    this.maxLength,
    this.maxItems,
  });

  final Set<Object?>? allowedValues;
  final num? minimum;
  final num? maximum;
  final int? maxLength;
  final int? maxItems;

  String? violation(Object? value) {
    final allowed = allowedValues;
    if (allowed != null && !allowed.contains(value)) {
      return 'Expected one of ${allowed.join(', ')}.';
    }
    if (value is num && minimum != null && value < minimum!) {
      return 'Must be at least $minimum.';
    }
    if (value is num && maximum != null && value > maximum!) {
      return 'Must be at most $maximum.';
    }
    if (value is String && maxLength != null && value.length > maxLength!) {
      return 'Must contain at most $maxLength characters.';
    }
    if (value is List && maxItems != null && value.length > maxItems!) {
      return 'Must contain at most $maxItems items.';
    }
    return null;
  }
}

final class GenuxPropertyDefinition {
  const GenuxPropertyDefinition({
    required this.type,
    this.required = false,
    this.constraint = const GenuxValueConstraint(),
  });

  final GenuxValueType type;
  final bool required;
  final GenuxValueConstraint constraint;
}

final class GenuxChannelDefinition {
  const GenuxChannelDefinition({
    required this.type,
    required this.direction,
    this.required = false,
    this.constraint = const GenuxValueConstraint(),
  });

  final GenuxValueType type;
  final GenuxChannelDirection direction;
  final bool required;
  final GenuxValueConstraint constraint;

  bool get acceptsLiteral => direction == GenuxChannelDirection.input;
}

final class GenuxEventDefinition {
  const GenuxEventDefinition({this.payload = GenuxValueType.any});

  final GenuxValueType payload;
}

final class GenuxSlotDefinition {
  const GenuxSlotDefinition({
    bool required = false,
    bool multiple = true,
    int? minChildren,
    int? maxChildren,
    this.acceptedComponents,
    this.introducesContext = GenuxContextKind.none,
  }) : minChildren = minChildren ?? (required ? 1 : 0),
       maxChildren = maxChildren ?? (multiple ? null : 1),
       assert((minChildren ?? (required ? 1 : 0)) >= 0),
       assert(
         maxChildren == null ||
             maxChildren >= (minChildren ?? (required ? 1 : 0)),
       );

  final int minChildren;
  final int? maxChildren;
  final Set<String>? acceptedComponents;
  final GenuxContextKind introducesContext;

  bool get required => minChildren > 0;
  bool get multiple => maxChildren != 1;
}

/// Context introduced by a component slot.
enum GenuxContextKind {
  /// No context introduced.
  none,

  /// Item template context with {key, index, data}.
  item,
}

final class GenuxComponentDefinition {
  GenuxComponentDefinition({
    required this.code,
    required this.version,
    this.id,
    Map<String, GenuxPropertyDefinition> properties = const {},
    Map<String, GenuxChannelDefinition> channels = const {},
    Map<String, GenuxEventDefinition> events = const {},
    Map<String, GenuxSlotDefinition> slots = const {},
  }) : properties = UnmodifiableMapView(_freezeProperties(properties)),
       channels = UnmodifiableMapView(_freezeChannels(channels)),
       events = UnmodifiableMapView(Map.of(events)),
       slots = UnmodifiableMapView(_freezeSlots(slots)) {
    if (code.isEmpty || version < 1) {
      throw ArgumentError(
        'Component code must be non-empty and version positive.',
      );
    }
    if (id != null && id! < 1) {
      throw ArgumentError('Component ID must be positive when provided.');
    }
    final memberCount =
        properties.length + channels.length + events.length + slots.length;
    final memberNames = {
      ...properties.keys,
      ...channels.keys,
      ...events.keys,
      ...slots.keys,
    };
    if (memberNames.length != memberCount) {
      throw ArgumentError(
        'Component member names must be unique across all member kinds.',
      );
    }
  }

  final String code;
  final int? id; // Numeric registry ID
  final int version;
  final Map<String, GenuxPropertyDefinition> properties;
  final Map<String, GenuxChannelDefinition> channels;
  final Map<String, GenuxEventDefinition> events;
  final Map<String, GenuxSlotDefinition> slots;
}

final class GenuxCatalog {
  GenuxCatalog({
    required this.id,
    required this.version,
    required this.checksum,
    required Iterable<GenuxComponentDefinition> components,
  }) : components = UnmodifiableMapView({
         for (final component in components) component.code: component,
       }),
       componentsById = UnmodifiableMapView({
         for (final component in components)
           if (component.id != null) component.id!: component,
       }) {
    if (id.isEmpty ||
        version < 1 ||
        !RegExp(r'^sha256:[0-9a-f]{64}$').hasMatch(checksum)) {
      throw ArgumentError(
        'Catalog ID must be non-empty, version positive, and checksum a '
        'lowercase SHA-256 fingerprint.',
      );
    }
    if (this.components.length != components.length) {
      throw ArgumentError('Component codes must be unique within a catalog.');
    }
    // Validate numeric IDs are unique
    final ids = components.where((c) => c.id != null).map((c) => c.id!).toList();
    if (ids.toSet().length != ids.length) {
      throw ArgumentError('Component IDs must be unique within a catalog.');
    }
  }

  final String id;
  final int version;
  final String checksum;
  final Map<String, GenuxComponentDefinition> components;
  final Map<int, GenuxComponentDefinition> componentsById;

  GenuxComponentDefinition? component(String code) => components[code];
  GenuxComponentDefinition? componentById(int id) => componentsById[id];
}

Map<String, GenuxPropertyDefinition> _freezeProperties(
  Map<String, GenuxPropertyDefinition> definitions,
) => {
  for (final entry in definitions.entries)
    entry.key: GenuxPropertyDefinition(
      type: entry.value.type,
      required: entry.value.required,
      constraint: _freezeConstraint(entry.value.constraint),
    ),
};

Map<String, GenuxChannelDefinition> _freezeChannels(
  Map<String, GenuxChannelDefinition> definitions,
) => {
  for (final entry in definitions.entries)
    entry.key: GenuxChannelDefinition(
      type: entry.value.type,
      direction: entry.value.direction,
      required: entry.value.required,
      constraint: _freezeConstraint(entry.value.constraint),
    ),
};

Map<String, GenuxSlotDefinition> _freezeSlots(
  Map<String, GenuxSlotDefinition> definitions,
) => {
  for (final entry in definitions.entries)
    entry.key: GenuxSlotDefinition(
      minChildren: entry.value.minChildren,
      maxChildren: entry.value.maxChildren,
      acceptedComponents: entry.value.acceptedComponents == null
          ? null
          : Set<String>.unmodifiable(entry.value.acceptedComponents!),
      introducesContext: entry.value.introducesContext,
    ),
};

GenuxValueConstraint _freezeConstraint(GenuxValueConstraint constraint) =>
    GenuxValueConstraint(
      allowedValues: constraint.allowedValues == null
          ? null
          : Set<Object?>.unmodifiable(constraint.allowedValues!),
      minimum: constraint.minimum,
      maximum: constraint.maximum,
      maxLength: constraint.maxLength,
      maxItems: constraint.maxItems,
    );
