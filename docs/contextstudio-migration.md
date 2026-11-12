# ContextStudio migration inventory and plan

This document records the starting point and the intended incremental migration
of ContextStudio to GenUX. It does not claim that the migration is complete.
The reference checkout is AIX branch `codex/system-columns` at `d721865`;
GenUX starts from `main` at `f80c0d7`.

## Boundaries and acceptance

GenUX provides reusable, application-independent Flutter widgets. The host
owns domain data, AIXHub calls, application routing, labels and theme values.
The existing public GenUX APIs and its UI-independence check remain supported.
ContextStudio must retain its design, behavior, accessibility, navigation and
AIXHub contracts. Backend changes, a visual redesign, and removing unrelated
features are outside the migration.

## Inventory

| Area | Current reference and required behavior |
| --- | --- |
| Shell and layout | App shell, 44 px top and leading bars, 26 px bottom bar, workspace and panels; compact pane layout below 1120 px. |
| Navigation | Sidebar items, active and disabled states, tooltips, focus, keyboard and pointer activation, existing navigation guards. |
| Buttons | Standard, filled, icon and destructive actions; hover, pressed, disabled, focus and keyboard activation. |
| Forms | Text and password input, validation, checkboxes, toggles, labels, disabled and error states. |
| Selection | Dropdown and searchable combo box; loading, empty, error, retry, selection, keyboard navigation and dismissible overlays. |
| Feedback | Progress rings, information/error messages, dialogs, confirmation, dismiss and focus behavior. |
| Content | Summary cards, lists, panels, tables, metadata editors and existing feature-specific screens. |
| Styling | Dark surfaces `#171717`, `#212121`, `#252525` and `#303030`; text `#ECECEC`/`#B4B4B4`, blue `#3B82F6`; 14 px body and 28 px minimum controls. App-owned tokens remain configurable. |

The reference includes raw scaffold, button, navigation, dialog, dropdown,
combo box, panel card and progress-ring implementations. They are useful
behavioral references but contain application-specific styling; some lack
keyboard/semantic behavior and the selection controls use Material icon fonts.
Adapt and test their behavior instead of assuming that copying them guarantees
equivalence. Representative flows include login/session restoration, the
metadata workspace and pane navigation, editing forms, selector loading/error
states, confirmations and logout.

## Starting constraints

The ContextStudio checkout is already incomplete: its initial `flutter analyze
--no-pub` reported 252 issues, including references to four deleted widgets,
unresolved controls in the login screen and ambiguous `showRawDialog` names.
This baseline must not be mistaken for a regression or ignored in final
verification. The current runtime dependency graph includes
`fluent_ui -> material_ui -> cupertino_ui`. Flutter's internal
`material_color_utilities` is not itself an application widget framework.

ContextStudio resolves Mix 1.7.0, whose library imports Flutter Material.
GenUX's existing independence check scans all runtime package sources, so Mix
cannot be a GenUX core dependency in this configuration. Keep core styling on
low-level Flutter APIs; any Mix integration must be isolated from core and
re-audited. Do not weaken the independence check to admit it.

The initial ContextStudio integration uses a path dependency at `../../genux`
so both uncommitted checkouts can be tested together. This requires sibling
checkouts and is not a self-contained CI or release dependency; replace it with
an available pinned GenUX revision, or arrange an equivalent checkout, before
building in an environment without that directory.

## Phased plan

1. **Foundation and coexistence:** preserve existing GenUX APIs; implement
   configurable low-level primitives and interaction tests in small slices.
   Map the existing scaffold and summary components first, then buttons,
   navigation, progress, dialogs, inputs and selection controls. Integrate
   representative ContextStudio screens while its current framework may
   coexist. Compare layouts and behaviors against the reference, including
   accessibility, focus, keyboard, pointer and small-window scenarios.
2. **Full migration:** replace Fluent/Material/Cupertino shells, themes,
   controls, icons and framework imports throughout production and tests;
   replace or isolate Mix as required. Audit direct and transitive runtime
   dependencies and enforce the final boundary with automated checks. Run
   existing workflows and web build; retain API contracts and feature behavior.
3. **JSON and protocol readiness:** keep the current static preview explicitly
   experimental. Define a versioned component/configuration vocabulary and
   map component state and events independently of protocol. Specify strict
   validation, unknown fields/components, version compatibility and safe,
   host-controlled action and data handling. Evaluate an isolated A2UI adapter
   against the relevant protocol and fixtures before claiming compatibility;
   protocol-specific semantics and executable actions do not belong in core.

Each increment must include focused tests, `flutter analyze`, appropriate
Flutter tests/builds and GenUX's independence checks. Record remaining gaps and
review both repository diffs before calling any phase complete.

## Current increment and remaining work

The first increment adds GenUX buttons, progress, navigation, dialog, a
selection primitive and an early text input. ContextStudio's workspace and summary cards, raw buttons,
progress ring and dialog use the shared primitives. Compatibility files and
imports restore the partially migrated checkout sufficiently to run its tests
and web build. Most application screens and UI framework usage remain; this is
not completion of any full phase.

The new GenUX dropdown is not yet wired into ContextStudio. The reference
dropdown has denser rows, a selected-color/check indicator, different control
padding and separate status backgrounds; matching and verifying those details
in the actual forms is required before replacing it. Searchable combo boxes,
inputs, toggles and many other controls also need migration. The early text
input lacks platform selection handles, a context menu and accessibility
copy/cut/paste actions. Test real keyboard,
screen-reader, pointer and responsive workflows and compare the appearance,
not just the existence of shared widgets.
