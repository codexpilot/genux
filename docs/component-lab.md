# Component Lab

Status: implemented native showcase View. Component Lab is a bundled,
strictly compiled `aix.genux/1.0` compatibility fixture; Flutter web is not a
Genux target.

## Purpose

[`component.lab` revision 1](../assets/views/component-lab.genux.json) is the
live catalog specimen for `aix.core@1`. It goes through the same document
compiler, View coordinator, surface session, state store, and Material renderer
registry as an Aix runtime View. There is no showcase-only rendering path.

The fixture currently contains 43 nodes and 13 actions. Its nodes include all
ten released component types and reference every one of the 47 top-level public
catalog members at least once: properties, input/state channels, events, and
slots. A test compares the fixture against the catalog so adding a public member
without adding a specimen fails verification.

Coverage means that each public member has a valid live example. It does not mean
that every allowed enum value or every combination of channels is shown. The lab
does render all four current `Button.variant` values, but other enum contracts use
representative values. `ChoiceItem` identity, label, and disabled state are
exercised; nested `description`, `group`, `icon`, and `meta` option presentation
is not implemented by the current native `ComboBox` renderer.

## Open and inspect

1. Run the native showcase and open **Customer Workspace**.
2. Edit the customer name if you want to observe session retention.
3. Select **Open Component Lab** in `customer.edit` revision 6.
4. Interact with the live controls, then inspect the **State**, **Actions**, and
   **Source** tabs beside the preview.
5. Select **Back to editor**. The coordinator reveals the same editor session,
   including its unsaved local state; it does not reload revision 6.

Interactive specimens emit the local `demo.event` capability. The trusted
showcase dispatcher records each invocation in the Actions inspector with the
originating View, source node, committed state version, and resolved arguments.
For writable controls, the state transaction commits before the event arguments
are resolved, so the State and Actions inspectors show the same accepted value.
`demo.event` is a showcase diagnostic capability, not a production network or
authorization contract.

## Current specimens

| Area | Live coverage |
| --- | --- |
| `Column`, `Row`, `Card`, `Divider` | Bounded gaps, alignment, padding, slots, thickness, and indents |
| `Text` | Literal and bound text, representative styles, `maxLines`, and ellipsis |
| `TextField` | Normal changed/submitted flow, read-only, disabled, error text, and multiline contract |
| `Checkbox` | Interactive changed flow and disabled selected state |
| `ComboBox` | Clearable selection, disabled control, busy control, and a disabled option |
| `Button` | Primary, secondary, tertiary, danger, disabled, and busy states |
| `Form` | Content/actions slots, error summary, keyboard submitted/cancelled events, and a busy blocked subtree |

Form action-slot children remain ordinary explicit components. The labels
“Primary / submit” and “Secondary / cancel” describe the lab examples, but the
`Form` does not infer intent from a button's slot position or label. Their
`pressed` events explicitly reference actions, while Ctrl/Cmd+Enter and Escape
emit the Form's own `submitted` and `cancelled` events.

## Deferred coverage

The lab is a catalog-member compatibility fixture, not yet a visual-regression
matrix. The following remain intentional gaps:

- every allowed enum value for components other than the explicitly tested
  `Button.variant` set;
- nested rich `ChoiceItem` presentation for `description`, `group`, `icon`, and
  `meta`;
- platform/theme/density permutations and automated golden images;
- keyboard traversal and accessibility audits across every native target;
- editable or remote-search ComboBox behavior; and
- future macro templates and data components such as virtualized List/DataGrid.

When a catalog member or component is released, the fixture and its structural
coverage test should be updated in the same change. Behavioral and visual tests
remain necessary for semantics that cannot be proven by member presence alone.
