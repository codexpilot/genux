# 01 — Stabilization and correctness

Tasks below describe outcomes and acceptance checks. Add a failing regression test for each confirmed defect before changing behavior. Existing tests exercise many older controls but do not cover all newer components.

## P0: controls and routing

- [ ] Make `GuxSlider` a controlled value selector with `onChanged`, tap/drag, keyboard adjustments, disabled state and usable semantics. Validate min/max/value, zero range and narrow/unbounded layouts; honor RTL and divisions if offered. Test pointer, keyboard, semantics, bounds, RTL and disabled behavior. Define a migration for existing callers before changing the constructor.
- [ ] Give `GuxSwitch` and `GuxRadio` focus, visible focus indication, Space/Enter activation and correct checked/selected/disabled semantics. Test pointer, keyboard, disabled and assistive-technology actions; agree on grouping and arrow-key behavior for radio groups.
- [ ] Audit the other recently added controls (accordion, tabs, sheet, toast, alert, card, badge, avatar and separator) for keyboard, state, focus, accessibility, responsive layout and lifecycle gaps. Record actual status in the component matrix; fix failures rather than extrapolating from class names.
- [ ] Define `GuxApp` routing: `/` must reliably reach `home` when a host supplies a named-route factory, and unknown route behavior must be explicit. Test startup, named and unknown routes, route settings, deep links, navigation and fallback ordering. Cover `GuxPageRoute` transitions, RTL and reduced motion.
- [ ] Investigate the skipped touch long-press selection/handles test in `test/gux_text_field_test.dart`. Implement and verify platform-appropriate selection and copy behavior, or document a concrete platform limitation and tracked follow-up; do not merely remove the skip.

## P0: documentation truth

- [ ] Correct the `Genux*`/`Gux*` names, actual runtime dependencies, catalog status, and README preview example. Fix the routing example's required button style and the example README's unregistered `Text` factory and incorrect progress JSON shape.
- [ ] Mark historical completion reports as historical where they assert full serialization, accessibility or A2UI support. Follow the documentation deliverables and verification in [04-documentation.md](04-documentation.md).

## P1: JSON contracts and correctness

- [ ] Specify three distinct boundaries: the bounded `schemaVersion: 1` static presentation document; the component JSON factory/renderer API; and the A2UI catalog/possible adapter. Document versioning, trusted inputs, error behavior, limits, host actions and compatibility for each. Preserve the existing static schema unless an explicit migration is approved.
- [ ] Replace duplicated color conversions with a shared, versioned codec that preserves alpha (including transparent black and semi-transparent values), handles leading zeros, and defines consistent errors for malformed hex. Decide and document accepted `#RRGGBB`/`#AARRGGBB` forms and compatibility with old data. Test invalid, transparent, semi-transparent and opaque values and representative serializers, including toast's default shadow.
- [ ] Define registry ownership and built-in registration: provide an explicit built-in setup or scoped registry with documented override and lifecycle rules. Preserve existing registration callers or publish a migration. Make the documented button example work from a fresh process; verify nested components, missing/unknown types and isolated registries.
- [ ] Define list child semantics. Either support strings and typed children recursively or reject unsupported elements with a useful path; never silently drop them. Test empty, mixed, nested and malformed lists and unknown components.
- [ ] State that arbitrary Flutter widgets and callbacks cannot round-trip as JSON. Choose explicit serializable configuration trees and action IDs for supported structures, or clearly label output as a partial snapshot. Address workspace children and navigation icons/actions; test supported round trips and rejection or disclosure of unsupported data.
- [ ] Align validation and error contracts across factories, including malformed colors, wrong types, missing required fields and unknown actions. Use bounded input and structured errors with paths where JSON may be untrusted; do not execute arbitrary names, URLs or code. Add fixtures for both valid and invalid inputs.

## P1/P2: A2UI integration, separately scoped

- [ ] Describe `GuxCatalog` accurately as schema declarations; remove unverified claims of a working adapter or protocol compatibility. Reconcile names and shapes with the chosen widget JSON contract, including dialog actions and dropdown options, and test catalog schemas against matching valid and invalid fixtures.
- [ ] Before implementing an adapter, choose and pin the protocol and catalog versions; document mappings, supported components, lifecycle, bindings, events, error handling and compatibility. Keep protocol concerns isolated from core UI. Decide whether optional packaging is necessary and feasible without breaking current imports; do not claim dependencies are optional until they are isolated.
- [ ] Implement the adapter only against that specification. Gate compatibility claims on official fixtures/schema tests plus surface lifecycle, incremental updates, binding, event, unsupported-input, resource-limit, host integration and accessibility tests. No arbitrary callback, code, filesystem or network execution from incoming messages.

## Done for this stream

All above P0 defects have regression tests and verified fixes; P1 contracts and behavior are consistent and documented; remaining adapter work is explicitly marked experimental or deferred. Full CI and representative host-app checks pass.
