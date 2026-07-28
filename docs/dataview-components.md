# DataView Components Design

Status: Design proposal for ListView, GridView, and TableView components.

## Overview

DataView components provide high-performance, virtualized rendering of large collections in Genux. These components follow the established catalog contract model and integrate with the existing state management system.

## Design Principles

1. **Virtualized Rendering**: Use Flutter's sliver-based rendering for performance
2. **Data-First**: Data lives in state, not in metadata nodes
3. **Bounded Contracts**: Strict limits on item counts and complexity
4. **Type Safety**: Strongly typed column definitions and data shapes
5. **Accessibility**: Full semantic labeling and keyboard navigation

## Component Definitions

### 1. ListView

Vertical scrolling list with item builder pattern.

#### Contract

**Properties:**
- `itemHeight`: number [minimum: 20, maximum: 1000] - Fixed item height in pixels
- `divider`: boolean - Show dividers between items (default: false)
- `padding`: number [minimum: 0, maximum: 64] - List padding

**Channels:**
- `items`: input list<object> [required, maxItems: 10000] - Data items array
- `loading`: input boolean - Show loading indicator
- `emptyMessage`: input string [maxLength: 256] - Message when items empty

**Events:**
- `itemTapped`: payload object - Emitted when item tapped, includes item data and index

**Slots:**
- `itemTemplate`: [minChildren: 1, maxChildren: 1] - Template for each item

#### Wire Example

```json
{
  "id": "customerList",
  "component": "ListView",
  "version": 1,
  "props": {
    "itemHeight": 72,
    "divider": true,
    "padding": 16
  },
  "bind": {
    "items": "/customers/list",
    "loading": "/ui/loading",
    "emptyMessage": {"path": "/ui/emptyMessage", "fallback": "No customers found"}
  },
  "events": {
    "itemTapped": "customerSelected"
  },
  "slots": {
    "itemTemplate": ["customerListItem"]
  }
}
```

#### Data Contract

Items channel expects array of objects:
```json
{
  "customers": {
    "list": [
      {"id": "1001", "name": "Mya", "type": "Business"},
      {"id": "1002", "name": "Alex", "type": "Retail"}
    ]
  }
}
```

Item template nodes can bind to special context paths:
- `/item` - Current item object
- `/item/index` - Current item index (0-based)
- `/item/data/*` - Item fields

---

### 2. GridView

Grid layout with fixed columns and item aspect ratio.

#### Contract

**Properties:**
- `columns`: integer [minimum: 1, maximum: 12] - Number of columns (required)
- `aspectRatio`: number [minimum: 0.1, maximum: 10] - Item width/height ratio (default: 1.0)
- `spacing`: number [minimum: 0, maximum: 64] - Gap between items (default: 8)
- `padding`: number [minimum: 0, maximum: 64] - Grid padding

**Channels:**
- `items`: input list<object> [required, maxItems: 10000] - Data items array
- `loading`: input boolean - Show loading indicator
- `emptyMessage`: input string [maxLength: 256] - Message when items empty

**Events:**
- `itemTapped`: payload object - Emitted when item tapped

**Slots:**
- `itemTemplate`: [minChildren: 1, maxChildren: 1] - Template for each item

#### Wire Example

```json
{
  "id": "productGrid",
  "component": "GridView",
  "version": 1,
  "props": {
    "columns": 3,
    "aspectRatio": 0.75,
    "spacing": 12,
    "padding": 16
  },
  "bind": {
    "items": "/products/catalog",
    "loading": "/ui/loading"
  },
  "events": {
    "itemTapped": "productSelected"
  },
  "slots": {
    "itemTemplate": ["productCard"]
  }
}
```

---

### 3. TableView

Tabular data with column definitions and sorting.

#### Contract

**Properties:**
- `columns`: list<object> [required, minItems: 1, maxItems: 20] - Column definitions
- `showHeader`: boolean - Show column headers (default: true)
- `striped`: boolean - Alternate row colors (default: false)
- `dense`: boolean - Compact row height (default: false)
- `sortable`: boolean - Enable column sorting (default: false)

**Channels:**
- `rows`: input list<object> [required, maxItems: 10000] - Data rows array
- `loading`: input boolean - Show loading indicator
- `emptyMessage`: input string [maxLength: 256] - Message when rows empty
- `sortColumn`: state string - Currently sorted column key
- `sortDirection`: state string [allowedValues: {'asc', 'desc'}] - Sort direction

**Events:**
- `rowTapped`: payload object - Emitted when row tapped
- `sortChanged`: payload object - Emitted when sort changes (includes column, direction)

#### Column Definition

Each column object in `columns` property:
```json
{
  "key": "name",           // required, string, field key in row data
  "label": "Customer",     // required, string, header text
  "width": 200,            // optional, number, fixed width in pixels
  "flex": 2,               // optional, number, flex factor (default: 1)
  "align": "left",         // optional, string: left|center|right (default: left)
  "sortable": true         // optional, boolean (default: false)
}
```

#### Wire Example

```json
{
  "id": "customerTable",
  "component": "TableView",
  "version": 1,
  "props": {
    "columns": [
      {"key": "id", "label": "ID", "width": 80, "sortable": true},
      {"key": "name", "label": "Name", "flex": 2, "sortable": true},
      {"key": "type", "label": "Type", "flex": 1},
      {"key": "status", "label": "Status", "width": 100, "align": "center"}
    ],
    "showHeader": true,
    "striped": true,
    "sortable": true
  },
  "bind": {
    "rows": "/customers/list",
    "loading": "/ui/loading",
    "sortColumn": "/ui/sortColumn",
    "sortDirection": "/ui/sortDirection"
  },
  "events": {
    "rowTapped": "customerSelected",
    "sortChanged": "sortCustomers"
  }
}
```

#### Data Contract

Rows channel expects array of objects with keys matching column definitions:
```json
{
  "customers": {
    "list": [
      {"id": "1001", "name": "Mya", "type": "Business", "status": "Active"},
      {"id": "1002", "name": "Alex", "type": "Retail", "status": "Inactive"}
    ]
  }
}
```

---

## Item Template Context

### ListView & GridView

Item templates receive a special context with item data:

```json
{
  "id": "customerListItem",
  "component": "Card",
  "version": 1,
  "props": {"padding": 12},
  "slots": {
    "content": ["itemContent"]
  }
}
```

**Special Binding Paths:**
- `/item/index` - Current item index (integer)
- `/item/data` - Current item object
- `/item/data/name` - Access item fields directly

Example binding to item data:
```json
{
  "id": "itemName",
  "component": "Text",
  "version": 1,
  "bind": {
    "text": "/item/data/name"
  }
}
```

---

## Performance Characteristics

### Virtualization

All DataView components use Flutter's `ListView.builder` / `GridView.builder` pattern:
- Only visible items are rendered
- Items are recycled as they scroll out of view
- Memory usage: O(visible items), not O(total items)

### Limits

| Component | Max Items | Max Columns | Max Item Height |
|-----------|-----------|-------------|-----------------|
| ListView | 10,000 | - | 1000px |
| GridView | 10,000 | 12 | - |
| TableView | 10,000 | 20 | - |

### Expected Performance

- **1,000 items**: Smooth 60fps scrolling
- **10,000 items**: Smooth scrolling, initial build ~100ms
- **Item updates**: Only affected items rebuild

---

## State Integration

### Data Flow

```
State: /customers/list
  ↓
ListView.items binding
  ↓
Flutter ListView.builder
  ↓
Render visible items (5-20 typically)
  ↓
Item template with /item/data binding
```

### Updates

When `/customers/list` changes:
1. StateStore transaction commits
2. ListView NodeHost receives notification (path intersection)
3. ListView rebuilds with new data
4. Flutter's builder re-renders visible items only

### Sorting (TableView)

Application handler manages sorting:
```dart
case 'sortCustomers':
  final column = invocation.arguments['column'];
  final direction = invocation.arguments['direction'];
  
  session.store.transact((tx) {
    tx.setPath('/ui/sortColumn', column);
    tx.setPath('/ui/sortDirection', direction);
    
    final rows = List.of(session.store.read('/customers/list').value);
    rows.sort((a, b) => /* sort logic */);
    tx.setPath('/customers/list', rows);
  });
```

---

## Security & Validation

### Input Validation

- **Item count**: Hard limit 10,000 items
- **Column count**: TableView max 20 columns
- **Item height**: ListView max 1000px per item
- **String fields**: Standard maxLength constraints apply
- **Objects**: Finite JSON values only

### No User Code Execution

- No eval, no dynamic builders
- Item templates are compiled nodes
- All bindings resolved through JSON Pointer
- No reflection or runtime code generation

---

## Accessibility

### ListView & GridView
- Semantic list role
- Each item is tappable with semantic label
- Screen reader announces "List, N items"
- Keyboard navigation support

### TableView
- Semantic table role
- Column headers with sort state
- Row selection feedback
- Screen reader announces "Table, N rows, M columns"

---

## Implementation Phases

### Phase 1: ListView (MVP)
- Fixed item height
- Vertical scrolling only
- Item template with /item context
- itemTapped event

### Phase 2: GridView
- Multi-column layout
- Aspect ratio control
- Reuse ListView virtualization

### Phase 3: TableView
- Column definitions
- Header rendering
- Sort state binding
- Row selection

### Phase 4: Enhancements
- Pull-to-refresh
- Infinite scroll / pagination
- Selection modes (single, multiple)
- Swipe actions
- Sticky headers

---

## Deferred Features

Not in v1:

- Horizontal scrolling
- Variable item heights (requires measurement)
- Nested scrolling
- Drag-and-drop reordering
- Expandable items
- Custom separators per item
- Lazy loading / pagination (app handles via state)
- Search/filter UI (app provides via separate controls)

---

## Example: Complete Customer List

### View Document

```json
{
  "schema": "aix.genux/1.0",
  "view": {
    "id": "2001",
    "code": "customer.list",
    "revision": 1,
    "kind": "view"
  },
  "catalog": {
    "id": "aix.core",
    "version": 2,
    "checksum": "sha256:..."
  },
  "root": "listContainer",
  "state": {
    "customers": {
      "list": [
        {"id": "1001", "name": "Mya", "type": "Business", "revenue": 125000},
        {"id": "1002", "name": "Alex", "type": "Retail", "revenue": 45000}
      ]
    },
    "ui": {
      "loading": false,
      "selectedId": null
    }
  },
  "actions": {
    "selectCustomer": {
      "capability": "customer.select",
      "args": {
        "customerId": {"$bind": "/item/data/id"}
      }
    },
    "loadMore": {
      "capability": "customer.loadMore"
    }
  },
  "nodes": [
    {
      "id": "listContainer",
      "component": "Column",
      "version": 1,
      "props": {"gap": 16, "mainAxisSize": "max", "crossAxisAlignment": "stretch"},
      "slots": {"children": ["header", "customerList"]}
    },
    {
      "id": "header",
      "component": "Text",
      "version": 1,
      "props": {"text": "Customers", "style": "headlineMedium"}
    },
    {
      "id": "customerList",
      "component": "ListView",
      "version": 1,
      "props": {"itemHeight": 80, "divider": true, "padding": 0},
      "bind": {
        "items": "/customers/list",
        "loading": "/ui/loading"
      },
      "events": {"itemTapped": "selectCustomer"},
      "slots": {"itemTemplate": ["customerItem"]}
    },
    {
      "id": "customerItem",
      "component": "Card",
      "version": 1,
      "props": {"padding": 16},
      "slots": {"content": ["itemRow"]}
    },
    {
      "id": "itemRow",
      "component": "Row",
      "version": 1,
      "props": {"gap": 16, "mainAxisSize": "max", "crossAxisAlignment": "center"},
      "slots": {"children": ["itemInfo", "itemRevenue"]}
    },
    {
      "id": "itemInfo",
      "component": "Column",
      "version": 1,
      "props": {"gap": 4, "mainAxisSize": "min", "crossAxisAlignment": "start"},
      "slots": {"children": ["itemName", "itemType"]}
    },
    {
      "id": "itemName",
      "component": "Text",
      "version": 1,
      "props": {"style": "titleMedium"},
      "bind": {"text": "/item/data/name"}
    },
    {
      "id": "itemType",
      "component": "Text",
      "version": 1,
      "props": {"style": "bodySmall"},
      "bind": {"text": "/item/data/type"}
    },
    {
      "id": "itemRevenue",
      "component": "Text",
      "version": 1,
      "props": {"style": "labelLarge"},
      "bind": {"text": "/item/data/revenue"}
    }
  ]
}
```

---

## Testing Strategy

### Unit Tests
- Catalog definition validation
- Item context binding resolution
- Empty state handling
- Loading state
- Event payload generation

### Widget Tests
- Render 100 items, verify visible subset
- Scroll and verify lazy loading
- Tap item, verify event emission
- Update state, verify rebuild
- Empty list shows message

### Performance Tests
- 10,000 item list scrolls at 60fps
- Item update only rebuilds affected items
- Memory usage stays constant during scroll

---

## Migration Path

Existing views continue working. New DataView components available in catalog v2:

```dart
final catalogV2 = GenuxCatalog(
  id: 'aix.core',
  version: 2,
  checksum: 'sha256:...', // New checksum
  components: [
    ...createGenuxCoreCatalog().components.values, // v1 components
    // New DataView components
    GenuxComponentDefinition(code: 'ListView', version: 1, ...),
    GenuxComponentDefinition(code: 'GridView', version: 1, ...),
    GenuxComponentDefinition(code: 'TableView', version: 1, ...),
  ],
);
```

Views explicitly reference catalog version in wire document.

