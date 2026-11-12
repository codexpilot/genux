# JSON and A2UI readiness

This is a design proposal, not a protocol implementation or compatibility
claim. GenUX's existing `schemaVersion: 1` JSON document remains an experimental,
static preview. Its `text`, `column`, `summaryLines` and `workspace` nodes
are not A2UI messages, catalogs, data bindings or actions.

## Component boundary

Keep configuration (appearance and content), externally controlled state
(such as selected value or enabled status), and events (such as activation or
selection) distinct. Core widgets accept typed values and callbacks; they do
not interpret arbitrary JSON, resolve remote resources or execute commands.
The embedding application controls theme values, labels, navigation and data.

A future versioned JSON layer could decode an allowlisted set of components to
typed configuration, retain stable component IDs and map permitted events to
host-registered handlers. Decoding must precede rendering; unknown components,
fields, versions, invalid values, duplicate IDs and invalid references should
produce structured errors with a location. Limits on bytes, nesting, nodes,
strings and collections apply both before and after normalization. Version
changes require explicit adapters and tests; they must not silently reinterpret
the existing static format. State and event schemas, exact compatibility rules
and behavior for partial updates require agreement before implementation.

## A2UI evaluation

The A2UI [message reference](https://a2ui.org/reference/messages/) describes
surface lifecycle, component updates and separate data-model updates. Its
[data-binding guide](https://a2ui.org/concepts/data-binding/) describes
per-surface state and path bindings; the [actions and functions guide](https://a2ui.org/concepts/actions-and-functions/)
describes outbound events and functions. These concepts go beyond the current
GenUX preview. Different protocol versions have different message and binding
semantics; an adapter must select a version explicitly and validate against its
schemas rather than infer compatibility from similar widget names.

An isolated adapter or custom catalog could map validated A2UI component
definitions to GenUX primitives and resolve bindings against a per-surface
model. It would own message ordering, surface IDs, component IDs, updates,
catalog negotiation, protocol errors and event serialization. GenUX core must
not depend on the adapter. Mapping a GenUX dialog, navigation rail or workspace
to a protocol component requires an explicit catalog definition; no automatic
equivalence is assumed. Unsupported catalog entries and fields must be
rejected or reported according to the selected protocol version, never silently
converted into a different action.

Treat incoming documents and data as untrusted. Restrict catalogs and functions
to host-approved registrations; never evaluate code or invoke arbitrary URLs,
filesystem operations, platform APIs or callbacks named by input. Deliver
validated event descriptions to the host, which decides whether to authorize
an operation. Scope and bound surface data, avoid accidental disclosure of
sensitive values, and define cleanup on surface deletion. The adapter must
respect user-activation and function rules of the selected protocol version.

Before claiming compatibility, pin a protocol version and catalog; test the
official schemas and fixtures, lifecycle and incremental updates, data binding,
events, invalid/unsupported messages and limits, plus representative host
integration and accessibility workflows. None of those protocol integration
tests or an A2UI adapter has been implemented yet.
