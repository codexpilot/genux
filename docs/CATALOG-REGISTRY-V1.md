# Catalog Registry v1 - Layer-Based Component System

## Overview

This document defines the **v1 catalog registry** with a layer-based ID system (1-255) and database schema using your naming conventions.

---

## 🎯 Component ID Allocation (1-255)

### Category Ranges

```
1-39    = Layout & Structure
40-69   = Text & Display
70-99   = Input Components
100-119 = Action Components
120-149 = Data Display
150-169 = Forms & Containers
170-189 = Navigation
190-209 = Pickers & Selectors
210-229 = Animation & Effects
230-255 = Advanced & Special (26 slots)
```

---

## 📋 **Current v1 Components (12 components)**

### Layout & Structure (1-39)

| ID | Name | Category | Description |
|----|------|----------|-------------|
| 10 | Column | 1 | Vertical layout container |
| 11 | Row | 1 | Horizontal layout container |
| 15 | Expanded | 1 | Flex layout primitive |
| 21 | Card | 1 | Material card container |
| 30 | Divider | 1 | Visual separator |

### Text & Display (40-69)

| ID | Name | Category | Description |
|----|------|----------|-------------|
| 40 | Text | 2 | Text display component |

### Input Components (70-99)

| ID | Name | Category | Description |
|----|------|----------|-------------|
| 70 | TextField | 3 | Text input control |
| 80 | Checkbox | 3 | Boolean checkbox control |
| 85 | ComboBox | 3 | Dropdown selection control |

### Action Components (100-119)

| ID | Name | Category | Description |
|----|------|----------|-------------|
| 100 | Button | 4 | Clickable button |

### Data Display (120-149)

| ID | Name | Category | Description |
|----|------|----------|-------------|
| 122 | CollectionView | 5 | List/grid repeated items |

### Forms & Containers (150-169)

| ID | Name | Category | Description |
|----|------|----------|-------------|
| 150 | Form | 6 | Form container with actions |

---

## 🗄️ Database Schema (Your Naming Convention)

### Table: `uicomponentx`

Component registry with your column naming scheme:

```sql
CREATE TABLE uicomponentx (
  i BIGSERIAL PRIMARY KEY,           -- Component identity (auto-increment)
  d BIGINT NOT NULL,                 -- Epoch milliseconds UTC of last edit
  a BOOLEAN NOT NULL DEFAULT true,   -- Active (true) / Inactive (false)
  n VARCHAR(63) NOT NULL,            -- Component name ("Text", "Button")
  c INT NOT NULL,                    -- Category ID for rendering (1-10)
  p TEXT[] NOT NULL DEFAULT '{}',    -- Array of customizable property names
  v JSONB NOT NULL DEFAULT '{}',     -- Default/forced property values
  
  -- Computed/derived fields
  numeric_id INT UNIQUE NOT NULL,    -- Layer-based ID (10, 40, 70, etc.)
  catalog_version INT NOT NULL,      -- Catalog version (1, 2, 3...)
  component_version INT NOT NULL DEFAULT 1, -- Component version
  
  -- Constraints
  UNIQUE(catalog_version, n),        -- Unique name per catalog version
  UNIQUE(catalog_version, numeric_id), -- Unique ID per catalog version
  CHECK (numeric_id >= 1 AND numeric_id <= 255),
  CHECK (c >= 1 AND c <= 10)
);

-- Indexes
CREATE INDEX idx_uicomponentx_active ON uicomponentx(a) WHERE a = true;
CREATE INDEX idx_uicomponentx_category ON uicomponentx(c);
CREATE INDEX idx_uicomponentx_numeric_id ON uicomponentx(numeric_id);
CREATE INDEX idx_uicomponentx_name ON uicomponentx(n);
```

---

## 🎨 Category System (c column)

Categories determine **rendering behavior** and **grouping**:

| c | Category Name | Rendering Behavior |
|---|---------------|-------------------|
| 1 | Layout | Container rendering, flex, spacing |
| 2 | Display | Text/icon rendering, typography |
| 3 | Input | Form controls, validation, state binding |
| 4 | Action | Event handling, buttons, gestures |
| 5 | Data | List/grid virtualization, scrolling |
| 6 | Form | Form lifecycle, submission, validation |
| 7 | Navigation | Routing, stack management |
| 8 | Picker | Modal dialogs, selection UIs |
| 9 | Effect | Animations, transitions, visual effects |
| 10 | Advanced | Custom rendering, platform-specific |

---

## 📊 Sample Data (v1 Components)

```sql
-- Layout & Structure (c = 1)
INSERT INTO uicomponentx (d, a, n, c, p, v, numeric_id, catalog_version, component_version) VALUES
(1722000000000, true, 'Column', 1, 
  ARRAY['gap', 'mainAxisSize', 'crossAxisAlignment'],
  '{"gap": 0, "mainAxisSize": "max", "crossAxisAlignment": "start"}',
  10, 1, 1),

(1722000000000, true, 'Row', 1,
  ARRAY['gap', 'mainAxisSize', 'crossAxisAlignment'],
  '{"gap": 0, "mainAxisSize": "max", "crossAxisAlignment": "start"}',
  11, 1, 1),

(1722000000000, true, 'Expanded', 1,
  ARRAY['flex'],
  '{"flex": 1}',
  15, 1, 1),

(1722000000000, true, 'Card', 1,
  ARRAY['padding'],
  '{"padding": 16}',
  21, 1, 1),

(1722000000000, true, 'Divider', 1,
  ARRAY['thickness', 'indent', 'endIndent'],
  '{"thickness": 1, "indent": 0, "endIndent": 0}',
  30, 1, 1);

-- Text & Display (c = 2)
INSERT INTO uicomponentx (d, a, n, c, p, v, numeric_id, catalog_version, component_version) VALUES
(1722000000000, true, 'Text', 2,
  ARRAY['style', 'maxLines'],
  '{"style": "bodyMedium", "maxLines": null}',
  40, 1, 1);

-- Input Components (c = 3)
INSERT INTO uicomponentx (d, a, n, c, p, v, numeric_id, catalog_version, component_version) VALUES
(1722000000000, true, 'TextField', 3,
  ARRAY['label', 'hint', 'maxLines'],
  '{"label": null, "hint": null, "maxLines": 1}',
  70, 1, 1),

(1722000000000, true, 'Checkbox', 3,
  ARRAY['label'],
  '{"label": ""}',
  80, 1, 1),

(1722000000000, true, 'ComboBox', 3,
  ARRAY['clearable', 'placeholder'],
  '{"clearable": false, "placeholder": "Select..."}',
  85, 1, 1);

-- Action Components (c = 4)
INSERT INTO uicomponentx (d, a, n, c, p, v, numeric_id, catalog_version, component_version) VALUES
(1722000000000, true, 'Button', 4,
  ARRAY['variant'],
  '{"variant": "primary"}',
  100, 1, 1);

-- Data Display (c = 5)
INSERT INTO uicomponentx (d, a, n, c, p, v, numeric_id, catalog_version, component_version) VALUES
(1722000000000, true, 'CollectionView', 5,
  ARRAY['itemKey', 'layout', 'itemHeight', 'columns', 'spacing', 'padding'],
  '{"layout": "list", "itemHeight": null, "columns": 1, "spacing": 8, "padding": 0}',
  122, 1, 1);

-- Forms & Containers (c = 6)
INSERT INTO uicomponentx (d, a, n, c, p, v, numeric_id, catalog_version, component_version) VALUES
(1722000000000, true, 'Form', 6,
  ARRAY[],
  '{}',
  150, 1, 1);
```

---

## 🔧 Column Definitions Explained

### `i` - Identity (BIGSERIAL)
- **Purpose**: Primary key, auto-incrementing
- **Example**: 1, 2, 3, ...
- **Use**: Internal database reference

### `d` - Date (BIGINT)
- **Purpose**: Last edit timestamp in epoch milliseconds UTC
- **Example**: `1722000000000` = July 26, 2024, 10:40:00 UTC
- **Use**: Track component metadata changes, cache invalidation

### `a` - Active (BOOLEAN)
- **Purpose**: Component availability flag
- **Values**: 
  - `true` = Active, available for use
  - `false` = Inactive, deprecated, hidden
- **Use**: Soft delete, feature flags, deprecation

### `n` - Name (VARCHAR)
- **Purpose**: Component identifier string
- **Example**: `'Text'`, `'Button'`, `'TextField'`
- **Constraints**: Unique per catalog version, max 63 chars
- **Use**: Human-readable lookup, backward compatibility

### `c` - Category (INT)
- **Purpose**: Rendering category for grouping and behavior
- **Values**: 1-10 (see Category System above)
- **Example**: `2` = Display, `3` = Input, `4` = Action
- **Use**: 
  - Renderer selection
  - UI grouping in authoring tools
  - Performance optimization (batch by category)

### `p` - Properties (TEXT[])
- **Purpose**: List of customizable property names
- **Example**: `['gap', 'mainAxisSize', 'crossAxisAlignment']`
- **Use**: 
  - Define which properties authors can customize
  - Validation during authoring
  - Property discovery in UI builders

### `v` - Values (JSONB)
- **Purpose**: Default or forced property values
- **Example**: `{"gap": 0, "mainAxisSize": "max"}`
- **Use**: 
  - Default values when property not specified
  - Forced values that cannot be overridden
  - Fallback during runtime

---

## 🎯 Category-Based Rendering Logic

### Example: Renderer Selection

```dart
// Select renderer based on category
Widget buildComponent(ComponentData component) {
  return switch (component.category) {
    1 => LayoutRenderer(component),      // Layout
    2 => DisplayRenderer(component),     // Display
    3 => InputRenderer(component),       // Input
    4 => ActionRenderer(component),      // Action
    5 => DataRenderer(component),        // Data
    6 => FormRenderer(component),        // Form
    7 => NavigationRenderer(component),  // Navigation
    8 => PickerRenderer(component),      // Picker
    9 => EffectRenderer(component),      // Effect
    10 => AdvancedRenderer(component),   // Advanced
    _ => ErrorRenderer(component),
  };
}
```

### Example: Property Merging

```dart
// Merge default values with author values
Map<String, dynamic> resolveProperties(
  ComponentData component,
  Map<String, dynamic> authorProps,
) {
  final defaults = component.defaultValues; // From 'v' column
  final customizable = component.properties; // From 'p' column
  
  final resolved = <String, dynamic>{...defaults};
  
  for (final entry in authorProps.entries) {
    // Only allow customizable properties
    if (customizable.contains(entry.key)) {
      resolved[entry.key] = entry.value;
    }
  }
  
  return resolved;
}
```

---

## 📦 Future Component Additions (Reserved IDs)

### Layout & Structure (1-39)
```
12 = Stack
13 = Wrap
14 = Flow
16 = Flexible
17 = Spacer
18 = SizedBox
19 = ConstrainedBox
20 = Container
22 = Padding
23 = Center
24 = Align
...
```

### Text & Display (40-69)
```
41 = RichText
42 = SelectableText
43 = Heading
44 = Label
45 = Icon
46 = Image
47 = CircleAvatar
48 = Badge
49 = Chip
...
```

### Input Components (70-99)
```
71 = TextFormField
72 = SearchBar
73 = Autocomplete
74 = PasswordField
75 = RichTextEditor
76 = Switch
77 = Radio
78 = RadioGroup
81 = Slider
82 = RangeSlider
86 = DropdownMenu
87 = MenuAnchor
...
```

---

## 🔄 Migration Path

### Phase 1: Update Runtime Catalog (Immediate)
1. Update `lib/src/catalog/core_catalog.dart` with new IDs
2. Map each component to category (c value)
3. Define customizable properties (p value)
4. Set default values (v value)

### Phase 2: Database Schema (When Implementing CloudX)
1. Create `uicomponentx` table with schema above
2. Insert v1 component data
3. Add foreign keys from `viewnodex`

### Phase 3: Renderer Updates (Ongoing)
1. Implement category-based renderer selection
2. Use `c` column for performance optimization
3. Batch render by category for efficiency

---

## ✅ Benefits of This Design

### 1. **Consistent Naming**
- Follows your `i,d,a,n,c,p,v` convention
- Familiar to developers working with MetaX/QueryX

### 2. **Category-Based Rendering**
- `c` column enables smart renderer selection
- Improves performance through batching
- Simplifies authoring UI grouping

### 3. **Flexible Properties**
- `p` array defines what can be customized
- `v` JSONB stores defaults/forced values
- Supports per-component configuration

### 4. **Layer-Based IDs**
- Logical grouping (10s, 40s, 70s)
- Room for 246 components (1-255)
- Memorable and predictable

### 5. **Soft Delete & Versioning**
- `a` flag for deprecation without breaking changes
- `d` timestamp for cache invalidation
- Support for component evolution

---

## 📝 Next Steps

1. **Approve this design** - Confirm schema matches your needs
2. **Update Dart catalog** - Migrate to new IDs
3. **Update documentation** - Reflect category system
4. **Plan database migration** - When CloudX is ready

**Ready to proceed with code migration?** 🚀
