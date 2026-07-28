# MultiView runtime

Status: implemented native milestone. The pure-Dart coordinator, three
independently compiled fixtures, retained-session back navigation, race
protection, and trusted showcase capability handling are covered by unit and
widget tests. Flutter web is not a Genux target.

## Boundary

MultiView does not change the `aix.genux/1.0` wire document. One delivered document
still represents exactly one View, with one `view` reference, one state root, one
node graph, and one component root. A stack of screens is a local runtime concern:

```text
GenuxViewCoordinator
  -> stack entry: customer.edit document -> session -> state store
  -> stack entry: customer.summary document -> session -> state store
  -> stack entry: component.lab document -> session -> state store
```

Partial Views remain publication-time inclusions that are pinned, flattened, and
namespaced into their owning full View. They are not independently navigable stack
entries.

## Public coordinator seam

`GenuxViewCoordinator` is exported by `package:genux/genux.dart` and therefore by
`package:genux/genux_flutter.dart`. It depends only on the existing compiler,
source-loader, and action-dispatch contracts:

```dart
final views = GenuxViewCoordinator(
  compiler: compiler,
  sourceLoader: (target) => loadViewSource(
    target.viewCode,
    parameters: target.parameters,
  ),
  dispatcher: dispatchSemanticAction,
);

final result = await views.open(
  GenuxViewTarget(
    viewCode: 'customer.edit',
    instanceKey: 'customer:1001',
    parameters: const {'customerId': '1001'},
  ),
);

final activeSession = views.current?.session;
```

The source loader may complete synchronously or asynchronously. It returns one
complete JSON document, not a node fragment, a collection of roots, or a Flutter
route.

## Target identity and parameters

A runtime target has three fields:

- `viewCode`: the stable published View code expected in the returned document;
- `instanceKey`: a trusted application key for the logical runtime instance; and
- `parameters`: deeply frozen, finite JSON data supplied only to the source loader.

Stack identity is the pair `(viewCode, instanceKey)`. View code alone is
insufficient: two customer editors can use `customer:1001` and `customer:1002` and
receive independent sessions. The instance key is local coordinator metadata and
does not enter the wire document.

The parameter map and its nested lists/maps are copied and made immutable when the
target is created. Parameters are not authority and are not automatically merged
into View state; QueryHub remains responsible for authentication, authorization,
and producing the complete authorized snapshot.

Opening the already-current identity with equal parameters is an explicit no-op
and does not reload or notify. Reusing that current identity with different
parameters is rejected as a request conflict. The same View code or identity may
appear deeper in the stack when opened from another current View; each successful
open creates a new session.

## Atomic open pipeline

An open follows one candidate pipeline:

```text
load source
-> strict compile and policy validation
-> verify requested View code and full-View kind
-> activate a new GenuxSurfaceSession
-> append one stack entry and publish one change
```

No candidate entry is exposed before all gates pass. Load exceptions,
`GenuxCompileFailure` diagnostics, a mismatched `view.code`, and a navigated
`partial` return `GenuxViewOpenFailure`. They do not change stack version, notify
stack listeners, or replace the current entry. The caller can display the failure
while continuing to render the last-known-good View.

The coordinator owns no durable source cache. In the showcase, bundled assets are
the source loader. QueryHub delivery, offline cache selection, expiry, restoration,
and sensitive-state persistence remain separate deferred work.

## Stack and retained sessions

Every `GenuxViewStackEntry` owns the exact `GenuxSurfaceSession` activated for its
document. Pushing another View leaves prior entries untouched. A successful
`pop()` removes only the current entry and reveals the same prior entry and session
object, including its state-store version, dirty paths, and unsaved local values.

The coordinator publishes immutable `GenuxViewStackChange` snapshots for
successful pushes and pops. Versions increase once per published stack mutation.
No-op opens, failures, superseded work, and root/empty pops do not publish. Listener
exceptions are isolated in the listener's Dart zone and cannot stop later
listeners.

The root cannot be popped by the coordinator; native shell dismissal or app exit
remains shell policy. The coordinator preserves surface session state. Preserving
Flutter-only focus, animation, and scroll objects across routes remains the
responsibility of a future native navigation adapter.

## Race rule

Navigation uses latest-request-wins semantics. Every `open()` receives a monotonic
request token. A later open or any pop intent supersedes older pending work. A
superseded load may finish, but it returns `GenuxViewOpenNoop` with reason
`superseded` and cannot append a session or publish a notification.

This rule also applies when back is requested at the root: the stack stays intact,
but an obsolete pending open is prevented from appearing afterward. Concurrent
identical opens are not currently coalesced; the later request supersedes the
earlier one.

## Semantic navigation boundary

The coordinator does not interpret capabilities. Documents can emit typed
semantic actions, but trusted native application code decides whether an action is
navigation and which View target it resolves to.

The showcase registers two local navigation capabilities:

- `view.open` accepts an allowlisted stable `viewCode`, resolves it to a bundled
  fixture, constructs a trusted instance key, and calls `open()`; and
- `view.back` calls `pop()`.

Before handling either action, the showcase verifies that the invocation came from
the currently visible session. A stale covered or popped session cannot navigate.
No document supplies an arbitrary Flutter route, URL, asset path, QueryX ID, or
source-loader implementation.

## Executable fixtures

All three fixtures use catalog `aix.core@1` with development fingerprint
`sha256:df13b4276c7e3f607524c4bc7e8b82d0fda561d610ac73013341794fa2e5de9d`.

| View | Revision | Root | Navigation action |
| --- | ---: | --- | --- |
| [`customer.edit`](../assets/views/customer-edit.genux.json) | 6 | `customerForm` | `view.open` to `customer.summary` or `component.lab` |
| [`customer.summary`](../assets/views/customer-summary.genux.json) | 1 | `summaryRoot` | `view.back` |
| [`component.lab`](../assets/views/component-lab.genux.json) | 1 | `labRoot` | `view.back` |

The native showcase lets the user edit customer state, open either independently
compiled child document, and return to the exact editor session. The **Open
Component Lab** action reaches a 43-node, 13-action View that exercises all ten
component types and all 47 top-level catalog members. Its interactive examples
emit local `demo.event` capabilities; the Actions inspector records the
originating View, node, committed state version, and resolved arguments. The stack
bar, revision labels, State/Actions/Source inspectors, and restored editor value
make the isolation and retention visible.

Component Lab's catalog coverage is structural and behavioral at representative
points. It does not claim every allowed enum value or rich nested `ChoiceItem`
presentation; those boundaries are recorded in [Component Lab](component-lab.md).

## Deferred

The implemented milestone intentionally does not yet provide:

- named open policies such as replace, reuse-existing, pop-to, or singleton;
- reload/refresh of an existing entry;
- coalescing or cancellation of underlying source-loader futures;
- pending-operation snapshots or coordinator-owned loading UI;
- durable/offline QueryHub caching, restoration, or stack serialization;
- deep-link parsing or a Flutter `Navigator.pages` adapter;
- cross-View result passing or parameter mutation after activation;
- automatic synchronization between separate View state stores; or
- multiple roots or multiple Views inside one wire document.

These features must preserve the same atomic candidate, identity, semantic-action,
and last-known-good invariants when introduced.
