import 'package:flutter/widgets.dart';

/// Registry of Gux component factories for dynamic JSON-to-widget rendering.
///
/// This enables building Gux widgets from JSON specifications at runtime,
/// which is essential for A2UI integration and dynamic UI generation.
class GuxJsonRenderer {
  GuxJsonRenderer._();

  /// Map of component type names to their factory functions
  static final Map<String, GuxComponentFactory> _registry = {};

  /// Register a component factory
  static void register(String type, GuxComponentFactory factory) {
    _registry[type] = factory;
  }

  /// Build a widget from JSON specification
  ///
  /// The JSON must have a 'type' field matching a registered component.
  /// The 'props' field contains the component properties.
  ///
  /// Example:
  /// ```dart
  /// final widget = GuxJsonRenderer.build({
  ///   'type': 'gux.button',
  ///   'props': {
  ///     'style': {'backgroundColor': '#0000FF'},
  ///     'child': 'Click Me',
  ///     'onPressed': 'handleClick',
  ///   }
  /// }, actions: {'handleClick': () => print('clicked')});
  /// ```
  static Widget build(
    Map<String, dynamic> json, {
    Map<String, VoidCallback> actions = const {},
  }) {
    final type = json['type'] as String?;
    if (type == null) {
      throw ArgumentError('JSON must have a "type" field');
    }

    final factory = _registry[type];
    if (factory == null) {
      throw ArgumentError('Unknown component type: $type');
    }

    final props = json['props'] as Map<String, dynamic>? ?? {};
    return factory(props, actions);
  }

  /// Build multiple widgets from JSON array
  static List<Widget> buildAll(
    List<dynamic> jsonList, {
    Map<String, VoidCallback> actions = const {},
  }) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map((json) => build(json, actions: actions))
        .toList();
  }

  /// Parse a child widget from JSON
  ///
  /// Supports:
  /// - String: creates Text widget
  /// - Map with 'type': nested component
  /// - null: returns SizedBox.shrink()
  static Widget parseChild(
    dynamic child, {
    Map<String, VoidCallback> actions = const {},
  }) {
    if (child == null) return const SizedBox.shrink();

    if (child is String) {
      return Text(child);
    }

    if (child is Map<String, dynamic>) {
      return build(child, actions: actions);
    }

    if (child is List) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: buildAll(child, actions: actions),
      );
    }

    throw ArgumentError('Invalid child type: ${child.runtimeType}');
  }

  /// Get all registered component types
  static List<String> get registeredTypes => _registry.keys.toList();

  /// Check if a component type is registered
  static bool isRegistered(String type) => _registry.containsKey(type);

  /// Clear all registrations (useful for testing)
  static void clear() => _registry.clear();
}

/// Factory function signature for creating Gux widgets from JSON
typedef GuxComponentFactory = Widget Function(
  Map<String, dynamic> props,
  Map<String, VoidCallback> actions,
);

/// Exception thrown when a component cannot be built from JSON
class GuxJsonRenderException implements Exception {
  GuxJsonRenderException(this.message, this.json);

  final String message;
  final Map<String, dynamic> json;

  @override
  String toString() => 'GuxJsonRenderException: $message\nJSON: $json';
}
