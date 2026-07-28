# DataView Foundation - Implementation Handover

**Status**: ✅ Complete and Released  
**Date**: July 2026  
**Catalog Version**: aix.core@2  
**Test Coverage**: 70 tests passing, 0 failures

## Executive Summary

Successfully implemented the DataView foundation for Genux, introducing CollectionView component with list and grid layouts, evaluation context for item/event bindings, and catalog backwards compatibility. All handover requirements met with comprehensive test coverage.

## What Was Implemented

### 1. Evaluation Context & Binding Sources
- **Purpose**: Support item-scoped bindings in collection templates and event payloads in actions
- **Implementation**: 
  - `GenuxEvaluationContext` with state/item/event data sources
  - Explicit binding syntax: `{"$bind": {"source": "item|event|state", "path": "/..."}}`
  - Shorthand for state bindings: `{"$bind": "/path"}` (backwards compatible)
- **Files Modified**:
  - `lib/src/model/document.dart` - Added evaluation context to action resolution
  - `lib/src/validation/document_validator.dart` - Validate binding sources and skip type-checking for unresolved bindings
  - `lib/src/compiler/document_compiler.dart` - Parse explicit binding objects

### 2. CollectionView Component
- **Specification**: List and grid layouts with lazy template rendering
- **Properties**:
  - `layout`: "list" | "grid"
  - `itemKey`: string (required) - Key path in item data
  - `itemHeight`: number (list only, required)
  - `columns`: number (grid only, required)
  - `aspectRatio`: number (grid only)
  - `spacing`: number, `padding`: number
  - `emptyMessage`: string
- **Channels**:
  - `items`: input, required - Array of item data
- **Slots**:
  - `itemTemplate`: Single child node rendered for each item
- **Events**:
  - `itemInvoked`: Fires when item is tapped, payload: `{item: object, index: number}`
- **Renderer**: `lib/src/flutter/collection_view_renderer.dart`
  - Uses ListView.builder / GridView.builder for virtualization
  - Lazy template rendering via `SurfaceHost.template()` with item context
  - Proper key management for Flutter performance

### 3. Catalog V2 & Backwards Compatibility
- **aix.core@2 Catalog**: Created `lib/src/catalog/core_catalog_v2.dart`
  - All 10 v1 components + CollectionView + Expanded = 12 total
  - Checksum: `sha256:a1b2c3d4e5f6789012345678901234567890123456789012345678901234abcd`
- **Backwards Compatibility**:
  - Validator allows document.version <= runtime.version
  - SurfaceHost permits v1 documents with v2 Flutter catalog
  - Checksum validation only when versions match exactly
  - customer-edit.genux.json (v1) runs on ShowcaseRuntime (v2)

### 4. SurfaceHost Template Rendering
- **New API**: `SurfaceHost.template()` constructor
- **Purpose**: Render a single node with custom evaluation context (for item templates)
- **Usage**: CollectionView renderer creates one SurfaceHost.template per visible item
- **Implementation**: `lib/src/flutter/surface_host.dart`

### 5. Customer List Demo
- **File**: `assets/views/customer-list.genux.json`
- **Features**:
  - List and grid layout toggles
  - 3-item demo collection with proper itemKey binding
  - itemInvoked action logging to console
  - Demonstrates all CollectionView properties and events
- **Integration**: Exposed in showcase navigation as "Customer List · CollectionView demo"

## Test Coverage

### Test Files
1. **test/component_lab_test.dart** (3 tests)
   - Validates Component Lab compilation
   - Ensures catalog coverage (11 of 12 components, CollectionView in customer.list)
   - Button variant coverage

2. **test/dataview_catalog_test.dart** (1 test)
   - Verifies CollectionView registered in aix.core@2
   - Validates component version and structure

3. **test/document_compiler_test.dart** (9 tests)
   - Explicit binding source validation
   - Action argument type checking
   - Catalog version compatibility

4. **test/surface_host_test.dart** (27 tests)
   - Template rendering with item context
   - CollectionView renderer behavior
   - Catalog mismatch handling

5. **test/widget_test.dart** (7 tests)
   - End-to-end showcase navigation
   - Component Lab interaction
   - MultiView state preservation

6. **test/surface_session_test.dart** (23 tests)
   - Session state management
   - Action dispatch with bindings

**Total**: 70 tests, all passing

## Key Design Decisions

### Why CollectionView Is Not in Component Lab
Component Lab uses SingleChildScrollView for its root, creating a scrollable container. CollectionView uses ListView/GridView which are also scrollable. Flutter does not allow nested scrollables without bounded constraints. 

**Options considered**:
1. Make Component Lab non-scrollable - breaks on small screens
2. Wrap CollectionView in fixed-height container - requires SizedBox component
3. Demonstrate CollectionView separately - chosen solution

**Decision**: CollectionView is fully demonstrated in customer-list.genux.json with proper bounded layout. Component Lab covers the other 11 components.

### Binding Source Validation Strategy
**Challenge**: At compile time, item and event bindings cannot be resolved (no runtime data yet).

**Solution**: 
- Validator checks binding path syntax for all sources
- Type checking only for state bindings (resolvable at compile time)
- Item/event bindings return `null` during validation, skipping type checks
- Runtime resolution happens in SurfaceHost with actual item/event context

### Catalog Version Compatibility
**Requirement**: ShowcaseRuntime uses v2, but existing fixtures are v1.

**Solution**:
- Semantic versioning: v2 is v1 + new components (additive change)
- Allow document.version <= runtime.version (backwards compatible)
- Skip checksum validation for cross-version documents
- Maintain strict validation for same-version documents

## Token Usage

**Opus 5 Usage**: ~72,000 tokens (36% of 200k budget)

This includes:
- Reading handover document and codebase
- Implementing 6 major features
- Writing 1 new test file + updating 4 others
- Debugging and fixing 5 critical issues
- Documentation updates

## Files Changed

### New Files (5)
- `lib/src/catalog/core_catalog_v2.dart` - aix.core@2 catalog definition
- `lib/src/flutter/collection_view_renderer.dart` - CollectionView Flutter renderer
- `lib/src/flutter/item_context.dart` - Item evaluation context (deprecated, moved to document.dart)
- `test/dataview_catalog_test.dart` - CollectionView catalog tests
- `docs/dataview-components.md` - CollectionView specification

### Modified Files (13)
- `lib/src/model/document.dart` - Evaluation context integration
- `lib/src/compiler/document_compiler.dart` - Explicit binding parsing
- `lib/src/validation/document_validator.dart` - Binding source validation, backwards compat
- `lib/src/flutter/surface_host.dart` - Template rendering, catalog version check
- `lib/src/flutter/material_catalog.dart` - V2 component registration
- `lib/src/catalog/catalog.dart` - Exported core_catalog_v2
- `lib/src/runtime/surface_session.dart` - Action resolution with context
- `lib/src/flutter/component_scope.dart` - Context parameter
- `lib/showcase/showcase_runtime.dart` - Upgraded to aix.core@2
- `lib/showcase/pages/workspace_page.dart` - customer.list navigation
- `assets/views/component-lab.genux.json` - Updated to aix.core@2 (without CollectionView)
- `assets/views/customer-list.genux.json` - Complete CollectionView demo
- `assets/views/customer-summary.genux.json` - Upgraded to v2
- `README.md` - Updated stats and implementation status
- `test/*.dart` - Test updates for new features

## Verification Checklist

✅ All 70 tests passing  
✅ Flutter analyzer reports no issues  
✅ customer-list.genux.json compiles and renders  
✅ Component Lab covers 11 of 12 aix.core@2 components  
✅ Backwards compatibility: v1 documents run on v2 runtime  
✅ CollectionView demonstrates all properties, channels, slots, events  
✅ Item context properly scoped in templates  
✅ Event payloads accessible in action arguments  
✅ Documentation updated with implementation status  
✅ Showcase navigation includes customer.list  

## Known Limitations

1. **CollectionView in scrollable containers**: Requires bounded height constraint. Not suitable for Component Lab's scrollable layout.

2. **Item context validation**: Type checking deferred to runtime for item/event bindings. Validation errors appear during execution, not compilation.

3. **Fixed checksums**: aix.core@2 uses placeholder checksum. Production requires canonical catalog manifest generation.

4. **No DataGrid yet**: Two-dimensional virtualization planned but not implemented.

## Next Steps for DataGrid

Based on this CollectionView foundation:

1. **Column Management**: Define column schema in metadata
2. **Cell Templates**: Per-column template slots with cell context
3. **Two-Dimensional Virtualization**: Horizontal + vertical scrolling
4. **Measured Cells**: Dynamic column widths based on content
5. **Selection Model**: Row/cell selection with keyboard navigation
6. **Sorting & Filtering**: Client-side data operations

See docs/dataview-components.md for full DataGrid specification (design phase).

## References

- [Evaluation Context ADR](adr-evaluation-context.md)
- [Architecture](architecture.md)
- [Component Lab](component-lab.md)
- [Customer List Fixture](../assets/views/customer-list.genux.json)
- [CollectionView Specification](dataview-components.md)
