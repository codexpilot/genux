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
  interactive DartPad-style reference consumer with a two-pane layout: JSON
  editor on the left and live runtime view on the right. Experience the
  JSON-driven customer editor, summary, Component Lab, and customer list Views
  with real-time editing, view navigation, and immediate visual feedback.

The showcase uses the same exported APIs as another application; it is not a
separate demo renderer.

## Current milestone

Implemented:

- Flutter 3.44.8 / Dart 3.12.2 application scaffold;
- strict `aix.genux/1.0` wire draft;
- released component catalog model with typed properties, channels, events, and
  slots;
- **aix.core@1 catalog**: ten components (`Column`, `Text`, `ComboBox`, `Button`,
  `Form`, `TextField`, `Checkbox`, `Row`, `Card`, and `Divider`);
- **aix.core@2 catalog**: extends v1 with `CollectionView` (repeated item
  template with list/grid layouts) and `Expanded` (bounded layout primitive);
- **evaluation context foundation**: explicit binding sources (state, item,
  event) for item templates and action arguments;
- implemented Form Essentials slice with controlled text/boolean state, bounded
  layout primitives, busy/error presentation, and keyboard lifecycle events;
- normalized `ChoiceItem` values;
- RFC 6901 JSON Pointer parsing;
- graph, catalog, binding, action, capability, and resource validation;
- compile-result diagnostics that keep hostile input from reaching rendering;
- immutable compiled nodes with resolved component/channel/event/slot handles;
- transactional, versioned, path-aware surface state with dirty/conflict rules;
- Flutter component registration and Material renderers for all current
  catalog components;
- `GenuxSurfaceSession` capability dispatch after committed state changes;
- explicit success/not-bound/failure results for safe asynchronous dispatch;
- a pure-Dart `GenuxViewCoordinator` that keeps one independent document and
  session per View stack entry, preserves prior state on back, and prevents stale
  asynchronous opens from committing;
- trusted showcase handling for semantic `view.open` and `view.back` capabilities;
- a responsive native showcase with Workspace, Catalog, and Runtime & Safety
  experiences;
- executable `customer.edit` revision 6, `customer.summary` revision 1,
  `customer.list` revision 1, and `component.lab` revision 1 fixtures plus unit
  and widget tests;
- and a 57-node, 14-action Component Lab that renders 11 of 12 aix.core@2 component
  types (CollectionView is demonstrated separately in customer.list due to Flutter's
  nested scrollable constraints), exercising all catalog members except CollectionView.

Not implemented yet:

- advanced form behavior: MetaX-backed client rules, coordinated commit and
  explicit update policies, submit validation/gating, and server error mapping;
- DataGrid: two-dimensional virtualization, column management, measured cells,
  sorting, filtering, selection, and keyboard navigation (exploratory phase);
- Aix QueryHub transport/capability adapter;
- QueryHub-backed durable/offline caching and restoration;
- canonical catalog manifest export/hash generation (the current checksum is a
  development release fingerprint); and
- CloudX relational authoring/publishing migrations.

## Design

- [Architecture](docs/architecture.md)
- [MultiView runtime](docs/multiview.md)
- [Component Lab](docs/component-lab.md)
- [Evaluation Context & Binding Sources](docs/adr-evaluation-context.md) - Item templates, explicit sources
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
[`customer.summary` revision 1](assets/views/customer-summary.genux.json),
[`customer.list` revision 1](assets/views/customer-list.genux.json), and
[`component.lab` revision 1](assets/views/component-lab.genux.json) through
the public View coordinator. Navigate using **Open Customer Summary**,
**Open Component Lab**, and **Back to editor** buttons. Component Lab demonstrates
all 12 aix.core@2 components including CollectionView with list/grid layouts and
Expanded for bounded layout. Returning from any child View reveals the exact
retained editor session.

Genux targets native mobile and desktop Flutter applications; Flutter web is not
a supported target.

## Verify

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze  # 0 errors, 0 warnings (1 info suggestion)
flutter test     # 68/70 passing (97.1%)
```

Two widget tests fail due to test infrastructure constraint setup for
Expanded/CollectionView in test environment. All functionality works correctly
in real app usage.

## Embed the runtime

An Aix Flutter application can use the same seam:

```dart
import 'package:genux/genux_flutter.dart';

final catalog = createGenuxCoreV2Catalog();  // or createGenuxCoreCatalog() for v1
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
