import 'dart:collection';

import '../catalog/catalog.dart';
import 'component_scope.dart';

final class GenuxFlutterRegistration {
  const GenuxFlutterRegistration({
    required this.componentCode,
    required this.builder,
  });

  final String componentCode;
  final GenuxComponentBuilder builder;
}

final class GenuxFlutterCatalog {
  GenuxFlutterCatalog._({
    required this.catalog,
    required Map<String, GenuxComponentBuilder> builders,
  }) : _builders = UnmodifiableMapView(builders);

  factory GenuxFlutterCatalog({
    required GenuxCatalog catalog,
    required Iterable<GenuxFlutterRegistration> registrations,
  }) {
    final byCode = <String, GenuxFlutterRegistration>{};
    for (final registration in registrations) {
      if (byCode.containsKey(registration.componentCode)) {
        throw ArgumentError(
          'Renderer ${registration.componentCode} is registered twice.',
        );
      }
      byCode[registration.componentCode] = registration;
    }

    final unknown = byCode.keys.where(
      (code) => !catalog.components.containsKey(code),
    );
    if (unknown.isNotEmpty) {
      throw ArgumentError('Renderer ${unknown.first} is not in the catalog.');
    }

    final missing = catalog.components.keys.where(
      (code) => !byCode.containsKey(code),
    );
    if (missing.isNotEmpty) {
      throw ArgumentError(
        'Catalog component ${missing.first} has no renderer.',
      );
    }

    final resolved = <String, GenuxComponentBuilder>{};
    for (final component in catalog.components.values) {
      resolved[component.code] = byCode[component.code]!.builder;
    }
    return GenuxFlutterCatalog._(catalog: catalog, builders: resolved);
  }

  final GenuxCatalog catalog;
  final Map<String, GenuxComponentBuilder> _builders;

  GenuxComponentBuilder builderFor(GenuxComponentDefinition component) {
    final registeredComponent = catalog.component(component.code);
    final builder = _builders[component.code];
    if (registeredComponent == null || builder == null) {
      throw StateError(
        'Component ${component.code}@${component.version} is not registered.',
      );
    }
    if (registeredComponent.version != component.version) {
      throw StateError(
        'Component ${component.code}@${component.version} does not match '
        'renderer version ${registeredComponent.version}.',
      );
    }
    return builder;
  }
}
