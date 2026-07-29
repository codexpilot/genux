# Genux coding handover for Opus

Date: 2026-07-29  
Repository: `/Users/Shared/dev/git/genux`  
Primary objective: make the current Genux v2/DataView path correct and testable, while preserving the single domain-neutral JSON-to-Flutter engine.

## 1. Executive instruction

Genux should remain one rendering pipeline that supports both:

1. trusted, native Flutter patterns with typed properties and JSON-defined slots; and
2. screens assembled entirely from smaller catalog components.

Do not add domain components such as `ProductPage`, `SalesPage`, `CustomerPage`, or `SaleDetailPage`. Those are JSON documents. Native components must describe reusable UI behavior or layout, for example `Screen`, `CollectionView`, `RecordView`, `FormLayout`, `DataGrid`, `Section`, and `AsyncBoundary`.

The immediate coding package is correctness hardening. It must fix the shipped `customer.list` path, make validator behavior safe for hostile graphs, correctly distinguish null from unavailable context, and add real v2 integration tests. It must not grow into the future template language, state-store rewrite, or catalog migration without discussing those decisions with the user first.

## 2. Non-negotiable architecture rules

- Keep one parse -> validate -> compile -> render pipeline.
- JSON names catalog components; it never names arbitrary Dart classes.
- Raw JSON must not reach component builders.
- Persistent state, template-local data, and event payloads remain separate namespaces.
- Actions remain typed, semantic, locally allowlisted capabilities.
- Do not add arbitrary Dart execution, arbitrary URLs/endpoints, route names, reflection, or a general expression evaluator to JSON.
- A compile success must mean known invalid values and unavailable lexical contexts were already rejected.
- Runtime checks remain as defense in depth; they are not substitutes for compiler checks.
- Generic native patterns may render JSON-defined slots. Fully JSON-composed trees and native patterns use the same compiled node graph.
- Reusable JSON partials should eventually be flattened during publication unless the user explicitly chooses runtime template expansion.
- Preserve existing state/item/event wire syntax during the immediate package.

## 3. Repository baseline

At analysis time:

- branch: `main`, tracking `origin/main`;
- worktree: clean;
- recent commits:
  - `05d6890 feat: add CollectionView data view foundation`
  - `ef44cc6 feat: bootstrap Genux runtime and showcase`
- `flutter analyze --no-pub`: no issues;
- `flutter test --no-pub`: all 70 existing tests passed;
- no repository `AGENTS.md` was present.

Do not preserve the number `70` in documentation after adding tests. Prefer wording tied to CI rather than a manually maintained total.

Before editing, Opus should repeat:

```sh
git status --short --branch
flutter analyze --no-pub
flutter test --no-pub
```

If the worktree is no longer clean, preserve user changes and discuss any overlap before editing.

## 4. Confirmed defects

These are evidence-backed, not speculative.

### 4.1 Cyclic input can overflow contextual validation

`_validateGraph` detects a cycle, but `_validateBindingsWithContext` then recursively traverses slot children without a visited set. A cyclic document can therefore recurse indefinitely after the validator has already produced `graph.cycle`.

Relevant code:

- `lib/src/validation/document_validator.dart`, graph call near line 396;
- `_validateBindingsWithContext`, near line 481;
- `_validateGraph`, near line 740.

### 4.2 The shipped customer-list action cannot dispatch

`assets/views/customer-list.genux.json` binds `selectCustomer` arguments from `source: item`, but `itemInvoked` belongs to the outer `CollectionView` node. Its payload contains the selected item, while the emitting node has no item-local context.

The current dispatch fails with:

```text
GenuxActionDispatchFailed: Bad state: Item context is not available.
```

`CollectionView` currently emits this payload:

```json
{
  "key": "1001",
  "index": 0,
  "data": {
    "id": "1001",
    "name": "Mya Chen"
  }
}
```

Because event bindings resolve against `{ "data": <payload> }`, the stable key is `/data/key` and the customer name is `/data/data/name`.

### 4.3 Action lexical-context validation is missing

The evaluation-context ADR says an item-dependent action shared across incompatible item/non-item use sites is rejected. The current validator validates action value shapes but does not correlate action requirements with each node event that references the action.

### 4.4 Actual null and unresolved values are conflated

`_resolveActionValue` returns nullable `Object?`. Null therefore means both:

- a known JSON null; and
- an item/event value that cannot be resolved statically.

The caller type-checks only when the returned value is non-null. Invalid non-nullable arguments can compile and fail after interaction.

### 4.5 Null event payload means both “present null” and “absent event”

`GenuxEvaluationContext.hasEventContext` is implemented as `eventPayload != null`. A legitimate nullable event, such as clearing a ComboBox, cannot be addressed using `source: event`, path `/data`.

### 4.6 CollectionView has no valid showcase viewport

The workspace is inside a vertical `SingleChildScrollView`. The customer-list root contains `Column -> Expanded -> CollectionView`, so the preview gives a non-zero flex child unbounded vertical constraints. In addition, `customer.list` is registered in the showcase fixture map but no current action opens it.

### 4.7 Item bindings create incorrect global-state subscriptions

`_GenuxNodeHostState._subscribe` subscribes every compiled binding pointer without filtering by binding source. An item binding such as `/data/name` is incorrectly registered against surface state.

### 4.8 Stable collection identity is incomplete

- duplicate detection converts keys to strings, so integer `1` and string `"1"` collide;
- the key is placed on a nested `InkWell`, not the widget returned by `itemBuilder`;
- list/grid builders have no `findChildIndexCallback`.

Stateful descendants can lose or move state when items reorder.

### 4.9 Existing performance claims are not established

Widget construction is lazy, but every CollectionView build validates and copies every item. Every store transaction also deep-copies, deep-compares, and refreezes the full state. Do not claim the whole path is O(visible items) or that 10,000 items sustain 60 fps until measured.

## 5. Coding package A: v2 correctness hardening

This is the recommended first implementation package. Complete Sections A1-A8, then stop and present the diff and test evidence. Use the subdivisions as review checkpoints; do not create commits unless the user asks for commits.

### A1. Replace recursive lexical-context discovery with a terminating analysis

Primary file:

- `lib/src/validation/document_validator.dart`

Required behavior:

1. Context analysis must terminate for cycles, self-cycles, over-depth graphs, missing children, unreachable nodes, and multiply-parented invalid graphs.
2. Preserve the existing graph diagnostics. Do not throw and do not duplicate the same graph error from the context pass.
3. Track every lexical context in which a node is reachable, not merely the first path.

Recommended private representation:

```dart
typedef _ContextState = ({String nodeId, bool hasItemContext});

Map<String, Set<bool>> _collectNodeItemContexts(
  GenuxDocument document,
  GenuxCatalog catalog,
)
```

Algorithm:

1. If the root does not exist, return an empty map.
2. Seed a `ListQueue<_ContextState>` with `(nodeId: root, hasItemContext: false)`.
3. Keep `Set<_ContextState> visited`.
4. For every declared slot edge, obtain the slot definition from the node component.
5. The child state is `hasItemContext || slot.introducesContext == GenuxContextKind.item`.
6. Enqueue a child only if that exact `(nodeId, context)` pair is new.
7. Record all booleans seen per node.

The finite state space is currently at most `nodes * 2`, so even a cyclic invalid graph terminates.

Node binding rule:

- `source: item` is valid only when the node is reachable and every recorded context contains item context.
- If a node is unreachable, rely on `graph.unreachable` and avoid a cascading item-context diagnostic.
- Keep existing diagnostic `binding.itemOutsideContext`; update the message if needed to say the context is not available on every path.

Required tests in a new `test/document_validator_hardening_test.dart`:

- `cycle returns graph.cycle without throwing`
- `self-cycle returns graph.cycle without throwing`
- `graph beyond maxDepth returns limit.depth without throwing`
- `item binding inside itemTemplate compiles`
- `item binding reached through both normal and item-introducing parents fails`

The last document is already invalid because it has multiple parents; context analysis must still terminate and must not incorrectly bless the item binding.

### A2. Analyze action source requirements at every event use site

Primary file:

- `lib/src/validation/document_validator.dart`

Add one recursive action-value analyzer that validates binding structure, records context requirements, and computes static value/shape information. Do not create separate traversals with subtly different ideas of what constitutes a binding.

Recommended internal concepts:

```dart
enum _ActionContextRequirement { item, event }

_ActionValueAnalysis _analyzeActionValue(Object? value)
```

Rules:

- state requires no lexical local;
- event is available for every actual component event dispatch, including a null payload after A5;
- item is available only when every lexical context recorded for the emitting node has item context;
- an action shared by multiple events must satisfy its requirements at every use site;
- unused actions do not need an item-use-site error;
- inspect only reachable nodes with a resolved component, a supported event, and an existing action; an empty context set must not pass through a vacuous `every(...)` and must not create a cascading context diagnostic;
- once an object is recognized as a binding, its `fallback` is a literal JSON value; do not recursively interpret a `$bind` key inside that fallback as another binding;
- malformed bindings must produce their existing structural diagnostic and an invalid analysis result, never a cast exception;
- runtime missing-context exceptions remain as invariant checks.

Use this stable diagnostic contract:

```text
code: action.contextUnavailable
location: /nodes/<escaped-node-id>/events/<escaped-event-name>
message: Action <action-id> requires <source> context, which is unavailable at this event.
```

Required compiler tests:

- a root Button action using `source: item` fails at its event location;
- a Button inside `CollectionView.itemTemplate` using `source: item` compiles;
- one item-dependent action referenced both inside and outside the template fails only at the outside event;
- a root action using `source: event` compiles;
- an event binding remains valid when the event payload type is nullable.
- an unreachable node with an item-dependent event reports the graph error without a cascading context error;
- a binding fallback object containing a literal `$bind` key remains literal;
- missing/non-string paths, unknown sources, and extra binding keys return diagnostics without throwing.

### A3. Represent statically known null separately from deferred resolution

Primary file:

- `lib/src/validation/document_validator.dart`

Replace nullable `_resolveActionValue` results with a tagged analysis result. It must preserve known container shape even when one or more descendants are runtime-dependent.

Recommended model:

```dart
sealed class _StaticActionResolution {
  const _StaticActionResolution();
}

final class _KnownActionValue extends _StaticActionResolution {
  const _KnownActionValue(this.value);
  final Object? value;
}

final class _DeferredActionValue extends _StaticActionResolution {
  const _DeferredActionValue({
    required this.requirements,
    required this.knownShape,
  });
  final Set<_ActionContextRequirement> requirements;
  final _KnownJsonShape knownShape;
}

final class _InvalidActionValue extends _StaticActionResolution {
  const _InvalidActionValue();
}
```

`_KnownJsonShape` should distinguish at least unknown binding value, scalar, list, and object. A deferred descendant does not erase the known shape of its containing list/object.

Resolution rules:

- every literal, including null, is known;
- a state binding that resolves is known, including when its value is null;
- a state binding using a fallback is known when the fallback is selected, including a null fallback;
- item/event bindings are deferred;
- a list/object is fully known only when all descendants are known; otherwise it is deferred with the union of descendant requirements and the known outer shape;
- malformed bindings return `_InvalidActionValue`; do not attempt resolution or add misleading follow-on type diagnostics.

Type-check every `_KnownActionValue`, including null. For deferred composites, still validate every statically known fact:

- reject a known object/list outer shape when the capability expects a scalar;
- for `list<T>`, validate each statically known element against `T` and defer only unknown elements;
- broad object arguments can validate only the outer object shape until field schemas exist.

Preserve `action.argumentType`. Preserve the existing structural-diagnostics guard, or use `_InvalidActionValue`, so one malformed/missing binding does not receive a second misleading type error.

Required tests:

- non-nullable string argument with literal null fails;
- non-nullable object argument bound to known null state fails;
- non-nullable argument using a null fallback fails;
- nullable argument with literal null succeeds;
- valid deferred item/event values compile when their use-site contexts are legal;
- a deferred argument does not suppress diagnostics for another known-invalid argument.
- a required string receiving an object with one deferred child fails;
- `list<string>` containing one known integer and one deferred element fails for the known integer.

Important: do not “fix” `GenuxValueType.jsonScalar` merely because `_isJsonScalar` includes null. `GenuxValueType.accepts` already handles nullability before switching on kind. Add regression tests (`jsonScalar` rejects null; `nullableJsonScalar` accepts null) if this area is touched, but no production change is currently required there.

### A4. Validate fallback branches independently

Primary file:

- `lib/src/validation/document_validator.dart`

Node bindings:

- For every non-writable binding with a fallback, validate the fallback type and constraint even when the primary state path currently exists.
- Item-binding fallbacks are statically known and must also be validated.
- Writable channels keep `binding.stateFallback`; do not add duplicate fallback diagnostics for that same invalid construct.
- Do not validate the selected fallback twice when the primary path is missing.

Use diagnostics:

```text
binding.fallbackType
binding.fallbackConstraint
```

Use the exact node fallback location:

```text
/nodes/<escaped-node-id>/bind/<escaped-channel-name>/fallback
```

Run fallback checking only after the component channel, source, pointer, and binding shape are valid. Avoid cascades such as reporting both `binding.eventInNode` and `binding.fallbackType` for one construct.

Action arguments:

- When the top-level argument is a binding with a fallback, validate that fallback against the capability argument definition, including deferred item/event bindings.
- Locate the diagnostic at `/actions/<action>/args/<arg>/fallback`.
- Use `action.argumentType` for a type mismatch; the precise location already identifies the fallback branch.
- Nested binding fallback types cannot be validated beyond JSON shape until object field schemas exist.

Required tests:

- an existing valid state path with an invalid fallback still fails;
- item-bound Text with numeric fallback fails `binding.fallbackType`;
- fallback violating a channel maximum fails `binding.fallbackConstraint`;
- event-bound string action argument with numeric fallback fails;
- nullable action argument with null fallback succeeds;
- writable fallback still reports only `binding.stateFallback`.

### A5. Make event-context presence explicit

Primary files:

- `lib/src/model/evaluation_context.dart`
- `lib/src/runtime/surface_session.dart`

Use an internal absence sentinel so an explicitly supplied null remains present:

```dart
final class _AbsentEventPayload {
  const _AbsentEventPayload();
}

const _absentEventPayload = _AbsentEventPayload();

final class GenuxEvaluationContext {
  const GenuxEvaluationContext({
    this.itemKey,
    this.itemIndex,
    this.itemData,
    Object? eventPayload = _absentEventPayload,
  }) : _eventPayload = eventPayload;

  final Object? _eventPayload;

  bool get hasEventContext =>
      !identical(_eventPayload, _absentEventPayload);

  Object? get eventPayload => hasEventContext ? _eventPayload : null;

  GenuxEvaluationContext withEventPayload(Object? payload) =>
      GenuxEvaluationContext(
        itemKey: itemKey,
        itemIndex: itemIndex,
        itemData: itemData == null ? null : _deepFreezeObject(itemData!),
        eventPayload: _deepFreezeJson(payload),
      );
}
```

The helper names above are illustrative; use one shared, tested JSON-freezing utility and avoid duplicating compiler-private freeze functions.

Keep `toEventMap()` behavior:

- absent source throws `StateError`;
- present null returns `{ 'data': null }`;
- fallback is used only when a pointer is missing inside an available source, not when the source context itself is absent.

Change `GenuxSurfaceSession.emit` to use:

```dart
final augmentedContext = context.withEventPayload(payload);
```

At the session boundary, validate the incoming payload, create one deeply frozen `frozenPayload`, use that value for both event-context resolution and `GenuxActionInvocation.payload`, and ensure resolved object/list arguments remain frozen snapshots. A dispatcher must not be able to mutate caller-owned event data or item-local maps during or after asynchronous dispatch. Prefer one shared internal JSON-freeze helper over several subtly different implementations. CollectionView item context should likewise expose an unmodifiable, deeply frozen item object. If this is intentionally split out of Package A, document the remaining shallow-immutability risk explicitly and do not describe the context as deeply immutable.

Required tests in `test/surface_session_test.dart`:

- `source:event`, path `/data`, resolves an explicit null and dispatches it;
- resolving the same compiled value without event context still throws;
- fallback does not replace an explicitly present null;
- a nullable ComboBox-style changed event dispatches `{value: null}`.
- attempting to mutate a captured object/list payload or resolved invocation value fails, and later observations remain unchanged.

### A6. Correct the shipped customer-list fixture and prove it end to end

Primary files:

- `assets/views/customer-list.genux.json`
- new `test/collection_view_test.dart`

Change the action to consume the CollectionView event payload:

```json
"selectCustomer": {
  "capability": "customer.select",
  "args": {
    "customerId": {
      "$bind": {"source": "event", "path": "/data/key"}
    },
    "customerName": {
      "$bind": {"source": "event", "path": "/data/data/name"}
    }
  }
}
```

Do not change the event payload shape in this package. Increment the fixture revision from 1 to 2 because its published behavior changed.

The widget test must:

1. read the actual fixture from disk;
2. compile it with `createGenuxCoreV2Catalog()` and a typed `customer.select` capability;
3. fail clearly if compilation is not `GenuxCompileSuccess`;
4. activate a session that records invocations;
5. pump `GenuxSurfaceHost` inside `SizedBox(width: 800, height: 600)`;
6. assert `tester.takeException()` is null;
7. tap `Mya Chen`;
8. assert exactly one `customer.select` invocation;
9. assert arguments equal `{customerId: '1001', customerName: 'Mya Chen'}`;
10. assert payload includes `key == '1001'`, `index == 0`, and the complete selected data object.

Also cover keyboard activation with Enter or Space and ensure one activation produces one dispatch.

### A7. Fix state subscriptions and stable item identity

Primary files:

- `lib/src/flutter/surface_host.dart`
- `lib/src/flutter/collection_view_renderer.dart`
- `test/collection_view_test.dart`

#### Source-aware subscriptions

In `_GenuxNodeHostState._subscribe`, subscribe only bindings with `source == GenuxBindingSource.state`. Deduplicate identical pointers before calling the store.

Either import `../model/json_pointer.dart` for an explicit `GenuxJsonPointer` collection type or let the collection type be inferred; Dart imports are not transitive through `document_compiler.dart`.

Conceptually:

```dart
final pathsBySource = <String, GenuxJsonPointer>{
  for (final binding in widget.node.bindings.values)
    if (binding.source == GenuxBindingSource.state)
      binding.pointer.source: binding.pointer,
};

if (pathsBySource.isEmpty) return;
```

Regression test:

- render one or more template nodes bound to item `/data/name`;
- include unrelated global state at the same pointer `/data/name`;
- mutate only the unrelated global pointer;
- assert item-only renderers do not rebuild;
- mutate the collection items path;
- assert CollectionView rebuilds and visible text updates.

#### Typed stable identities

Do not normalize keys with raw `toString()`.

Recommended private identity:

```dart
typedef _ItemIdentity = (Type, Object);
```

Required behavior:

- identity is `(keyValue.runtimeType, keyValue)`;
- use `Set<_ItemIdentity>` for duplicate detection;
- use that exact same `_ItemIdentity` value for duplicate detection, `ValueKey<_ItemIdentity>` on the outermost widget returned by `itemBuilder`, and identity-to-index lookup;
- remove the nested InkWell key;
- build an identity-to-index map;
- provide `findChildIndexCallback` for list and grid builders, returning the mapped index only for a matching `ValueKey<_ItemIdentity>` and `null` for unknown/nonmatching keys;
- use an unambiguous type-prefixed string only where the current `buildItemTemplate` API still requires `String instanceKey`, for example `s:${jsonEncode(value)}`, `i:<value>`, `d:<value>`, or `b:<value>`; add `dart:convert` if `jsonEncode` is used;
- set `primary: false` on the nested list/grid scroll views.

Required tests:

- integer `1` and string `"1"` are distinct identities;
- exact duplicate typed keys produce a bounded CollectionView error;
- stateful row state remains attached to the same key after list reorder;
- repeat reorder coverage for grid layout.

Use a minimal test catalog or an internal CollectionView renderer plus a custom stateful probe for the reorder tests. Existing built-in repeated controls are not a suitable probe because writable item bindings are deliberately unsupported. Pump `GenuxSurfaceHost` directly for build-count/subscription assertions; `WorkspacePage` has its own broad inspector subscription and would invalidate those counts.

For keyboard coverage, explicitly move/request focus to the intended row and assert it owns primary focus before sending Enter/Space. Use a fresh session or clear recorded invocations between pointer and keyboard cases.

### A8. Give the showcase a real bounded path to customer.list

Primary files:

- `lib/showcase/pages/workspace_page.dart`
- `assets/views/customer-edit.genux.json`
- `test/widget_test.dart`

The preview needs a bounded path for surfaces that own a lazy viewport. Do not “solve” the problem by setting CollectionView `shrinkWrap: true`, because that defeats lazy collection behavior.

Recommended temporary showcase behavior:

- when the active compiled document contains `CollectionView`, wrap its `GenuxSurfaceHost` in a finite showcase viewport, initially about 500 logical pixels high;
- keep existing intrinsic-height handling for the editor, summary, and Component Lab—Component Lab is intentionally much taller and a tight height would overflow it;
- branch only in showcase presentation code and detect the generic component/viewport need, not a business view code;
- keep CollectionView `primary: false`;
- remove this detection once a catalog-level `Screen`/viewport contract exists;
- test narrow and wide windows.

Expose the fixture through the existing semantic navigation mechanism:

- add action `openCustomerList` with `view.open`, `viewCode: customer.list`;
- add `customerListButton` to the Form actions;
- label it `Open customer list`;
- increment `customer.edit` revision from 6 to 7.

Showcase widget tests:

- open Customer List from the editor at a wide window size;
- repeat at a narrow window size;
- assert no RenderFlex/unbounded-layout exception;
- assert the customer data renders and the first row is interactive;
- tap a row, switch to the visible Actions inspector tab, and assert rendered `customer.select` plus its arguments; do not reach into `_actions` private state from the test;
- navigate back and verify the previous editor session/state remains intact.

The five-row fixture may fit without scrolling because five rows at 88 pixels are only 440 pixels. Test scrolling separately in `collection_view_test.dart` with a smaller bounded viewport or a generated larger item list; assert that an off-screen item becomes visible after a drag. Do not introduce `if (viewCode == 'customer.list')` into the reusable Genux runtime.

## 6. Package A acceptance gate

Package A is complete only when all of the following are true:

- cyclic and self-cyclic documents return compile failures without an uncaught exception or stack overflow;
- known null values are type-checked;
- every applicable fallback branch is statically checked;
- item-dependent actions are valid at every event use site;
- an explicit null event payload is distinguishable from absent event context;
- the corrected customer-list fixture compiles under core v2;
- pointer tap and keyboard activation dispatch the selected customer exactly once;
- customer-list renders inside the real showcase without an unbounded flex error;
- item-only bindings produce no global-state subscription;
- list/grid stable keys survive reorder;
- existing v1 wire documents remain schema/source compatible except documents that were previously invalid but slipped to runtime; report the public API semantic changes listed below;
- no product-, sales-, customer-, or detail-specific Flutter component is added;
- analyzer and the entire test suite pass.

Observable compatibility changes that Opus must report:

- documents with statically invalid nulls, fallbacks, or item-action use sites will now fail compilation instead of failing after interaction;
- `const GenuxEvaluationContext(eventPayload: null)` changes from “no event context” to “event context containing null”; omission still means absent;
- dispatch contexts and invocation JSON values become frozen snapshots rather than retaining mutable caller-owned collections;
- integer `1` and string `"1"` become distinct CollectionView identities instead of a duplicate collision;
- customer-list revision becomes 2 and, if showcase navigation is added, customer-edit revision becomes 7;
- new diagnostics and their locations may affect tooling that asserts exact diagnostic sets;
- Package A does not change the schema string, catalog versions/checksums, or the existing state/item/event JSON grammar.

Run and report:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub test/document_validator_hardening_test.dart
flutter test --no-pub test/surface_session_test.dart
flutter test --no-pub test/collection_view_test.dart
flutter test --no-pub test/widget_test.dart
flutter test --no-pub
git diff --check
git status --short
```

If formatting check fails, run `dart format` on only the files changed by this task and repeat the checks.

## 7. Documentation updates in Package A

Update these documents with the code, not as a separate speculative pass:

- `README.md`
- `docs/adr-evaluation-context.md`
- `docs/binding-model.md`
- `docs/handover-dataview-foundation.md`
- `docs/dataview-components.md`
- `docs/protocol-v1-draft.md`
- `docs/architecture.md`
- `docs/component-lab.md`

Required corrections:

- `binding-model.md` must describe explicit `state`, `item`, and `event` sources;
- the ADR must not claim untested lexical action behavior;
- remove references to nonexistent tests;
- do not hardcode an obsolete test count;
- state that widget construction is lazy but current collection preprocessing is O(total items);
- label 10k/60fps statements as targets until benchmark evidence exists;
- state accurately that Component Lab excludes CollectionView and the customer-list fixture covers it;
- document the event wrapper: `source:event` sees `{data: payload}`.
- update every reference to the changed `customer.edit` and `customer.list` revisions.

Also add the existing fixture token `labelSmall` to the Material Text renderer (`theme.labelSmall`) and add a focused test; do not silently fall back to `bodyLarge`. Do not change the catalog checksum or introduce a style-token manifest in Package A. Enumerating all presentation tokens belongs in a later catalog release.

## 8. Stop-and-discuss gates after Package A

Do not implement these as incidental refactors. Present the listed choices to the user, give a recommendation, and wait for direction.

### Gate B1. General template-local scopes

Problem: `GenuxEvaluationContext` has only one item frame. Nested collections replace the outer record, and `buildItemTemplate` is CollectionView-specific.

Recommended direction:

```dart
final class GenuxLocalFrame {
  GenuxLocalFrame({
    required this.ownerNodeId,
    required this.kind,
    required Map<String, Object?> values,
  }) : values = deepFreezeJsonObject(values);

  final String ownerNodeId;
  final GenuxContextKind kind;
  final Map<String, Object?> values;
}

final class GenuxEvaluationContext {
  final List<GenuxLocalFrame> frames;
  // explicit event-presence representation remains separate
}
```

Do not simply replace the current public `buildItemTemplate(String, String, GenuxEvaluationContext)` method. `GenuxComponentScope` is a public abstract interface, so removing a method, adding a required method, or changing `String instanceKey` to `Object` breaks external implementations.

First introduce stacked internals while preserving the current API. For a future package/API major—or through a separately versioned template-scope interface—the safer generic operation is conceptually:

```dart
Widget renderTemplate(
  String slotName, {
  required Object instanceKey,
  required GenuxLocalFrame local,
});
```

The host, not the renderer, appends `local` to its current context. A renderer must not supply a replacement complete context because that could accidentally discard outer frames. Keep the old method as a compatibility adapter until a declared package/API major permits removal.

Recommended compatible binding syntax:

```json
{"source": "item", "path": "/data/name"}
```

continues to mean nearest item frame. Add optional owner selection:

```json
{
  "source": "item",
  "scope": "salesCollection",
  "path": "/data/customerName"
}
```

The `scope` identifies the ancestor context-producing node ID, not a dynamic item key.

Exact propagation invariants:

- frame maps/lists are copied and deeply frozen when captured;
- ordinary slots retain the same frame list;
- a contextual slot appends exactly one frame;
- unscoped lookup walks newest to oldest;
- scoped lookup names an ancestor producer visible on every lexical path;
- event overlay never becomes a persistent local frame and never removes local frames;
- a lexically promised but missing runtime frame is an invariant failure, not a fallback case.

Internal nearest-item stacking can preserve the existing wire grammar. The new `scope` field must use an explicit protocol feature or schema revision: older strict `aix.genux/1.0` parsers reject unknown binding fields, and a catalog version cannot change protocol grammar. Discuss the exact versioning mechanism before implementation.

### Gate B2. Writable repeated-item fields

Problem: state-direction channels accept only fixed state pointers. A TextField in a repeated template cannot safely write to the current keyed record.

Recommendation: do not concatenate JSON strings into state paths and do not mutate the item map directly. Split compile-time source information from per-row runtime identity:

```dart
final class GenuxCompiledItemWriteSource {
  final GenuxJsonPointer collectionPath;
  final String keyField;
}

final class GenuxWritableItemTarget {
  final GenuxCompiledItemWriteSource source;
  final int indexHint;
  final Object keyValue;
}
```

The compiler can produce only `GenuxCompiledItemWriteSource`. CollectionView creates `GenuxWritableItemTarget` for each rendered instance because index and key are runtime values.

At transaction time, verify the key at the index hint, fall back to a bounded stable-key lookup if required, and then write a validated relative `/data/...` path atomically. Reject key mutation, whole-row replacement, missing/duplicate identities, transformed collections, and literal/event-derived collections.

Controls currently write and then emit through the pre-write component scope. Before resolving an action after a writable item change, refresh writable frames from current state using the typed stable key. If the identity is missing or duplicated, fail dispatch; never read stale item data or target a different row. Event bindings remain the preferred source for the immediate changed value.

This requires a protocol/runtime feature gate and a security review. Discuss it separately.

### Gate B3. Generic page and viewport contract

Problem: a JSON author cannot reliably know whether the host already owns scrolling. `Expanded` is exposed without parent-placement constraints.

Recommended catalog patterns:

- `Screen` or `Viewport`: owns safe area and bounded body;
- `ScrollPage`: scrolls ordinary content;
- `CollectionPage`: provides a sliver/lazy collection body;
- layout placement metadata so `Expanded` is valid only in `Row.children` or `Column.children`.

Do not add `ProductPage`. A product page is JSON configuring the generic page/record/collection patterns.

Discuss whether `Expanded` remains a free node with allowed-parent metadata or becomes slot metadata on Row/Column.

### Gate B4. Renderer catalog extensibility

Problem: `createGenuxMaterialCatalog` hardcodes private registrations, while `GenuxFlutterCatalog` requires complete coverage. Applications cannot add a generic native pattern while reusing built-ins.

Safe additive option:

```dart
GenuxFlutterCatalog createGenuxMaterialCatalog(
  GenuxCatalog catalog, {
  Iterable<GenuxFlutterRegistration> additionalRegistrations = const [],
})
```

Duplicates must fail rather than override silently. A more durable design is immutable registration bundles keyed by `(componentCode, componentVersion)` with `extend()`.

Discuss the public API before implementation.

### Gate B5. Exact catalog identity and multi-release support

Current validation accepts an older document catalog version when the runtime catalog version is newer, and skips checksum comparison in that case. The documented model implies exact `(id, version, checksum)` identity.

Changing this immediately breaks the showcase because `customer-edit` declares core v1 while `ShowcaseRuntime` supplies core v2.

Choose explicitly:

1. migrate every active fixture to core v2 and require an exact triple; or
2. add a catalog/compiler/Flutter-renderer resolver keyed by the exact triple so cached v1 documents still run.

Recommendation: use exact triples. If backward compatibility matters, retain each exact catalog rather than treating version integers as automatically compatible.

### Gate B6. Pure transforms and conditional presentation

Generic product/sales/detail JSON will need formatting, localization, visibility, and small derived values. Add a typed, allowlisted transform catalog, not a general expression language.

Examples to discuss:

- named formatters: currency, date/time, decimal, percent;
- localization tokens plus arguments;
- explicit `Visibility`/`When` components bound to booleans;
- server/preparation-layer computation for business rules.

Keep business calculations and authorization out of UI expressions.

### Gate B7. State and collection performance redesign

Do this after correctness is covered.

Recommended sequence:

1. replace full-state cloning with path-copy/structural sharing;
2. preserve untouched branch identity;
3. cache CollectionView validation by item-list identity;
4. avoid copying maps that are already immutable and correctly typed;
5. add deterministic rebuild/scan counters in unit tests;
6. add profile-mode 1k/10k list and grid benchmarks on a declared reference device.

Preserve existing transaction semantics: atomic rejection, versioning, write order, dirty conflicts, changed paths, and one notification per commit.

Do not set performance thresholds from intuition. Record the device, build mode, scenario, frame timings, and memory methodology.

## 9. Explicitly out of scope for Package A

- `ProductPage`, `SalesPage`, `CustomerEditor`, or other domain-native widgets;
- reusable JSON partial expansion in the mobile runtime;
- arbitrary expression evaluation;
- inline editable CollectionView rows;
- named nested context scopes;
- state-store structural-sharing rewrite;
- 10k performance optimization or benchmark claims;
- canonical catalog manifest generation;
- exact catalog migration;
- renderer plug-in API redesign;
- paging, pull-to-refresh, selection model, grouping, tree views, or sliver composition;
- endpoint, SQL, route, or executable-code fields in JSON.

## 10. File map

Core model and compiler:

- `lib/src/model/document.dart`
- `lib/src/model/evaluation_context.dart`
- `lib/src/model/json_pointer.dart`
- `lib/src/catalog/catalog.dart`
- `lib/src/catalog/value_type.dart`
- `lib/src/compiler/document_compiler.dart`
- `lib/src/validation/document_validator.dart`

Runtime and state:

- `lib/src/runtime/surface_session.dart`
- `lib/src/runtime/view_coordinator.dart`
- `lib/src/state/surface_store.dart`

Flutter:

- `lib/src/flutter/component_scope.dart`
- `lib/src/flutter/surface_host.dart`
- `lib/src/flutter/collection_view_renderer.dart`
- `lib/src/flutter/flutter_catalog.dart`
- `lib/src/flutter/material_catalog.dart`

Showcase and fixtures:

- `lib/showcase/showcase_runtime.dart`
- `lib/showcase/pages/workspace_page.dart`
- `assets/views/customer-edit.genux.json`
- `assets/views/customer-list.genux.json`

Tests:

- `test/document_compiler_test.dart`
- `test/surface_session_test.dart`
- `test/surface_host_test.dart`
- `test/widget_test.dart`
- new `test/document_validator_hardening_test.dart`
- new `test/collection_view_test.dart`

## 11. Opus working protocol

1. Read this handover and the evaluation-context ADR completely.
2. Inspect the current worktree; do not assume the baseline is unchanged.
3. Restate Package A and any proposed deviations before editing.
4. Ask the user before changing a stop-and-discuss item.
5. Implement in small reviewable groups with tests next to behavior.
6. Do not weaken a validator merely to make a fixture compile; correct the fixture or contract.
7. Do not catch and discard action failures in tests. Assert the concrete `GenuxActionDispatchResult` or recorded invocation.
8. Use actual fixtures for at least one end-to-end test; use minimal inline documents for validator edge cases.
9. Keep diagnostics deterministic and assert both code and location where relevant.
10. Run targeted tests after each group and the full gate before handoff.
11. Report changed files, compatibility changes, test evidence, and unresolved decisions.

## 12. Questions Opus should raise with the user

These questions are useful, but they do not block Package A unless the answer changes its scope:

1. Should Package A land as one review or be split into validator/runtime and Flutter/showcase reviews?
2. May `customer.edit` be changed to expose the customer-list demo, including revision 7?
3. After Package A, is nested named local context or exact catalog compatibility the next priority?
4. Must cached core-v1 documents remain executable, or may active fixtures migrate to core v2?
5. For future inline row editing, should Genux initially support only collections directly bound to state?
6. Which device and frame budget should define the first performance baseline?

Default recommendations if the user delegates the choice:

- split Package A into two review checkpoints but keep one coherent branch;
- expose customer-list through the showcase;
- implement named read-only scopes before writable row bindings;
- retain exact old catalogs if published/cached documents must survive;
- restrict the first writable-row design to directly state-bound keyed collections;
- benchmark in profile mode on one named mid-range physical device before setting thresholds.

## 13. Final handoff format expected from Opus

Opus should finish its coding turn with:

1. outcome first;
2. changed-file summary grouped by compiler/runtime/Flutter/docs;
3. observable compatibility changes;
4. exact test/analyzer commands and results;
5. any benchmark results clearly separated from assumptions;
6. remaining stop-and-discuss decisions;
7. confirmation that no domain-specific native page component or executable JSON feature was introduced.
