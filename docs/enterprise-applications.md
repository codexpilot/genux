# Genux for Enterprise Applications

Recommendations for adapting Genux as a UI library for ERP, CRM, EMR, LMS, and other enterprise systems.

## Executive Summary

Genux's architecture—dynamic UI with strict schemas, two-stage compilation, and capability-based actions—provides a solid foundation for enterprise applications. However, production enterprise systems require additional components focused on:

1. **Complex data operations** (filtering, sorting, pagination, search)
2. **Advanced forms** (validation, wizards, conditional fields)
3. **Rich interactions** (drag-drop, inline editing, keyboard shortcuts)
4. **Specialized widgets** (calendars, charts, file uploads, rich text)
5. **Performance at scale** (100K+ records, complex dashboards)
6. **Accessibility compliance** (WCAG 2.1 AA, screen readers, keyboard-only)
7. **Offline capability** (local caching, sync, conflict resolution)

---

## 1. Essential Components for Enterprise

### Data Components (High Priority)

#### DataGrid (Advanced TableView)
**Use Cases**: Customer lists, inventory, transactions, logs

**Required Features:**
- **Column features**:
  - Resizable columns
  - Reorderable columns (drag to reposition)
  - Frozen columns (lock left/right)
  - Column visibility toggle
  - Column groups/headers
- **Row features**:
  - Row selection (single, multiple, range)
  - Row actions menu
  - Expandable rows (master-detail)
  - Row grouping by field
- **Virtualization**:
  - Virtual scrolling for 100K+ rows
  - Progressive loading (load on scroll)
  - Row height caching
- **Filtering**:
  - Column filters (text, number, date, choice)
  - Quick filter (search all columns)
  - Advanced filter builder
  - Saved filter presets
- **Sorting**:
  - Multi-column sort
  - Custom sort functions
  - Sort indicators
- **Editing**:
  - Inline cell editing
  - Batch edit mode
  - Validation on edit
  - Undo/redo
- **Export**:
  - Export to CSV/Excel
  - Print view
  - Copy selected cells

**Wire Contract Extension:**
```json
{
  "component": "DataGrid",
  "version": 1,
  "props": {
    "columns": [...],
    "selectionMode": "multiple",
    "editable": true,
    "frozenColumns": 2,
    "groupBy": "department",
    "showFilters": true
  },
  "bind": {
    "rows": "/data/customers",
    "selectedIds": "/ui/selection",
    "filterState": "/ui/filters",
    "sortState": "/ui/sort"
  },
  "events": {
    "selectionChanged": "updateSelection",
    "cellEdited": "saveCell",
    "filterChanged": "applyFilters",
    "exportRequested": "exportData"
  }
}
```

---

#### TreeView
**Use Cases**: File systems, org charts, categories, nested menus

**Features:**
- Expand/collapse nodes
- Lazy loading of children
- Drag-drop to reorder/reparent
- Selection modes
- Search/filter tree
- Icons per node type
- Checkbox tree (partial selection)

**Wire Contract:**
```json
{
  "component": "TreeView",
  "version": 1,
  "props": {
    "showCheckboxes": true,
    "draggable": true,
    "lazyLoad": true
  },
  "bind": {
    "nodes": "/data/orgChart",
    "expandedIds": "/ui/expanded",
    "selectedId": "/ui/selectedNode"
  },
  "events": {
    "nodeExpanded": "loadChildren",
    "nodeSelected": "selectNode",
    "nodeMoved": "reorderNode"
  }
}
```

---

#### Calendar / DatePicker
**Use Cases**: Scheduling, events, appointments, deadlines

**Features:**
- Month/week/day/agenda views
- Event rendering with duration
- Drag to reschedule
- Time zone support
- Recurring events
- Multi-day events
- Resource timeline view

**Wire Contract:**
```json
{
  "component": "Calendar",
  "version": 1,
  "props": {
    "view": "month",
    "firstDayOfWeek": 0,
    "businessHours": {"start": "09:00", "end": "17:00"}
  },
  "bind": {
    "events": "/data/appointments",
    "selectedDate": "/ui/selectedDate",
    "viewMode": "/ui/calendarView"
  },
  "events": {
    "eventClicked": "openAppointment",
    "dateSelected": "createAppointment",
    "eventDropped": "reschedule"
  }
}
```

---

#### Kanban Board
**Use Cases**: Project management, workflow tracking, sales pipeline

**Features:**
- Multiple columns (stages)
- Drag cards between columns
- WIP limits per column
- Card templates
- Swimlanes (grouped rows)
- Filters and search

---

### Form Components (High Priority)

#### DateTimePicker
**Features:**
- Date picker with calendar
- Time picker with dropdown
- Date range selection
- Keyboard input
- Locale-aware formatting
- Min/max constraints
- Disabled dates

---

#### FileUpload
**Features:**
- Drag-drop zone
- Multiple files
- Progress indicators
- File type restrictions
- Size limits
- Preview for images
- Upload to capability endpoint

**Wire Contract:**
```json
{
  "component": "FileUpload",
  "version": 1,
  "props": {
    "multiple": true,
    "accept": ["image/*", ".pdf"],
    "maxSize": 10485760,
    "maxFiles": 5
  },
  "bind": {
    "files": "/draft/attachments",
    "uploading": "/ui/uploading"
  },
  "events": {
    "filesSelected": "uploadFiles",
    "uploadComplete": "filesUploaded"
  }
}
```

---

#### RichTextEditor
**Features:**
- WYSIWYG editing
- Formatting (bold, italic, lists)
- Links and images
- Tables
- HTML/Markdown output
- Sanitized input
- Accessibility support

---

#### SearchBox with Autocomplete
**Features:**
- Debounced search
- Async suggestions
- Highlighted matches
- Recent searches
- Keyboard navigation
- Clear button

---

#### MultiSelect with Tags
**Features:**
- Select multiple items
- Tag chips display
- Search/filter items
- Create new tags
- Remove tags
- Max selection limit

---

#### NumberInput with Formatting
**Features:**
- Currency formatting
- Percentage mode
- Decimal precision
- Thousands separator
- Min/max validation
- Step increment buttons

---

### Layout Components

#### Tabs
**Features:**
- Horizontal/vertical tabs
- Closeable tabs
- Scroll overflow
- Lazy load content
- Badge indicators
- Router integration

---

#### Accordion / Expansion Panel
**Features:**
- Expand/collapse sections
- Single or multiple open
- Nested accordions
- Icons and badges

---

#### SplitPane / Resizable Panels
**Features:**
- Horizontal/vertical split
- Resizable divider
- Min/max sizes
- Collapse panels
- Multiple panes

---

#### Dialog / Modal
**Features:**
- Overlay with backdrop
- Draggable header
- Resizable
- Full-screen mode
- Nested dialogs
- Confirmation dialogs
- Alert/info variants

---

#### Stepper / Wizard
**Features:**
- Multi-step forms
- Linear/non-linear flow
- Step validation
- Progress indicator
- Back/next navigation
- Step summaries

---

### Visualization Components

#### Charts
**Features:**
- Line, bar, pie, area charts
- Real-time updates
- Interactive tooltips
- Zoom and pan
- Multiple series
- Legends
- Accessibility (data tables)

**Recommendation**: Use capability to fetch chart configuration rather than embedding chart library in Genux. Server returns chart spec in JSON format.

---

#### ProgressBar / Indicators
**Features:**
- Linear progress
- Circular progress
- Determinate/indeterminate
- Labels and values
- Color thresholds

---

#### Badge / Chip
**Features:**
- Status indicators
- Count badges
- Color variants
- Removable chips
- Avatar chips

---

#### Timeline
**Features:**
- Vertical/horizontal timeline
- Event markers
- Grouping by date
- Expand/collapse details

---

## 2. Advanced Features

### Filtering & Search

#### Server-Side Filtering
Application manages filter logic; Genux only displays UI.

**Filter Builder Component:**
```json
{
  "component": "FilterBuilder",
  "version": 1,
  "props": {
    "fields": [
      {"key": "name", "label": "Name", "type": "string"},
      {"key": "revenue", "label": "Revenue", "type": "number"},
      {"key": "status", "label": "Status", "type": "choice", "options": [...]}
    ]
  },
  "bind": {
    "filters": "/ui/activeFilters"
  },
  "events": {
    "filtersChanged": "applyFilters"
  }
}
```

Application handler:
```dart
case 'applyFilters':
  final filters = invocation.arguments['filters'];
  final results = await queryCustomers(filters); // Server query
  session.store.transact((tx) => tx.setPath('/data/customers', results));
```

---

### Pagination

#### Server-Side Pagination
```json
{
  "component": "DataGrid",
  "bind": {
    "rows": "/data/currentPage",
    "pageNumber": "/ui/pageNumber",
    "pageSize": "/ui/pageSize",
    "totalCount": "/data/totalCount"
  },
  "events": {
    "pageChanged": "loadPage"
  }
}
```

**Pagination Component:**
```json
{
  "component": "Pagination",
  "version": 1,
  "props": {
    "showSizeSelector": true,
    "pageSizes": [10, 25, 50, 100]
  },
  "bind": {
    "currentPage": "/ui/pageNumber",
    "pageSize": "/ui/pageSize",
    "totalCount": "/data/totalCount"
  },
  "events": {
    "pageChanged": "loadPage",
    "sizeChanged": "changePageSize"
  }
}
```

---

### Inline Editing

Allow editing cells directly in DataGrid:

```dart
case 'cellEdited':
  final rowIndex = invocation.arguments['rowIndex'];
  final columnKey = invocation.arguments['columnKey'];
  final newValue = invocation.arguments['value'];
  
  // Optimistic update
  session.store.transact((tx) {
    tx.setPath('/data/customers/$rowIndex/$columnKey', newValue);
  });
  
  // Save to server
  await updateCustomerField(rowId, columnKey, newValue);
```

---

### Bulk Operations

Select multiple rows and perform batch actions:

```json
{
  "component": "BulkActionBar",
  "version": 1,
  "bind": {
    "selectedCount": "/ui/selectedIds/length",
    "visible": {"path": "/ui/hasSelection", "fallback": false}
  },
  "slots": {
    "actions": ["bulkDelete", "bulkExport", "bulkAssign"]
  }
}
```

---

### Master-Detail Views

Expand row to show detailed information:

```json
{
  "component": "DataGrid",
  "props": {
    "expandableRows": true
  },
  "bind": {
    "expandedRowId": "/ui/expandedRow"
  },
  "slots": {
    "detailTemplate": ["customerDetail"]
  },
  "events": {
    "rowExpanded": "loadDetails"
  }
}
```

---

## 3. Performance Optimizations

### Virtual Scrolling
Already implemented for ListView/GridView. Extend to DataGrid with:
- Column virtualization (horizontal scroll)
- Variable row heights with measurement cache
- Overscan for smoother scrolling

---

### Lazy Loading
Load data progressively as user scrolls:

```dart
case 'loadMore':
  if (isLoading) return;
  final currentCount = session.store.read('/data/customers').length;
  final newPage = await fetchCustomers(offset: currentCount, limit: 50);
  
  session.store.transact((tx) {
    final existing = List.from(tx.read('/data/customers'));
    existing.addAll(newPage);
    tx.setPath('/data/customers', existing);
  });
```

---

### Debouncing & Throttling
For search and filter inputs:

```dart
Timer? _searchDebounce;

case 'searchChanged':
  _searchDebounce?.cancel();
  _searchDebounce = Timer(Duration(milliseconds: 300), () {
    final query = invocation.arguments['query'];
    performSearch(query);
  });
```

---

### State Optimization
- Use path-based subscriptions (already implemented)
- Avoid full list re-renders when single item changes
- Use incremental updates where possible

---

## 4. Validation & Business Rules

### Field-Level Validation

Extend validation beyond type constraints:

```json
{
  "component": "TextField",
  "bind": {
    "value": "/draft/email",
    "errorText": "/errors/email"
  },
  "events": {
    "changed": "validateEmail"
  }
}
```

Application validates and updates error state:
```dart
case 'validateEmail':
  final email = invocation.arguments['value'];
  final error = validateEmailFormat(email);
  session.store.transact((tx) => tx.setPath('/errors/email', error));
```

---

### Form-Level Validation

Validate entire form before submit:

```dart
case 'customer.save':
  final draft = invocation.arguments['customer'];
  final validationErrors = validateCustomer(draft);
  
  if (validationErrors.isNotEmpty) {
    session.store.transact((tx) {
      tx.setPath('/errors', validationErrors);
      tx.setPath('/ui/saving', false);
    });
    return;
  }
  
  await saveCustomer(draft);
```

---

### Conditional Fields

Show/hide fields based on other field values:

```json
{
  "id": "businessFields",
  "component": "Column",
  "bind": {
    "visible": {"path": "/draft/customerType", "fallback": null}
  },
  "slots": {"children": ["taxId", "companyName"]}
}
```

**Note**: `visible` channel not yet implemented. Would need to add to all components.

---

### Cross-Field Validation

Validate relationships between fields:

```dart
case 'validateDateRange':
  final startDate = session.store.read('/draft/startDate');
  final endDate = session.store.read('/draft/endDate');
  
  if (endDate < startDate) {
    session.store.transact((tx) {
      tx.setPath('/errors/endDate', 'End date must be after start date');
    });
  }
```

---

## 5. Offline & Sync

### Local Storage

Store state locally for offline access:

```dart
// On state change
session.store.subscribe([], (change) {
  if (change.origin == GenuxTransactionOrigin.user) {
    await saveToLocalStorage('draft_${viewCode}', session.store.state);
  }
});

// On view open
final cached = await loadFromLocalStorage('draft_${viewCode}');
if (cached != null) {
  session.store.transact(
    (tx) => tx.setPath('/', cached),
    origin: GenuxTransactionOrigin.system,
  );
}
```

---

### Conflict Resolution

Handle offline edits conflicting with server changes:

```dart
// Detect conflicts using dirty paths
final result = session.store.transact(
  (tx) => tx.setPath('/draft', serverData),
  origin: GenuxTransactionOrigin.remote,
  dirtyConflict: GenuxDirtyConflictPolicy.reject,
);

if (result is GenuxStateRejected && 
    result.reason == GenuxRejectionReason.dirtyConflict) {
  // Show conflict resolution UI
  await showConflictDialog(localData, serverData);
}
```

---

### Optimistic Updates

Update UI immediately, sync in background:

```dart
case 'customer.save':
  // Optimistic: update UI immediately
  final draft = invocation.arguments['customer'];
  session.store.transact((tx) {
    tx.setPath('/customers/list/$index', draft);
    tx.setPath('/ui/saving', true);
  });
  
  try {
    await saveCustomer(draft);
    session.store.acknowledge(['/customers/list/$index']);
  } catch (e) {
    // Revert on failure
    session.store.transact((tx) {
      tx.setPath('/customers/list/$index', originalData);
      tx.setPath('/errors/save', e.toString());
    });
  } finally {
    session.store.transact((tx) => tx.setPath('/ui/saving', false));
  }
```

---

## 6. Accessibility (WCAG 2.1 AA)

### Keyboard Navigation

All components must support:
- Tab navigation
- Arrow keys (lists, grids, trees)
- Enter/Space (activation)
- Escape (close dialogs)
- Shortcuts (Ctrl+S save, Ctrl+F find)

**DataGrid keyboard support:**
- Arrow keys: Navigate cells
- Page Up/Down: Scroll page
- Home/End: First/last column
- Ctrl+Home/End: First/last row
- Space: Toggle selection
- Shift+Arrow: Range selection

---

### Screen Reader Support

- Semantic HTML roles
- ARIA labels and descriptions
- Live regions for updates
- Announced row/column counts
- Status messages

**Example:**
```dart
Semantics(
  label: 'Customer data grid, ${rows.length} rows, ${columns.length} columns',
  child: DataTable(...),
)
```

---

### Focus Management

- Visible focus indicators
- Focus trapping in dialogs
- Focus restoration on dialog close
- Skip navigation links

---

### Color & Contrast

- WCAG AA contrast ratios (4.5:1 text, 3:1 UI)
- Don't rely on color alone
- High contrast mode support

---

## 7. Internationalization (i18n)

### Locale-Aware Formatting

- Date/time formatting per locale
- Number/currency formatting
- Text direction (RTL support)
- Collation for sorting

**Approach**: Server provides formatted strings in state, or Genux uses Dart intl package.

---

### Translatable Content

Wire documents contain content keys, not literal text:

```json
{
  "component": "Text",
  "bind": {
    "text": "/i18n/customer.name.label"
  }
}
```

State contains translations:
```json
{
  "i18n": {
    "customer.name.label": "Customer Name",
    "customer.save.button": "Save Customer"
  }
}
```

---

## 8. Security Enhancements

### Row-Level Security

Server returns only authorized rows. Client doesn't filter.

---

### Field-Level Security

Hide/disable fields based on permissions:

```json
{
  "component": "TextField",
  "bind": {
    "value": "/draft/salary",
    "enabled": "/permissions/canEditSalary"
  }
}
```

---

### Audit Trail

Log all user actions for compliance:

```dart
case 'customer.save':
  await auditLog(
    userId: currentUser.id,
    action: 'customer.update',
    resourceId: customerId,
    changes: computeDiff(oldData, newData),
    timestamp: DateTime.now(),
  );
```

---

### Data Sanitization

Sanitize user input before storing:

```dart
case 'comment.add':
  final rawComment = invocation.arguments['text'];
  final sanitized = sanitizeHtml(rawComment);
  await saveComment(sanitized);
```

---

## 9. Developer Experience

### Form Builder Tool

Visual editor for creating Genux forms:
- Drag-drop components
- Configure properties
- Set bindings visually
- Preview real-time
- Export to JSON

---

### Component Playground

Interactive component browser:
- Browse all components
- Adjust properties live
- Copy wire JSON
- View accessibility info

---

### Schema Validator

Validate wire documents in CI/CD:

```bash
genux validate customer-edit.genux.json --catalog=aix.core@2
```

---

### TypeScript Definitions

Generate TypeScript types from catalog:

```typescript
interface ListView {
  component: 'ListView';
  version: 1;
  props: {
    itemHeight: number; // 20-1000
    divider?: boolean;
    padding?: number; // 0-64
  };
  bind: {
    items: string; // path to list<object>
    loading?: string;
    emptyMessage?: string;
  };
  events?: {
    itemTapped?: string; // action ID
  };
  slots: {
    itemTemplate: [string]; // exactly 1 child
  };
}
```

---

## 10. Migration Path

### Phase 1: Core Enhancements (Months 1-2)
- DataGrid with filtering, sorting, selection
- DateTimePicker, FileUpload, SearchBox
- Pagination component
- Enhanced validation framework

### Phase 2: Advanced Components (Months 3-4)
- TreeView, Calendar, Kanban
- RichTextEditor, MultiSelect
- Tabs, Accordion, Dialog, Stepper
- Charts integration

### Phase 3: Performance & Scale (Months 5-6)
- Column virtualization in DataGrid
- Lazy loading improvements
- Memory optimization
- 100K+ row benchmarks

### Phase 4: Enterprise Features (Months 7-9)
- Advanced filtering UI
- Bulk operations framework
- Offline sync system
- Audit logging
- Row-level security

### Phase 5: DX & Tooling (Months 10-12)
- Form builder tool
- Component playground
- Schema validator
- TypeScript definitions
- Migration guides

---

## 11. Example: ERP Inventory Screen

Complete example showing multiple enterprise features:

```json
{
  "schema": "aix.genux/1.0",
  "view": {
    "code": "erp.inventory",
    "revision": 1
  },
  "catalog": {
    "id": "aix.enterprise",
    "version": 1
  },
  "root": "inventoryScreen",
  "state": {
    "inventory": {
      "items": [], // Loaded from server
      "totalCount": 0,
      "currentPage": 1,
      "pageSize": 50
    },
    "ui": {
      "loading": false,
      "selectedIds": [],
      "filters": {
        "category": null,
        "minStock": null,
        "location": null
      },
      "sortColumn": "sku",
      "sortDirection": "asc",
      "expandedRow": null
    },
    "permissions": {
      "canEdit": true,
      "canDelete": false,
      "canExport": true
    }
  },
  "actions": {
    "loadPage": {
      "capability": "inventory.query",
      "args": {
        "page": {"$bind": "/inventory/currentPage"},
        "pageSize": {"$bind": "/inventory/pageSize"},
        "filters": {"$bind": "/ui/filters"},
        "sort": {
          "column": {"$bind": "/ui/sortColumn"},
          "direction": {"$bind": "/ui/sortDirection"}
        }
      }
    },
    "applyFilters": {
      "capability": "inventory.filter",
      "args": {"filters": {"$bind": "/ui/filters"}}
    },
    "updateStock": {
      "capability": "inventory.updateStock",
      "args": {
        "itemId": {"$bind": "/item/data/id"},
        "quantity": {"$bind": "/item/data/quantity"}
      }
    },
    "bulkExport": {
      "capability": "inventory.export",
      "args": {"itemIds": {"$bind": "/ui/selectedIds"}}
    },
    "viewDetails": {
      "capability": "view.open",
      "args": {
        "viewCode": "erp.inventory.detail",
        "itemId": {"$bind": "/item/data/id"}
      }
    }
  },
  "nodes": [
    {
      "id": "inventoryScreen",
      "component": "Column",
      "version": 1,
      "props": {"gap": 16, "crossAxisAlignment": "stretch"},
      "slots": {"children": ["header", "filterBar", "bulkActions", "dataGrid", "pagination"]}
    },
    {
      "id": "header",
      "component": "Row",
      "version": 1,
      "props": {"gap": 16, "mainAxisSize": "max", "crossAxisAlignment": "center"},
      "slots": {"children": ["title", "searchBox", "refreshButton"]}
    },
    {
      "id": "filterBar",
      "component": "FilterBuilder",
      "version": 1,
      "props": {
        "fields": [
          {"key": "category", "label": "Category", "type": "choice"},
          {"key": "minStock", "label": "Min Stock", "type": "number"},
          {"key": "location", "label": "Location", "type": "string"}
        ]
      },
      "bind": {"filters": "/ui/filters"},
      "events": {"filtersChanged": "applyFilters"}
    },
    {
      "id": "bulkActions",
      "component": "BulkActionBar",
      "version": 1,
      "bind": {
        "selectedCount": "/ui/selectedIds/length",
        "visible": "/ui/hasSelection"
      },
      "slots": {
        "actions": ["exportButton", "deleteButton"]
      }
    },
    {
      "id": "dataGrid",
      "component": "DataGrid",
      "version": 1,
      "props": {
        "columns": [
          {"key": "sku", "label": "SKU", "width": 120, "sortable": true, "frozen": true},
          {"key": "name", "label": "Product", "flex": 2, "sortable": true},
          {"key": "category", "label": "Category", "flex": 1, "sortable": true},
          {"key": "quantity", "label": "Quantity", "width": 100, "sortable": true, "editable": true},
          {"key": "location", "label": "Location", "flex": 1},
          {"key": "lastUpdated", "label": "Last Updated", "width": 150, "sortable": true}
        ],
        "selectionMode": "multiple",
        "editable": true,
        "frozenColumns": 1,
        "showFilters": true,
        "striped": true
      },
      "bind": {
        "rows": "/inventory/items",
        "loading": "/ui/loading",
        "selectedIds": "/ui/selectedIds",
        "sortColumn": "/ui/sortColumn",
        "sortDirection": "/ui/sortDirection"
      },
      "events": {
        "rowClicked": "viewDetails",
        "cellEdited": "updateStock",
        "selectionChanged": "updateSelection",
        "sortChanged": "loadPage"
      }
    },
    {
      "id": "pagination",
      "component": "Pagination",
      "version": 1,
      "props": {
        "showSizeSelector": true,
        "pageSizes": [25, 50, 100, 200]
      },
      "bind": {
        "currentPage": "/inventory/currentPage",
        "pageSize": "/inventory/pageSize",
        "totalCount": "/inventory/totalCount"
      },
      "events": {
        "pageChanged": "loadPage",
        "sizeChanged": "loadPage"
      }
    }
  ]
}
```

---

## Summary

**Immediate Priorities (MVP for Enterprise):**

1. ✅ DataGrid with filtering, sorting, pagination, selection
2. ✅ DateTimePicker and FileUpload
3. ✅ TreeView for hierarchical data
4. ✅ Enhanced validation framework
5. ✅ Dialog/Modal component
6. ✅ Tabs component
7. ✅ SearchBox with autocomplete
8. ✅ Pagination component

**Medium Priority:**

9. Calendar component
10. RichTextEditor
11. Charts integration
12. Stepper/Wizard
13. Accordion/Expansion panels
14. MultiSelect with tags

**Long Term:**

15. Kanban board
16. Advanced filtering UI
17. Bulk operations framework
18. Form builder tool
19. Component playground
20. Offline sync system

**Estimated Effort**: 9-12 months for complete enterprise-ready library with 2-3 full-time developers.

The existing Genux architecture is solid. The main gaps are specialized components and advanced interaction patterns. The security model, state management, and compilation pipeline are already production-quality.
