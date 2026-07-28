# ADR: Evaluation Context and Explicit Binding Sources

Status: Implemented  
Date: 2026-07-28

## Context

The DataView foundation requires repeated item templates where bindings resolve against item-local data rather than only persistent surface state. The v1 binding model supports only state bindings via RFC 6901 JSON Pointers.

The experiment attempted to merge item locals into state, which violates the separation between persistent transactional state and ephemeral render context.

## Decision

### 1. First-class evaluation context

Introduce `GenuxEvaluationContext` as an immutable read-only container for local values available during one render instance. The context is separate from `GenuxStateStore` and never merged into persistent state.

```dart
enum GenuxBindingSource {
  state,    // persistent surface state
  item,     // item-template local data
  event,    // event payload (action arguments only)
}

final class GenuxEvaluationContext {
  const GenuxEvaluationContext({
    this.itemKey,
    this.itemIndex,
    this.itemData,
    this.eventPayload,
  });

  final String? itemKey;
  final int? itemIndex;
  final Map<String, Object?>? itemData;
  final Object? eventPayload;
  
  static const empty = GenuxEvaluationContext();
}
```

### 2. Explicit binding sources in wire protocol

Extend `aix.genux/1.0` to support explicit source objects alongside the shorthand state pointer string:

**State binding (backward compatible shorthand):**
```json
"text": "/customers/name"
```

**Item binding (explicit source):**
```json
"text": {"source": "item", "path": "/data/name"}
```

**Event binding (action arguments only):**
```json
"customerId": {"$bind": {"source": "event", "path": "/data/id"}}
```

The shorthand string form resolves to `source: "state"` for backward compatibility.

### 3. Item context structure

Item-template slots introduce a fixed structure:

```json
{
  "key": "1001",          // stable item identity from itemKey path
  "index": 0,             // current array position
  "data": { ... }         // the item object from items array
}
```

Bindings can reference:
- `/key` → item stable key
- `/index` → item index
- `/data/fieldName` → item field

### 4. Compiled binding representation

Extend `GenuxCompiledBinding` to carry source information:

```dart
final class GenuxCompiledBinding {
  const GenuxCompiledBinding({
    required this.name,
    required this.definition,
    required this.source,
    required this.pointer,
    this.fallback,
    this.hasFallback = false,
  });

  final String name;
  final GenuxChannelDefinition definition;
  final GenuxBindingSource source;
  final GenuxJsonPointer pointer;
  final Object? fallback;
  final bool hasFallback;

  Object? read(Map<String, Object?> state, GenuxEvaluationContext context);
  bool get isWritable;
}
```

### 5. Validation rules

Compiler validation enforces:

- Item bindings are legal only inside item-template slot descendants
- Event bindings are legal only in action arguments
- State bindings can appear anywhere
- Writable channels (state direction) can only bind to `source: "state"`
- A shared action referenced from incompatible contexts (item and non-item) is rejected
- Unknown sources are rejected at compile time

### 6. Slot context contracts

Extend `GenuxSlotDefinition` to declare introduced context:

```dart
final class GenuxSlotDefinition {
  const GenuxSlotDefinition({
    required this.minChildren,
    required this.maxChildren,
    this.introducesContext = GenuxContextKind.none,
  });

  final int minChildren;
  final int maxChildren;
  final GenuxContextKind introducesContext;
}

enum GenuxContextKind {
  none,
  item,      // introduces item context {key, index, data}
}
```

CollectionView's `itemTemplate` slot declares `introducesContext: GenuxContextKind.item`.

### 7. Runtime resolution

Binding resolution checks the source:

```dart
Object? read(Map<String, Object?> state, GenuxEvaluationContext context) {
  final source = switch (this.source) {
    GenuxBindingSource.state => state,
    GenuxBindingSource.item => {
      'key': context.itemKey,
      'index': context.itemIndex,
      'data': context.itemData,
    },
    GenuxBindingSource.event => {
      'data': context.eventPayload,
    },
  };
  
  final result = pointer.read(source);
  return result.exists ? result.value : (hasFallback ? fallback : throw ...);
}
```

Item and event sources throw if context is missing at resolution time (defensive check for compiler bugs).

### 8. Action argument resolution

Extend action resolution to accept event payload:

```dart
Map<String, Object?> resolveArgs(
  Map<String, Object?> state,
  GenuxEvaluationContext context,
)
```

This allows action arguments to bind to item context or event payload.

### 9. Template rendering API

Extend `GenuxComponentScope` for lazy template rendering:

```dart
abstract interface class GenuxComponentScope {
  // ... existing members ...
  
  Widget buildItemTemplate(
    String slotName,
    String instanceKey,
    GenuxEvaluationContext context,
  );
}
```

CollectionView calls this for each visible item with a unique `instanceKey` (derived from stable item key) and evaluation context containing item data.

## Consequences

### Positive

- Item locals and state remain separate and cannot shadow each other
- Binding sources are explicit, lexically validated, and compiled
- One reusable mechanism for item templates, event payloads, and future contexts
- Backward compatible: v1 fixtures continue using string state bindings
- Supports future contexts (tree node, timeline entry, option template) without new binding syntax

### Negative

- Protocol becomes more complex with explicit source objects
- Requires migration for fixtures using item bindings
- Type safety for item data fields remains `list<object>` until MetaX integration

### Migration

Existing `aix.core@1` fixtures remain valid. New `aix.core@2` catalog introduces CollectionView with item-template context. The showcase migrates to core v2 and updates customer-list fixture to use explicit item bindings.

## Stable Item Identity

CollectionView requires a stable item key for:
- Flutter widget keys that preserve stateful descendants across reordering
- Action payload identity
- Accessibility item identity

### Wire contract

```json
{
  "component": "CollectionView",
  "props": {
    "itemKey": "id",        // required: field name in item data
    "layout": "list",       // "list" or "grid"
    "itemHeight": 80        // for list layout
  },
  "bind": {
    "items": "/customers/list"
  },
  "slots": {
    "itemTemplate": ["templateRoot"]
  }
}
```

The `itemKey` property names which field in each item object provides stable identity. Compiler validates:
- `itemKey` is a non-empty string
- Items channel is `list<object>`
- itemTemplate slot has exactly one child

Renderer extracts `item[itemKey]` and uses it for widget keys and payload `key` field.

## Bounded Layout

Flutter lazy scrollables require bounded constraints. Add `Expanded` component to core v2:

```dart
GenuxComponentDefinition(
  code: 'Expanded',
  version: 1,
  properties: const {
    'flex': GenuxPropertyDefinition(
      type: GenuxValueType.integer,
      constraint: GenuxValueConstraint(minimum: 1, maximum: 100),
    ),
  },
  slots: const {
    'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
  },
)
```

Material renderer wraps child in `Expanded(flex: flex ?? 1, child: ...)`.

This allows:
```json
{
  "component": "Column",
  "slots": {
    "children": ["header", "expandedScroll", "footer"]
  }
}

{
  "id": "expandedScroll",
  "component": "Expanded",
  "slots": {
    "child": ["collectionView"]
  }
}
```

## Implementation Notes

- Protocol version remains `aix.genux/1.0` as explicit sources are additive
- Catalog version increments to `aix.core@2`
- Core v1 and v2 catalogs are explicit separate releases
- Tests cover: normal nodes cannot access item context, template descendants can, item locals are not writable, action arguments resolve from originating context
