# 05 — Basic component catalog

This is the prioritized inventory of **51 component families** for Genux's shared UI layer. It is a planning baseline for ERP, POS, e-commerce, CRM and clinical applications, not a claim of production readiness or a promise that each family needs a separate widget class. A family groups closely related variants and behaviors; for example, a date range is a date-picker capability and a confirmation dialog is a dialog composition. The order and scope are design targets and should be revised against real product workflows.

**Baseline:** `main` at `16982ea`, reviewed 2026-11-12. **21 families** have a related public implementation that needs an audit or further work; **30 families** have no dedicated implementation identified in the public API. These counts are family-level planning classifications, not counts of finished features or Dart classes. `GuxTextInput` already has multiline, label and error capabilities, and `GuxSummaryLines` is a specialized display rather than a general description list.

- **Existing / partial** means an exported widget covers some of the family; it does not mean it meets the criteria below. Keep its current public API compatible or provide an explicit migration.
- **New** means no dedicated general-purpose family was identified in the exported API. An existing primitive or documented composition may satisfy it; choose the API after testing real use cases.
- **P0** is the first shared business-workflow milestone. **P1** extends it for common operational workflows. **P2** is useful for broader or specialized use cases. Priorities do not override the stabilization work in [01-stabilization.md](01-stabilization.md).
- Every row is open. The scope column gives the minimum family-specific outcome; the shared release criteria below apply to all rows. Track a family as complete only after its acceptance checks pass.

## Forms and input

| ID | Family | Priority | Baseline | Minimum scope to deliver |
|---|---|---|---|---|
| 01 | Button | P0 | Existing / partial: `GuxButton` | Text/icon composition, disabled and loading states, pointer and keyboard activation. |
| 02 | Text input | P0 | Existing / partial: `GuxTextField`, `GuxTextInput` | Single- and multiline editing, read-only/disabled, selection, IME and submission; document platform limitations. |
| 03 | Form field | P0 | Existing / partial: `GuxTextInput` | Associate label, help, required indication and validation message with an input and its semantics; support host-owned validation. |
| 04 | Checkbox | P0 | Existing / partial: `GuxCheckbox` | Controlled checked, unchecked and optional mixed states, with accessible label and disabled behavior. |
| 05 | Radio group | P0 | Existing / partial: `GuxRadio` | Single selection, group labeling and keyboard navigation; settle and test the JSON callback compatibility issue. |
| 06 | Switch and toggle | P0 | Existing / partial: `GuxSwitch`, `GuxToggle` | Define distinct on/off versus pressed semantics and supported APIs; controlled state, keyboard and disabled behavior. |
| 07 | Slider | P1 | Existing / partial: `GuxSlider` | Controlled continuous/discrete values, range validation, pointer and keyboard, semantics and consistent RTL; fix known defects. |
| 08 | Single select | P0 | Existing / partial: `GuxDropdown` | Controlled selection, keyboard, async/error/empty states and accessible selected state. Search and multiple selection are separate families. |
| 09 | Combobox | P0 | New | Editable search with async options, selection, loading/empty/error states and keyboard/screen-reader behavior; handle stale results. |
| 10 | Multi-select | P1 | New | Controlled multiple selection, removal, keyboard and accessible selected values; support large or async option sets. |
| 11 | Decimal input | P0 | New | Locale-aware entry, exact decimal representation, precision, bounds, validation and intermediate editing states; avoid binary floating-point for financial values. |
| 12 | Money input | P0 | New | Compose decimal entry with an explicit currency, locale and rounding policy supplied by the host; do not implement tax or accounting rules. |
| 13 | Date picker | P0 | New | Localized keyboard-accessible calendar and text entry, min/max, clear and single/range selection; define date-only semantics. |
| 14 | Time and date-time picker | P1 | New | Localized time entry and optional date-time composition; make time-zone and ambiguous-time policy explicit when applicable. |
| 15 | File selector | P1 | New | Host-provided selection callback, selected files, constraints, progress/error and removal; file access/upload remain host responsibilities. |
| 16 | Segmented control | P1 | New | Labeled single or multiple selection with controlled state, disabled options and keyboard operation; document relation to toggle and radio. |

## Data and information

| ID | Family | Priority | Baseline | Minimum scope to deliver |
|---|---|---|---|---|
| 17 | Data table / grid | P0 | New | Column definitions, row identity, controlled selection/sort, keyboard navigation, accessible headers/cells and loading/empty/error; support bounded large or server-backed data. Document edit and virtualization limits. |
| 18 | Pagination | P0 | New | Controlled page navigation and page size, known or unknown totals, accessible labels and loading/disabled states; work with remote data. |
| 19 | Filter builder | P1 | New | Host-defined fields and operators, editable criteria, apply/clear and validation; serialize only through an explicitly defined contract. |
| 20 | Bulk-action toolbar | P1 | New | Display selected count and host-provided actions, unavailable state and clear selection; compose with the grid. |
| 21 | Tree view | P1 | New | Expand/collapse, focus, selection, keyboard navigation and accessible hierarchy; allow lazily loaded children. |
| 22 | Timeline | P1 | New | Ordered, host-provided events with timestamps, status, optional details and accessible reading order. |
| 23 | Chart | P2 | New | At least one documented host-data visualization with labels, accessible tabular alternative and an explicit dependency/interaction policy. |
| 24 | Attachment list | P1 | New | Show host-provided file metadata, status and actions; accessible list, loading/error and removal; no automatic fetching or execution. |

## Navigation

| ID | Family | Priority | Baseline | Minimum scope to deliver |
|---|---|---|---|---|
| 25 | Navigation / sidebar | P0 | Existing / partial: `GuxNavigation` | Controlled active destination, grouped items, keyboard/focus, responsive behavior and host-owned routing. |
| 26 | Tabs | P0 | Existing / partial: `GuxTabs` | Controlled selection, keyboard movement, tab/panel semantics, disabled tabs and overflow behavior. |
| 27 | Breadcrumb | P1 | New | Navigable ancestors, noninteractive current location, overflow and accessible navigation label. |
| 28 | Command search | P1 | New | Searchable host-provided actions, grouping, empty state, keyboard navigation and focus restoration. |
| 29 | Stepper | P1 | New | Current, completed and error states; optional navigation controlled by host; accessible sequence. |
| 30 | Menu bar | P2 | New | Host-provided menus, keyboard traversal and focus restoration; reuse the action-menu family. |

## Overlays and actions

| ID | Family | Priority | Baseline | Minimum scope to deliver |
|---|---|---|---|---|
| 31 | Dialog | P0 | Existing / partial: `GuxDialog` | Modal semantics, localized barrier, focus containment/restoration and dismissal; document a confirmation composition. |
| 32 | Sheet / drawer | P1 | Existing / partial: `GuxSheet` | Controlled presentation, size and placement, modal/nonmodal contract, dismissal and focus behavior. |
| 33 | Action menu | P0 | New | Anchored and context-triggered actions, disabled items, keyboard navigation, dismissal and focus restoration; distinguish from value selection. |
| 34 | Popover | P1 | New | Anchored arbitrary content, viewport collision handling, outside/Escape dismissal and explicit focus behavior. |
| 35 | Tooltip | P1 | New | Accessible description on hover and keyboard focus, dismissible and usable with touch; no essential information available only on hover. |

## Feedback

| ID | Family | Priority | Baseline | Minimum scope to deliver |
|---|---|---|---|---|
| 36 | Alert | P0 | Existing / partial: `GuxAlert` | Informational, success, warning and error content with accessible semantics and optional actions. |
| 37 | Toast and notification host | P1 | Existing / partial: `GuxToast` | Queue/replace and dismissal policy, timed and persistent messages, announcements and accessible actions. |
| 38 | Progress | P0 | Existing / partial: `GuxProgressIndicator` | Determinate/indeterminate states, accessible label and value, and reduced-motion behavior. |
| 39 | Loading placeholder | P1 | New | Skeleton or equivalent loading presentation, reduced motion and an accessible loading announcement without exposing decorative items. |
| 40 | Empty state | P0 | New | Host-provided message and optional primary action; support no data and no search results. |
| 41 | Error state | P0 | New | Host-provided error and retry action where appropriate; accessible status and no sensitive technical details by default. |

## Layout and content

| ID | Family | Priority | Baseline | Minimum scope to deliver |
|---|---|---|---|---|
| 42 | App and workspace scaffold | P0 | Existing / partial: `GuxScaffold`, `GuxAppBar`, `GuxWorkspaceScaffold` | Composable app bar, navigation and content regions with bounded, responsive and RTL layout. |
| 43 | Card | P0 | Existing / partial: `GuxCard` | Flexible content and optional header/footer; clear semantics for interactive versus static cards. |
| 44 | Accordion | P1 | Existing / partial: `GuxAccordion` | Controlled expansion, keyboard activation, labeled sections and expanded semantics. |
| 45 | Separator | P1 | Existing / partial: `GuxSeparator` | Horizontal/vertical layout and decorative or meaningful semantics. |
| 46 | Resizable split / master-detail | P1 | New | Bounded resizable panes, keyboard resizing, minimum sizes, responsive fallback and host-controlled selection. |
| 47 | Badge / status | P0 | Existing / partial: `GuxBadge` | Text and optional icon, host-owned styling and a non-color-only status cue. |
| 48 | Avatar | P1 | Existing / partial: `GuxAvatar` | Image/initials fallback, meaningful or decorative semantics, bounded size and loading/error behavior. |
| 49 | Typography | P1 | New | Documented text roles and host-overridable styles that respect scaling and contrast; use Flutter text primitives where sufficient. |
| 50 | List item | P1 | New | Composable leading/trailing content, title/subtitle, selected/disabled and optional action semantics. |
| 51 | Description list | P1 | New | Responsive label/value pairs, accessible reading order and optional actions; assess reuse of `GuxSummaryLines`. |

## Shared acceptance and dependencies

- Public API and ownership are documented: controlled state and callbacks, disabled/read-only/loading/error behavior where applicable, lifecycle, style slots and examples. Avoid redundant wrappers where a documented composition suffices.
- Test pointer/touch and keyboard, focus order/restoration and semantics roles, values, labels and actions as applicable. Do not communicate state by color alone. Test supported screen readers on representative target platforms before release.
- Support localization, text scaling, RTL, narrow constraints, contrast and reduced motion where relevant. Inputs must preserve intermediate editing and distinguish invalid, missing and valid values.
- Async components define cancellation or stale-result handling, loading, empty and error behavior. Data grids document performance limits, remote-data ownership, row identity and sorting/selection contracts.
- Provide focused widget and regression tests, API documentation, a runnable gallery example and a public-import smoke test; run the relevant checks in [the plan README](README.md). Follow [02-structure.md](02-structure.md) for placement. JSON and A2UI support are optional until their separate contracts are defined.
- Build shared focus, overlay, theming, localization and testing infrastructure before duplicating it. Complete the known P0 repairs in [01-stabilization.md](01-stabilization.md); use [03-components.md](03-components.md) for the broader shadcn coverage audit.

## Suggested delivery slices

1. **Stabilize and unblock:** repair current controls and accessibility; define shared theme, focus and overlay behavior. Complete existing P0 families and their regression coverage.
2. **First business workflow:** deliver form field, decimal/money, combobox, date picker, action menu, data grid, pagination and empty/error states. Integrate them into one realistic host-owned order or customer workflow; verify large/remote data and keyboard use.
3. **Operational workflows:** add P1 families in dependency order, especially multiple selection, time, attachments, filters, tree, timelines, split views and notification host. Exercise a second application workflow before freezing abstractions.
4. **Broader catalog:** add P2 families when a validated product use case and maintenance owner exist. Continue the separate reference-catalog audit.

## Outside the basic count

Potential optional compositions include product search/cart/checkout and receipt views (POS and commerce); customer/account summaries, activity and pipeline views (CRM); inventory and transaction lines (ERP); and patient/encounter context, clinical timeline, medications/allergies, results and order review (clinical). These must be designed against actual workflows and tested with users; they are not 51 additional core families. For clinical screens, verify patient and encounter context, display status/source/time/units where relevant, handle missing or stale information and validate with clinicians.

Payments, taxes, inventory and accounting rules, device adapters, offline synchronization, authorization, clinical decision logic and FHIR mapping/versioning belong to host applications or separately scoped integrations. A component catalog alone does not establish FHIR conformance or clinical safety.
