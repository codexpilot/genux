# Component ID Migration Analysis

## Current State Investigation

### ✅ Where Component IDs Are Stored

Based on code inspection, here's what I found:

#### 1. **Runtime Catalog (In-Memory)**
- **Location**: `lib/src/catalog/core_catalog.dart` and `core_catalog_v2.dart`
- **Storage**: Dart code defining component definitions
- **Current IDs**: 1-12 (sequential)
- **Impact**: ⚠️ **MUST CHANGE** - This is the source of truth for runtime

#### 2. **JSON View Documents (Asset Files)**
- **Location**: `assets/views/*.genux.json` (4 files)
- **Storage**: JSON files with `"component": "Text"` (string names only)
- **Current State**: ❌ **NO componentId fields yet**
- **Impact**: ✅ **SAFE** - No numeric IDs stored, only string names

#### 3. **Database (Server-Side - NOT YET IMPLEMENTED)**
- **Location**: CloudX/Aix relational tables (see `storage-model.md`)
- **Storage**: PostgreSQL tables: `uicomponentx`, `viewnodex`
- **Current State**: ❌ **NOT IMPLEMENTED YET**
- **Impact**: ✅ **SAFE** - No production database exists yet

#### 4. **Test Files**
- **Location**: `test/numeric_component_id_test.dart`
- **Storage**: Hard-coded expectations
- **Current IDs**: Expects 1-12
- **Impact**: ⚠️ **MUST UPDATE** - Tests will fail after migration

---

## 🔍 Key Findings

### ✅ **GOOD NEWS: Safe to Migrate!**

1. **No Production Database**: The relational storage model is documented but not implemented yet
2. **No Numeric IDs in JSON**: All existing JSON files use string names only (`"component": "Text"`)
3. **Backward Compatible**: String names will continue to work even after ID changes
4. **Only Test Files**: Only test expectations need updating

### 📊 Data Storage Locations

```
┌─────────────────────────────────────────────────────────────┐
│ STORAGE LOCATION              │ CURRENT STATE │ MIGRATION   │
├─────────────────────────────────────────────────────────────┤
│ Dart Catalog Definitions      │ IDs 1-12      │ ⚠️ CHANGE   │
│ JSON Asset Files              │ No IDs        │ ✅ SAFE     │
│ Test Expectations             │ IDs 1-12      │ ⚠️ UPDATE   │
│ CloudX Database (future)      │ N/A           │ ✅ SAFE     │
│ Published Artifacts (future)  │ N/A           │ ✅ SAFE     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗄️ Future Database Schema (From storage-model.md)

### Relevant Tables

```sql
-- Catalog registry (server-side)
uicatalogx (
  i BIGINT,              -- Catalog identity
  version INT,           -- Release version (1, 2, etc.)
  checksum TEXT,         -- SHA-256 manifest hash
  ...
)

uicomponentx (
  i BIGINT,              -- Component identity
  catalog_i BIGINT,      -- FK to catalog
  code TEXT,             -- Component name ("Text", "Button")
  version INT,           -- Component version
  -- NOTE: No numeric ID field mentioned yet
  ...
)

-- View documents (server-side)
viewnodex (
  i BIGINT,              -- Node identity
  revision_i BIGINT,     -- FK to view revision
  node_code TEXT,        -- Node ID in document
  component_code TEXT,   -- References component by name
  -- NOTE: Uses component_code (string), not component_id
  ...
)
```

### 🎯 **Critical Insight**

The database schema currently references components by **string code**, not numeric ID!

This means:
- ✅ Changing runtime IDs won't break any database
- ✅ No migration scripts needed
- ⚠️ Future enhancement: Add `component_id` column to `uicomponentx` table

---

## 📋 Migration Impact Assessment

### Files That MUST Change

#### 1. **Catalog Definitions** (Source of Truth)
```
lib/src/catalog/core_catalog.dart       - 10 component IDs
lib/src/catalog/core_catalog_v2.dart    - 2 component IDs
```

**Change Type**: ID reassignment
```dart
// OLD
GenuxComponentDefinition(id: 1, code: 'Column', ...)
GenuxComponentDefinition(id: 2, code: 'Text', ...)

// NEW
GenuxComponentDefinition(id: 10, code: 'Column', ...)
GenuxComponentDefinition(id: 40, code: 'Text', ...)
```

#### 2. **Test Files**
```
test/numeric_component_id_test.dart     - 12 ID expectations
```

**Change Type**: Update assertions
```dart
// OLD
expect(catalog.component('Column')?.id, equals(1));

// NEW
expect(catalog.component('Column')?.id, equals(10));
```

### Files That Are SAFE (No Changes Needed)

#### 1. **JSON Asset Files** ✅
```
assets/views/customer-edit.genux.json
assets/views/customer-summary.genux.json
assets/views/customer-list.genux.json
assets/views/component-lab.genux.json
```

**Why Safe**: These files only use string names:
```json
{"component": "Text"}  // ✅ No numeric ID
```

#### 2. **Runtime Code** ✅
```
lib/src/model/document.dart
lib/src/compiler/document_compiler.dart
lib/src/validation/document_validator.dart
```

**Why Safe**: Code resolves by ID OR name, backward compatible

---

## 🔄 Migration Strategy

### Phase 1: Update Catalog IDs (Immediate)

**Files to Modify:**
1. `lib/src/catalog/core_catalog.dart`
2. `lib/src/catalog/core_catalog_v2.dart`
3. `test/numeric_component_id_test.dart`
4. `docs/numeric-component-registry.md`

**Old → New Mapping:**
```
OLD ID → NEW ID (Layer-Based)

1  (Column)         → 10  (Layout)
2  (Text)           → 40  (Display)
3  (TextField)      → 70  (Input)
4  (Checkbox)       → 80  (Input)
5  (ComboBox)       → 85  (Input)
6  (Button)         → 100 (Action)
7  (Form)           → 150 (Container)
8  (Row)            → 11  (Layout)
9  (Card)           → 21  (Container)
10 (Divider)        → 30  (Separator)
11 (CollectionView) → 122 (Data)
12 (Expanded)       → 15  (Layout)
```

### Phase 2: Future JSON Optimization (Optional)

When authoring tools start using numeric IDs:
```json
{
  "id": "myText",
  "component": "Text",
  "componentId": 40,  // ← Add this later
  "version": 1
}
```

**Timeline**: After CloudX integration

### Phase 3: Database Schema Enhancement (Future)

When implementing CloudX/Aix database:
```sql
ALTER TABLE uicomponentx 
ADD COLUMN numeric_id INT UNIQUE;

-- Populate with layer-based IDs
UPDATE uicomponentx SET numeric_id = 10 WHERE code = 'Column';
UPDATE uicomponentx SET numeric_id = 40 WHERE code = 'Text';
...
```

**Timeline**: When relational storage is implemented

---

## ⚠️ Breaking Changes

### For Runtime (Minimal Impact)

**What Breaks:**
- ❌ Hard-coded numeric ID references (none exist in JSON files)
- ❌ Test expectations (easy to fix)

**What Still Works:**
- ✅ String component names ("Text", "Button")
- ✅ All existing JSON documents
- ✅ Backward compatibility maintained

### For Future CloudX Integration

**Recommendation**: When implementing the database:

1. Store both `component_code` (string) and `component_id` (numeric)
2. Use `component_id` as primary lookup, `component_code` as fallback
3. Include both in published artifacts for safety

---

## 📝 Migration Checklist

### Pre-Migration
- [x] ✅ Verify no production database exists
- [x] ✅ Confirm JSON files use string names only
- [x] ✅ Document current ID → new ID mapping
- [x] ✅ Identify all files requiring changes

### Migration Execution
- [ ] Update `core_catalog.dart` with new IDs (10-39 range)
- [ ] Update `core_catalog_v2.dart` with new IDs (15, 122)
- [ ] Update `numeric_component_id_test.dart` expectations
- [ ] Update `numeric-component-registry.md` documentation
- [ ] Run all tests and verify passing
- [ ] Update CHANGELOG.md with breaking change notice

### Post-Migration
- [ ] Verify backward compatibility (string names work)
- [ ] Document layer-based ID system
- [ ] Update CloudX integration plan
- [ ] Plan database schema enhancement

---

## 🎯 Recommendation: PROCEED WITH MIGRATION

### Why It's Safe

1. ✅ **No production data** - Database doesn't exist yet
2. ✅ **No numeric IDs in use** - JSON files only use string names
3. ✅ **Backward compatible** - String names continue working
4. ✅ **Easy rollback** - Just change the Dart code back

### Benefits

1. 🎯 **Logical grouping** - 10s = layout, 40s = display, etc.
2. 📦 **Room for growth** - 30 slots per category
3. 🧠 **Memorable** - Easy to remember ID ranges
4. 🔮 **Future-proof** - Scalable to 246 components

### Risk Level: **LOW** ⚠️

The only risk is test failures, which are trivial to fix.

---

## 🚀 Next Steps

**Ready to proceed with Migration Phase 1?**

I can immediately:
1. Update all catalog definitions with new layer-based IDs
2. Update test expectations
3. Verify all tests pass
4. Update documentation

**Estimated time**: 15 minutes

Shall I proceed with the migration? 🎯
