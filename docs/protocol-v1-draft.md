# `aix.genux/1.0` runtime snapshot

Status: implemented draft. Parsing, semantic validation, compilation,
transactional state, capability dispatch, the ten-component Form Essentials
renderer slice, one-document-per-View MultiView coordination, and a full-catalog
native Component Lab exist. The contract still has no compatibility promise
until an explicit v1 release is declared.

This is the deterministic inner runtime document delivered to Genux. It is not
the QueryHub transport envelope, relational authoring format, or an A2UI dialect.

## Example

```json
{
  "schema": "aix.genux/1.0",
  "view": {
    "id": "1001",
    "code": "customer.edit",
    "revision": 6,
    "kind": "view"
  },
  "catalog": {
    "id": "aix.core",
    "version": 1,
    "checksum": "sha256:df13b4276c7e3f607524c4bc7e8b82d0fda561d610ac73013341794fa2e5de9d"
  },
  "root": "customerForm",
  "state": {
    "draft": {
      "name": "Mya",
      "customerType": 2,
      "marketingOptIn": false
    },
    "lookups": {
      "customerTypes": [
        {"key": 1, "label": "Retail"},
        {"key": 2, "label": "Business"},
        {"key": 3, "label": "Internal", "disabled": true}
      ]
    },
    "ui": {"saving": false}
  },
  "actions": {
    "openComponentLab": {
      "capability": "view.open",
      "args": {"viewCode": "component.lab"}
    },
    "openSummary": {
      "capability": "view.open",
      "args": {"viewCode": "customer.summary"}
    },
    "customerTypeChanged": {
      "capability": "customer.type.changed",
      "args": {"value": {"$bind": "/draft/customerType"}}
    },
    "saveCustomer": {
      "capability": "customer.save",
      "args": {"customer": {"$bind": "/draft"}}
    }
  },
  "nodes": [
    {
      "id": "customerForm",
      "component": "Form",
      "version": 1,
      "bind": {"busy": "/ui/saving"},
      "slots": {
        "content": ["heading", "intro", "sectionDivider", "profileCard"],
        "actions": ["componentLabButton", "summaryButton", "saveButton"]
      }
    },
    {
      "id": "heading",
      "component": "Text",
      "version": 1,
      "props": {"text": "Edit customer", "style": "titleLarge"}
    },
    {
      "id": "intro",
      "component": "Text",
      "version": 1,
      "props": {
        "text": "This form is compiled from a published Genux snapshot.",
        "style": "bodySmall"
      }
    },
    {
      "id": "sectionDivider",
      "component": "Divider",
      "version": 1,
      "props": {"thickness": 1}
    },
    {
      "id": "profileCard",
      "component": "Card",
      "version": 1,
      "props": {"padding": 20},
      "slots": {"content": ["profileFields"]}
    },
    {
      "id": "profileFields",
      "component": "Column",
      "version": 1,
      "props": {
        "gap": 16,
        "crossAxisAlignment": "stretch",
        "mainAxisSize": "min"
      },
      "slots": {
        "children": ["customerName", "customerType", "marketingOptIn"]
      }
    },
    {
      "id": "customerName",
      "component": "TextField",
      "version": 1,
      "props": {
        "label": "Customer name",
        "hint": "Enter a display name",
        "maxLines": 1
      },
      "bind": {"value": "/draft/name"},
      "events": {"submitted": "saveCustomer"}
    },
    {
      "id": "customerType",
      "component": "ComboBox",
      "version": 1,
      "props": {
        "clearable": false,
        "placeholder": "Customer type"
      },
      "bind": {
        "items": "/lookups/customerTypes",
        "value": "/draft/customerType"
      },
      "events": {"changed": "customerTypeChanged"}
    },
    {
      "id": "marketingOptIn",
      "component": "Checkbox",
      "version": 1,
      "props": {"label": "Marketing consent"},
      "bind": {"value": "/draft/marketingOptIn"}
    },
    {
      "id": "componentLabButton",
      "component": "Button",
      "version": 1,
      "props": {
        "label": "Open Component Lab",
        "variant": "secondary"
      },
      "events": {"pressed": "openComponentLab"}
    },
    {
      "id": "summaryButton",
      "component": "Button",
      "version": 1,
      "props": {
        "label": "Open customer summary",
        "variant": "secondary"
      },
      "events": {"pressed": "openSummary"}
    },
    {
      "id": "saveButton",
      "component": "Button",
      "version": 1,
      "props": {
        "label": "Dispatch customer.save",
        "variant": "primary"
      },
      "bind": {"busy": "/ui/saving"},
      "events": {"pressed": "saveCustomer"}
    }
  ]
}
```

The executable fixtures are
[`customer.edit` revision 6](../assets/views/customer-edit.genux.json),
[`customer.summary` revision 1](../assets/views/customer-summary.genux.json), and
[`component.lab` revision 1](../assets/views/component-lab.genux.json).
The Component Lab contains 43 nodes and 13 actions, renders all ten component
types, and exercises all 47 top-level catalog properties, channels, events, and
slots.

## Inner document

| Field | Contract |
| --- | --- |
| `schema` | Exact wire family and version. V1 is `aix.genux/1.0`. |
| `view` | Stable published View identity and revision. |
| `catalog` | Exact immutable Flutter catalog release and required checksum. |
| `root` | ID of the single root node. |
| `nodes` | Flat component instances with stable IDs. |
| `state` | Initial JSON state for this authorized runtime snapshot. |
| `actions` | Named semantic capabilities referenced by component events. |

`catalog.version` is a positive integer release identifier. Comparisons are exact
integer comparisons; it is not a semantic-version string. A separate human label
such as `1.0 Preview` may be carried by catalog authoring or release metadata, but
it is not used for runtime compatibility.

Database IDs are encoded as strings where they can exceed JavaScript's exact
integer range. Transport status, ETag, session, DomainX scope, tracing, cache age,
and QueryHub request metadata stay outside this document.

### QueryHub outer envelope draft

QueryHub may carry the complete Genux document inside Aix's compact transport
envelope. The current shape under discussion is:

```json
{
  "s": 200,
  "vs": "20260728143000000",
  "vm": {"ui": 17},
  "r": {
    "gx": "<complete aix.genux/1.0 document>",
    "gh": "sha256:<runtime-snapshot-hash>",
    "gr": 6
  }
}
```

Here `gx` denotes the complete document shown above; the string is only a compact
placeholder for this draft. `gh` is the delivered snapshot hash and `gr` is its
serving revision. Final field meanings and cache semantics belong to the QueryHub
transport contract, not the inner Genux schema.

Authentication, session identity, DomainX scope, request correlation, transport
status, and cache metadata remain trusted outer/request context. They must not be
copied into the Genux document as client-editable authority. QueryHub injects that
context server-side and returns only state and capabilities authorized for it.

Unknown fields are rejected in v1. Future optional data must enter through an
explicit versioned extension point rather than accidental leniency.

## View identity

`view.id` identifies the stable `viewx` row. `view.code` is its immutable machine
code. `view.revision` identifies the published immutable `viewrevx` source.
`view.kind` is `view` or `partial`; normal runtime delivery is a `view`. Included
partials are pinned and flattened during publication.

### One document per navigable View

MultiView does not add a roots array or navigation stack to this schema. Each
navigable View is delivered as its own complete `aix.genux/1.0` document with one
`root`. The pure-Dart `GenuxViewCoordinator` owns a local stack of independently
compiled documents and sessions above this protocol.

Coordinator targets use `(viewCode, instanceKey)` as local runtime identity and
may carry deeply immutable JSON parameters to the trusted source loader. The
instance key and loader parameters are not wire-document fields and are not
automatically merged into `state`. Before activation, the coordinator verifies
that the compiled document's `view.code` matches the requested code and that its
kind is `view`; a delivered `partial` cannot become a stack entry.

## Nodes

Every node contains:

- `id`: stable within the compiled View;
- `component`: catalog component code;
- `version`: exact component contract version;
- optional `props`: static configuration and literal input values;
- optional `bind`: channel name to state binding;
- optional `events`: event name to document action ID; and
- optional `slots`: slot name to ordered child node IDs.

The catalog determines whether a member is a configuration property, input
channel, state channel, event, or slot. A literal may satisfy an input channel by
appearing in `props`. A state channel must use `bind`. The same channel cannot
have both a literal and a binding.

The graph must have unique IDs, one root, exactly one parent for every non-root
node, valid slot cardinality, no cycles, and no unreachable nodes.

The current native catalog has ten version-1 components. Exact controlled
`TextField`/`Checkbox` members and `Row`/`Card`/`Divider` bounds are specified in
the [Form Essentials contracts](binding-model.md#form-essentials-contracts).
The native [Component Lab](component-lab.md) is a strict fixture that references
every top-level member at least once. That coverage does not imply every allowed
enum value or nested option presentation is implemented.

### Form v1 behavior

`Form.busy` displays linear progress, fades and absorbs its rendered subtree,
releases and excludes descendant focus, and suppresses Form keyboard lifecycle
events. `Form.errors` accepts a nullable object and presents non-empty top-level
entries in a live-region summary. Authors should map field/form keys to strings
or lists of messages; other finite JSON values are rendered as safe diagnostic
text rather than interpreted as markup or code.

With focus inside the Form, Ctrl+Enter or Cmd+Enter emits `submitted`, while
Escape emits `cancelled`. Children in the `actions` slot are still explicit
components: Form never infers submit/cancel behavior from button position or
label, so each button's `pressed` event must reference its intended action. The
full contracts and deferred validation behavior are in
[Binding model](binding-model.md#form-essentials-contracts).

## Bindings

A simple binding is an RFC 6901 JSON Pointer string:

```json
"bind": {"value": "/draft/customerType"}
```

An explicit fallback uses an object:

```json
"bind": {
  "subtitle": {"path": "/customer/subtitle", "fallback": "Not provided"}
}
```

Missing and explicit JSON `null` are distinct. A missing initial path without a
fallback is rejected. The fallback must match the channel type.

V1 has no `DataContext`, reflection, element references, relative sources,
multibinding, interpolation, converters, or general expression language.

## `ChoiceItem`

Lookup controls consume normalized items:

```json
{
  "key": 2,
  "label": "Business",
  "disabled": false,
  "description": "Commercial customer",
  "group": "Customer",
  "icon": "business",
  "meta": {"color": "blue"}
}
```

`key` is the persisted identity and must be a non-null JSON scalar. `label` is
presentation only. The remaining fields are optional. `meta` is bounded,
JSON-compatible presentation metadata; it cannot contain behavior.

The v1 native `ComboBox` currently displays `label` and honors `disabled`. It
does not yet render nested `description`, `group`, `icon`, or `meta` content; the
presence of those validated fields in the normalized contract must not be read as
a rich-option rendering promise.

## Actions

Events refer to a named action. An action contains a lowercase dotted semantic
capability and JSON arguments:

```json
{
  "capability": "customer.save",
  "args": {
    "customer": {"$bind": "/draft"},
    "source": "editor"
  }
}
```

`$bind` values are compiled once and resolved against the current state at
dispatch time, after any component state transaction commits. A bound object may
only contain `$bind` and optional `fallback`.

The local Aix adapter must register the capability. The document cannot specify
an HTTP endpoint, method, QueryX ID, SQL function, Dart callback, shell command,
raw route, or unrestricted URL. Backend authorization and validation still run
for every dispatch.

Semantic navigation uses the same boundary. The current fixtures emit
`view.open` with an allowlisted stable View code and `view.back` without route
data. Trusted native showcase code verifies the source session, resolves the View
target, and calls the coordinator. The coordinator itself does not assign meaning
to capability names.

Component Lab interactions use the local `demo.event` capability. The showcase
does not forward it to a network service: it records the originating View/node,
committed state version, and resolved arguments in the Actions inspector. It is a
diagnostic example of typed dispatch, not a production capability contract.

The session converts adapter exceptions into an inspectable
`GenuxActionDispatchFailed` result. Renderer fire-and-forget dispatch therefore
cannot leak a failed QueryHub future as an unhandled asynchronous error.

## Strict compile and activation

The client pipeline is:

```text
byte limit -> JSON decode -> strict draft -> semantic/policy validation
           -> resolved immutable render plan -> View identity check
           -> atomic session activation and stack append
```

Compilation resolves catalog entries, channel definitions, JSON Pointers,
events, actions, and slots. Flutter component builders never parse the envelope.

Malformed or unsupported input returns structured diagnostics. It does not
escape as an input exception and does not replace the last-known-good View. A
newer open or back intent also supersedes older asynchronous source work before it
can activate.

## Resource limits

The runtime applies configurable limits including document bytes, nodes, actions,
depth, children per slot, string sizes, item counts, and component-specific
constraints. Later catalog components must declare equally bounded contracts.

The publication compiler applies equal or stricter limits so invalid documents
normally never reach a client.

## Runtime artifact versus state

`viewartifactx` stores the deterministic compiled structure and its hash. It does
not store user-specific form or entity data. QueryHub delivers a runtime snapshot
by combining the published structure with authorized initial state and current
compatibility context.

Sensitive runtime state is not persisted in the client cache by default. Cache
keys include every scope that can change the result, including user/domain,
View/revision, catalog, locale, theme, and application version.

## Deferred features

V1 begins with complete snapshots. Revisioned patches, streamed A2UI updates,
conditional rules, named pure transforms, and partial state refreshes are deferred
until snapshot activation, state transactions, and representative performance
fixtures are reliable.

MultiView currently has push/current-duplicate-no-op/pop behavior. Replace,
reuse-existing, pop-to, reload, concurrent-load coalescing, stack serialization,
cross-View result passing, durable/offline caching, deep-link parsing, and a
Flutter `Navigator.pages` adapter are explicitly deferred. None of those features
will place multiple roots or multiple Views inside one wire document.
