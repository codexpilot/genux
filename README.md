# Genux

Genux is the private native Flutter runtime frontend for Aix applications: a
high-performance, template-first, JSON-driven UI system for mobile and desktop,
with a future bounded GenUI/A2UI integration path. Flutter web is not a target.

The design principle is **dynamic UI without schema-less UI**. CloudX authors
normalized relational View metadata and initiates publication. A trusted
server-side compiler validates it and stores an immutable artifact in Aix;
QueryHub delivers an authorized runtime snapshot, which Genux compiles into
trusted Flutter runtime handles.

Genux deliberately has two roles:

- **Reusable runtime:** the catalog, strict document compiler, transactional
  state store, capability session, pure-Dart View coordinator, Flutter registry,
  and `GenuxSurfaceHost` can be embedded in Aix runtime frontend applications.
- **Showcase application:** this repository's native Flutter app is an
  interactive reference consumer. It lets people experience the live JSON-driven
  customer editor, summary, and Component Lab Views, navigate between their
  retained sessions, inspect state/actions/source, browse the released catalog,
  and exercise rejection and safety behavior.

The showcase uses the same exported APIs as another application; it is not a
separate demo renderer.

## Current milestone

Implemented:

- Flutter 3.44.8 / Dart 3.12.2 application scaffold;
- strict `aix.genux/1.0` wire draft;
- released component catalog model with typed properties, channels, events, and
  slots;
- ten-component `aix.core@1` catalog: `Column`, `Text`, `ComboBox`, `Button`,
  `Form`, `TextField`, `Checkbox`, `Row`, `Card`, and `Divider`;
- implemented Form Essentials slice with controlled text/boolean state, bounded
  layout primitives, busy/error presentation, and keyboard lifecycle events;
- normalized `ChoiceItem` values;
- RFC 6901 JSON Pointer parsing;
- graph, catalog, binding, action, capability, and resource validation;
- compile-result diagnostics that keep hostile input from reaching rendering;
- immutable compiled nodes with resolved component/channel/event/slot handles;
- transactional, versioned, path-aware surface state with dirty/conflict rules;
- Flutter component registration and Material renderers for all ten current
  catalog components;
- `GenuxSurfaceSession` capability dispatch after committed state changes;
- explicit success/not-bound/failure results for safe asynchronous dispatch;
- a pure-Dart `GenuxViewCoordinator` that keeps one independent document and
  session per View stack entry, preserves prior state on back, and prevents stale
  asynchronous opens from committing;
- trusted showcase handling for semantic `view.open` and `view.back` capabilities;
- a responsive native showcase with Workspace, Catalog, and Runtime & Safety
  experiences;
- executable `customer.edit` revision 6, `customer.summary` revision 1, and
  `component.lab` revision 1 fixtures plus unit and widget tests;
- and a 43-node, 13-action Component Lab that renders all ten component types and
  exercises all 47 top-level `aix.core@1` catalog members.

Not implemented yet:

- Aix QueryHub transport/capability adapter;
- QueryHub-backed durable/offline caching and restoration;
- canonical catalog manifest export/hash generation (the current checksum is a
  development release fingerprint); and
- CloudX relational authoring/publishing migrations.

## Design

- [Architecture](docs/architecture.md)
- [MultiView runtime](docs/multiview.md)
- [Component Lab](docs/component-lab.md)
- [`aix.genux/1.0` runtime protocol](docs/protocol-v1-draft.md)
- [Binding model](docs/binding-model.md)
- [Relational authoring model](docs/storage-model.md)

## Run

```sh
flutter pub get
flutter devices
flutter run -d <native-device-id>
```

This launches the native showcase application. Its Customer Workspace loads
[`customer.edit` revision 6](assets/views/customer-edit.genux.json), opens
[`customer.summary` revision 1](assets/views/customer-summary.genux.json) through
the public View coordinator, and opens the
[`component.lab` revision 1](assets/views/component-lab.genux.json) compatibility
View through **Open Component Lab**. Returning from either child View reveals the
exact retained editor session. Component Lab interactions update its isolated
state and record typed `demo.event` invocations in the Actions inspector.
Genux targets native mobile and desktop Flutter applications; Flutter web is not
a supported target.

## Embed the runtime

An Aix Flutter application can use the same seam:

```dart
import 'package:genux/genux_flutter.dart';

final catalog = createGenuxCoreCatalog();
final capabilities = GenuxCapabilityRegistry([
  GenuxCapabilityDefinition(
    code: 'view.open',
    arguments: const {
      'viewCode': GenuxArgumentDefinition(
        type: GenuxValueType.string,
        required: true,
      ),
    },
  ),
  GenuxCapabilityDefinition(code: 'view.back'),
  GenuxCapabilityDefinition(
    code: 'customer.type.changed',
    arguments: const {
      'value': GenuxArgumentDefinition(
        type: GenuxValueType.nullableJsonScalar,
        required: true,
      ),
    },
  ),
  GenuxCapabilityDefinition(
    code: 'customer.save',
    arguments: const {
      'customer': GenuxArgumentDefinition(
        type: GenuxValueType.object,
        required: true,
      ),
    },
  ),
]);

final result = GenuxDocumentCompiler(
  catalog: catalog,
  capabilities: capabilities,
).compileJson(source);

if (result is! GenuxCompileSuccess) {
  throw StateError('Genux document was rejected.');
}

final session = GenuxSurfaceSession.activate(
  result.document,
  dispatcher: (invocation) => dispatchToAix(invocation),
);

final surface = GenuxSurfaceHost(
  session: session,
  catalog: createGenuxMaterialCatalog(catalog),
);
```

Production consumers should present compiler diagnostics and retain their current
last-known-good surface instead of throwing as this compact example does.

Applications with more than one dynamic View put the same compiler and session
seam behind `GenuxViewCoordinator`:

```dart
final views = GenuxViewCoordinator(
  compiler: GenuxDocumentCompiler(
    catalog: catalog,
    capabilities: capabilities,
  ),
  sourceLoader: (target) => loadPublishedView(
    target.viewCode,
    parameters: target.parameters,
  ),
  dispatcher: handleSemanticAction,
);

await views.open(
  GenuxViewTarget(
    viewCode: 'customer.edit',
    instanceKey: 'customer:1001',
    parameters: const {'customerId': '1001'},
  ),
);

final currentSurface = GenuxSurfaceHost(
  session: views.current!.session,
  catalog: createGenuxMaterialCatalog(catalog),
);
```

The trusted action handler may translate allowlisted semantic capabilities such
as `view.open` and `view.back` into coordinator calls. Wire documents never name
Flutter routes or URLs and never contain multiple View roots.

## Verify

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```
