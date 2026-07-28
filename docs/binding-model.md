# Binding model

Status: implemented v1 foundation. State transactions, path subscriptions,
Flutter component scopes, controlled `ComboBox`, `TextField`, and `Checkbox`
renderers, bounded Form Essentials layout, and Form busy/error/lifecycle behavior
exist. Later controls may extend the contract without introducing a general
binding language.

## Position

Genux adopts the clarity of .NET control contracts without reproducing the .NET
binding runtime.

The useful idea is that a component declares what data it consumes, what state it
can edit, what events it emits, and what children it accepts. The unsuitable parts
for Genux are reflection, string member lookup during rendering, implicit
`DataContext` inheritance, converters everywhere, and mutation hidden inside a
general two-way binding engine.

## Component member kinds

| Kind | Direction | Document source | Example |
| --- | --- | --- | --- |
| property | static configuration | `props` literal | `clearable: false` |
| input | reactive read-only | `props` literal or `bind` path | `items`, `busy` |
| state | reactive read/write | `bind` path | `value` |
| event | component to runtime | `events` action reference | `changed` |
| slot | structural children | `slots` child IDs | `content` |

Direction and type are defined once by the trusted catalog. Documents do not
repeat `OneWay`, `TwoWay`, `SelectedValuePath`, or converter declarations.

## Why binding mode is inferred

An explicit mode is useful in a general reflection system because the engine does
not otherwise know a property's role. Genux owns its catalog, so the role is
already known:

- an `input` can be watched but not written by the component;
- a `state` channel can be watched and updated through a transaction;
- an `event` emits a typed payload; and
- a `slot` contains compiled child nodes.

Rejecting a document that tries to write an input is safer than accepting a
runtime `mode` override. It also keeps CloudX, Aix validation, Dart, and future
GenUI authoring on one contract.

Binding direction is separate from update timing. The intended policy vocabulary
for editable controls and forms is:

- `live`: commit valid edits as the user changes the value;
- `commit`: keep an editing value locally and commit on focus loss or confirmation;
- `explicit`: commit only when the form or control explicitly submits.

Only `live` is implemented by the current v1 editable controls. `commit` and
`explicit` remain deferred contract work; documents cannot select them today.

## Explicit scope

Every v1 binding is an RFC 6901 pointer into the current surface state. There is
no invisible inherited `DataContext`.

```json
"bind": {
  "items": "/lookups/customerTypes",
  "value": "/draft/customerType",
  "busy": "/lookups/customerTypesBusy"
}
```

A future Partial View can declare named input/output parameters, but publication
will resolve them to explicit state paths when flattening the View. Flutter
builders receive compiled pointer handles and typed channel keys, never arbitrary
paths.

## `ComboBox` contract

`ComboBox` is the canonical control name. It takes inspiration from the strong
contract of .NET ComboBox controls but is designed for Flutter and dynamic Aix
schemas.

Released `aix.core@1` slice:

| Member | Kind | Type | Purpose |
| --- | --- | --- | --- |
| `items` | input | `List<ChoiceItem>` | Available normalized choices |
| `value` | state | nullable JSON scalar | Selected stable key |
| `busy` | input | boolean | Lookup progress |
| `enabled` | input | boolean | Interaction state |
| `changed` | event | selected key | Selection committed |

Configuration properties are `clearable` and `placeholder`. When clearable, the
native renderer exposes an explicit no-selection item and commits JSON `null`
before emitting `changed`.

`ChoiceItem.key` is identity. `ChoiceItem.label` is display-only. QueryHub should
normally normalize lookup results into this shape, so documents do not repeat
`DisplayMemberPath` and `SelectedValuePath`.

Editable/local/remote search is intentionally deferred to a new component
contract version. That version can add a `query` state channel plus
`searchChanged`/`openChanged` events only when the native renderer implements the
same behavior. Remote search will remain orchestration, not a network feature
inside `ComboBox`:

```text
query state changes -> searchChanged event -> approved lookup capability
                    -> QueryHub result -> items state transaction
```

Rich option rendering will use a pinned Partial View or trusted option template
after a real use case establishes the contract. Turning every option into an
ordinary node is avoided because it bloats graphs and harms virtualization.
The current native renderer presents `ChoiceItem.label` and respects
`ChoiceItem.disabled`; validated `description`, `group`, `icon`, and `meta`
fields are not yet rendered as nested option content.

## Form Essentials contracts

All contracts below are component version 1 in `aix.core@1`. Properties are
optional unless marked required. Input channels may be literal properties or
bindings; state channels require writable bindings.

### `Form`

| Member | Kind | V1 contract |
| --- | --- | --- |
| `busy` | input | boolean; renderer default is `false` |
| `errors` | input | nullable object containing top-level error entries |
| `submitted` | event | lifecycle intent with no payload |
| `cancelled` | event | lifecycle intent with no payload |
| `content` | slot | 1–100 content nodes |
| `actions` | slot | 0–10 action nodes |

When `busy` is true, the native renderer displays linear progress, fades the Form
subtree, absorbs pointer interaction, releases existing descendant focus, blocks
new descendant focus, and suppresses its keyboard lifecycle events. The state
value does not authorize or cancel server work; it is bounded presentation and
interaction state controlled by the trusted application.

A non-empty `errors` object is rendered as a live-region summary above the Form
content. The recommended shape maps a top-level field or form key to a string or
list of messages, for example:

```json
{
  "name": "A display name is required.",
  "contacts": ["An email or phone number is required."]
}
```

Null, empty-string, and empty-list entries are omitted. Other finite JSON values
are presented as diagnostic text; they are never interpreted as markup, code, or
binding expressions. V1 does not recursively assign nested errors to individual
controls.

While focus is within the Form subtree, Ctrl+Enter or Cmd+Enter emits
`submitted`, and Escape emits `cancelled`. Buttons in the `actions` slot remain
ordinary explicit components: Form does not infer submit/cancel semantics from a
button's position or label. A button must bind its own `pressed` event to the
desired action.

### Controlled `TextField`

| Member | Kind | V1 contract |
| --- | --- | --- |
| `label` | property | string, maximum 256 characters |
| `hint` | property | string, maximum 512 characters |
| `maxLines` | property | integer from 1 through 20; renderer default is 1 |
| `value` | state | required writable string, maximum 16,384 characters |
| `enabled` | input | boolean; renderer default is `true` |
| `readOnly` | input | boolean; renderer default is `false` |
| `errorText` | input | nullable string, maximum 1,024 characters |
| `changed` | event | string payload after a committed edit |
| `submitted` | event | string payload for native field submission |

The editing controller is synchronized from surface state. An accepted user edit
first commits `value` transactionally and then emits `changed`; a rejected write
restores the state value. External state updates refresh the controller while
preserving valid selection and focus. Disabled or read-only fields do not write or
emit editing events.

The current v1 native renderer is live-controlled: it commits on each accepted
change. Form-wide `commit` or `explicit` update policies are deferred to a new
contract version rather than being advertised before coordinated buffering is
implemented.

### `Checkbox`

| Member | Kind | V1 contract |
| --- | --- | --- |
| `label` | property | required string, maximum 256 characters |
| `value` | state | required writable boolean |
| `enabled` | input | boolean; renderer default is `true` |
| `changed` | event | boolean payload after a committed change |

Like `ComboBox` and `TextField`, `Checkbox` emits only after its state transaction
commits. A disabled checkbox cannot write or emit.

### Bounded layout primitives

| Component | Properties | Slot contract |
| --- | --- | --- |
| `Row` | `gap`: 0–128 (default 12); `mainAxisSize`: `min` or `max` (default `max`); `crossAxisAlignment`: `start`, `center`, or `end` (default `center`) | `children`: 1–100 nodes |
| `Card` | `padding`: 0–128 (default 16) | `content`: exactly one node |
| `Divider` | `thickness`: 0.5–16; `indent`: 0–512; `endIndent`: 0–512 | no slots |

These limits are catalog validation rules, so out-of-range values or invalid slot
cardinality are rejected before rendering. MetaX validation execution,
field-to-summary aggregation, automatic submit gating, server-error mapping, and
buffered `commit`/`explicit` update policies remain outside this first slice.

## State transaction semantics

State writes never occur as invisible property assignment. A writable component
channel creates a proposed state transaction.

```text
read old value
-> validate proposed key and binding access
-> atomically commit all writes
-> increment state version once
-> notify intersecting path subscribers once
-> emit typed event
-> resolve action arguments from committed state
```

Required guarantees:

- document revision and local state version are independent;
- transactions are synchronous and cannot nest;
- all paths and values validate before the visible state swaps;
- one invalid write rolls back the whole transaction;
- equal-value writes are a no-op;
- listeners run only after a complete commit;
- one failing listener is isolated and cannot change the commit result or block
  later listeners;
- user writes mark paths dirty;
- remote writes that intersect dirty paths reject by default;
- submit acknowledgement explicitly clears dirty paths; and
- path subscriptions match both ancestors and descendants.

For example, a subscriber to `/draft` is affected by
`/draft/customerType`, and a subscriber to `/draft/customerType` is affected by
replacing `/draft`.

## Translation from familiar .NET concepts

| .NET concept | Genux equivalent |
| --- | --- |
| `ItemsSource` | typed `items` input channel |
| `SelectedValue` | typed `value` state channel |
| `DisplayMemberPath` | normalized `ChoiceItem.label` |
| `SelectedValuePath` | normalized `ChoiceItem.key` |
| `INotifyPropertyChanged` | versioned path-aware state transaction |
| `ObservableCollection` | keyed collection state plus typed patches later |
| `ICommand` | semantic capability action |
| `ValidationRule` | MetaX/server rule plus trusted client rule |
| `UpdateSourceTrigger` | `live` now; `commit` or `explicit` in a later contract |
| `DataContext` | explicit surface or Partial View scope |
| `IValueConverter` | preferably normalized data; later named pure transforms |

## Deliberately absent from v1

- arbitrary element-to-element bindings;
- `RelativeSource` traversal;
- multibinding;
- inline arithmetic or condition expressions;
- runtime reflection;
- arbitrary converters or formatter code;
- network requests inside controls; and
- actions that mutate state without a transaction.

If a repeated real-world requirement needs derived state, the preferred order is:
normalize it in QueryHub, model it as explicit state, implement it inside a trusted
semantic component, then consider a small allowlisted pure transform catalog.
