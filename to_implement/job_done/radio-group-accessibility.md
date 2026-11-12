# Radio Group Accessibility - Status and Requirements

## Current State

**GuxRadio Implementation:**
- Individual radio buttons support Space/Enter keyboard activation
- Each radio has `inMutuallyExclusiveGroup: true` semantic
- Focus management works for individual buttons
- No coordinated group-level keyboard navigation

## Standard Radio Group Behavior

Radio groups typically implement:
1. **Arrow key navigation**: Up/Down or Left/Right arrows move focus between radios in the group
2. **Automatic selection**: Moving focus with arrow keys also selects that radio
3. **Tab behavior**: Tab moves to the selected radio in the group (or first if none selected)
4. **Roving tabindex**: Only one radio in the group is tab-stoppable at a time

## Implementation Options

### Option 1: GuxRadioGroup Container Widget
Create a `GuxRadioGroup` widget that manages focus and arrow-key navigation for its children:

```dart
GuxRadioGroup<String>(
  value: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
  children: [
    GuxRadio(value: 'option1', label: 'Option 1'),
    GuxRadio(value: 'option2', label: 'Option 2'),
    GuxRadio(value: 'option3', label: 'Option 3'),
  ],
)
```

**Pros:**
- Explicit grouping matches semantic structure
- Centralized keyboard handling
- Can control layout and spacing

**Cons:**
- More rigid than individual radios
- Breaking change if users already lay out radios themselves

### Option 2: Implicit Grouping via groupValue
Radios with the same `groupValue` coordinate automatically:

```dart
Column(children: [
  GuxRadio(value: 'a', groupValue: group, onChanged: ...),
  GuxRadio(value: 'b', groupValue: group, onChanged: ...),
])
```

**Pros:**
- Backwards compatible with current API
- Flexible layout

**Cons:**
- Complex implementation (radios must discover siblings)
- Performance concerns with large widget trees
- Harder to determine visual grouping vs logical grouping

### Option 3: Defer to Host Application
Document that arrow-key navigation is the host's responsibility using FocusScope/FocusTraversalGroup:

**Pros:**
- Simple primitive components
- Host controls navigation policy

**Cons:**
- Less accessible out-of-the-box
- Host must implement standard pattern

## Recommendation

Start with **Option 1** (GuxRadioGroup container) because:
1. Matches native radio group patterns (HTML `<fieldset>`, native iOS/Android groups)
2. Provides clear accessibility semantics
3. Can optimize tab behavior (only selected radio is tab-stoppable)
4. Explicit API is easier to document and test

Individual GuxRadio buttons remain usable standalone for custom layouts, but GuxRadioGroup provides accessible defaults.

## Testing Requirements

Once implemented, test:
- Arrow key navigation (Up/Down and Left/Right)
- Wrapping at boundaries (last -> first, first -> last)
- Disabled radios are skipped during arrow navigation
- Tab enters at selected radio (or first if none selected)
- RTL support (arrow direction reversal)
- Screen reader announcements ("1 of 3", "Option 1, selected")
- Mouse/touch selection still works
- onChanged called when arrow keys change selection

## Current Status

**P0 Complete:**
- Individual radio keyboard activation (Space/Enter) ✓
- Semantic markup (inMutuallyExclusiveGroup) ✓
- Disabled state handling ✓
- JSON callback contract ✓

**Deferred to P1/P2:**
- Arrow-key group navigation (requires GuxRadioGroup or equivalent)
- Roving tabindex optimization
- Enhanced screen reader announcements

This is documented as a gap rather than marking radio as "complete" without group navigation support.
