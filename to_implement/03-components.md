# 03 — Component coverage roadmap

## Reference and current coverage

Reference snapshot: [official shadcn/ui component index](https://ui.shadcn.com/docs/components), reviewed 2026-11-12. It changes over time; refresh the matrix before each release. The list below is a scope inventory, not a claim of parity. The source is a web/React catalog: implement equivalent useful Flutter behavior with native platform conventions, not React dependencies or an assumed pixel-for-pixel clone.

Existing approximate counterparts that require a documented audit: Accordion, Alert, Avatar, Badge, Button, Card, Checkbox, Dialog, Input, Progress, Radio Group, Select, Separator, Sheet, Slider, Switch, Tabs, Toast and Toggle. `GuxNavigation` and workspace scaffolds cover parts of Sidebar/Navigation Menu; they are not proven equivalents. `GuxTextField`/`GuxTextInput` may support aspects of Textarea and Field but need an explicit feature audit. In particular, a selection dropdown is not a Dropdown Menu and a dialog is not automatically an Alert Dialog. Preserve Genux-specific navigation and workspace primitives.

For every reference item, maintain a live matrix with: Genux API, status (missing / partial / tested / intentionally mapped / deferred), supported variants and platforms, gaps, documentation, tests and owner. A Flutter primitive or composition can satisfy an item when its usage and limitations are documented and verified; avoid wrappers with no added value.

## Shared definition of done

- [ ] Document API, controlled/uncontrolled state where applicable, callbacks, disabled/read-only/loading/error behavior, and lifecycle/disposal. Expose style/theme tokens and useful composition slots.
- [ ] Test pointer/touch and keyboard interaction, visible focus, semantics roles/states/actions and disabled behavior as applicable. Verify screen-reader behavior on representative platforms, not just semantic-tree presence.
- [ ] Cover narrow layouts, large text, RTL, localization, high contrast and reduced motion where relevant; check bounds and avoid overflow. Provide meaningful localized labels rather than hard-coded English.
- [ ] Add representative widget and accessibility tests, focused regression tests, a gallery example and an API/usage page. Add JSON/catalog support only where its contract is defined and tested; do not block a sound widget on speculative protocol parity.
- [ ] Compare supported behavior and variants to the referenced shadcn/ui entry, explicitly recording Flutter-specific differences and remaining gaps. Meet the package independence check.

Overlays additionally need anchor tracking on scroll/resize, collision handling, outside/Escape dismissal, nested overlay behavior, correct barrier semantics, modal focus containment where applicable and focus restoration. Tests must cover each behavior that the component offers.

## Delivery waves

### Wave 0 — audit and foundations

- [ ] Audit all existing approximate counterparts against the shared definition of done. Fix the P0 controls and routing in [01-stabilization.md](01-stabilization.md) before claiming them complete.
- [ ] Establish theme tokens, focus/keyboard conventions, selection models, overlay/portal positioning and dismissal, localization hooks, semantics patterns and common test harnesses. Check host-owned styling, text scaling, RTL and reduced motion. Do not couple every widget to a single global controller.

### Wave 1 — basic composition and forms

- [ ] **Aspect Ratio, Button Group, Collapsible, Empty, Field, Input Group, Input OTP, Item, Kbd, Label, Skeleton, Spinner, Textarea, Toggle Group, Typography.** Determine whether each is a reusable Genux component or a documented composition of Flutter/Genux primitives. Include labeling, validation/error descriptions, selection and keyboard behavior as applicable.
- [ ] Complete and test existing button, checkbox, text inputs, switch, radio, slider, toggle, separator, badge, card, avatar and progress variants. Agree on input/textarea and switch/toggle APIs to avoid duplicate or conflicting behavior.

### Wave 2 — overlays and navigation

- [ ] **Alert Dialog, Drawer, Tooltip, Popover, Hover Card, Dropdown Menu, Context Menu, Menubar, Navigation Menu, Command, Breadcrumb, Sidebar.** Build on the shared overlay and navigation primitives; specify controlled state, focus, dismissal and semantics per component. Distinguish action menus from value selection and modal alerts from ordinary dialogs.
- [ ] Audit and finish existing Dialog, Sheet, Toast, Accordion and Tabs, including focus restoration, announcements, keyboard navigation and state lifetimes. Add toast host/queue behavior only after defining its contract.

### Wave 3 — selection, data and layout

- [ ] **Combobox, Native Select, Pagination, Resizable, Scroll Area, Table, Data Table.** Support filtering, selection, empty/loading states and keyboard operation where applicable. Define whether Native Select maps to a Flutter platform adapter or is intentionally represented by Genux Select; do not add a prohibited dependency. Treat [Data Table](https://ui.shadcn.com/docs/components/radix/data-table) as composable table behaviors and documented integrations, with sorting/filtering/selection/pagination tested where supplied, rather than assuming one monolithic widget.
- [ ] Audit Select, radio groups and workspace/sidebar composition against real host needs. Include large data, constrained sizes, RTL and accessibility scenarios.

### Wave 4 — dates, visualization and specialized catalog

- [ ] **Calendar, Date Picker, Carousel, Chart.** Define localization, date/time-zone and range semantics, keyboard navigation and accessible alternatives; evaluate chart dependencies against the UI boundary and provide nonvisual data access. See [Calendar](https://ui.shadcn.com/docs/components/radix/calendar).
- [ ] **Attachment, Bubble, Code Block, Marker, Message, Message Scroller, Questionnaire, Trace.** Specify the Flutter API and actual product use cases, including safe handling of host-provided content and accessibility. Implement the catalog equivalents as bounded, composable features in prioritized slices; track any deliberate deferral with rationale rather than silently omitting it.
- [ ] **Direction** maps to Flutter's `Directionality` unless a documented Genux abstraction adds value; verify inherited direction across every family. Refresh the inventory for upstream additions. The separate shadcn **AI Elements** catalog (Chain of Thought, Chat, Checkpoint, Confirmation, Context, File Tree, Inline Citation, Message, Model Selector, Plan, Prompt Input, Queue, Reasoning, Sources, Stack Trace, Subagent, Suggestion, Task, Terminal and Test Results) is a follow-on product scope: assess individually after the core catalog and record decisions in the matrix.

## Completion gate

All items in the dated core index have either a verified Genux implementation/composition or an explicit, documented Flutter-specific mapping or deferral. The matrix states differences and evidence; no blanket parity claim precedes that audit. Revisit upstream changes for subsequent releases.
