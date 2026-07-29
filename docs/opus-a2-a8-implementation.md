# A2-A8 Implementation Summary

This document summarizes the implementation of specifications A2-A4 and A8 for the Genux project.

## A2: Action Context Requirements at Use Sites

**Specification**: Item/event bindings in action arguments must only be used where those contexts are available.

**Implementation**: 
- Added `_collectNodeItemContexts()` function to identify which nodes are inside item template contexts
- After analyzing all actions, validate that actions using item/event bindings are only invoked from appropriate contexts
- Reports `action.contextUnavailable` diagnostic when context requirements are violated

**Location**: `lib/src/validation/document_validator.dart` lines ~493-542

**Tests**: `test/action_validation_test.dart` - "A2: Action context requirements at use sites" group (3 tests)

## A3: Static vs Deferred Resolution

**Specification**: 
- Explicit literals and resolved state bindings are type-checked at compile time
- Item/event bindings defer type-checking to runtime
- Null values (explicit or resolved) are type-checked against argument nullability

**Implementation**:
- Created analyzer types: `_StaticActionResolution`, `_KnownActionValue`, `_DeferredActionValue`, `_InvalidActionValue`
- `_analyzeActionValue()` function performs static analysis:
  - Returns `_KnownActionValue` for literals and resolvable state bindings
  - Returns `_DeferredActionValue` for item/event bindings
  - Returns `_InvalidActionValue` for invalid structures
- Type checking happens at the argument level (lines ~461-487):
  - Known values (including null) are type-checked immediately
  - Deferred values skip type-checking with a comment

**Location**: `lib/src/validation/document_validator.dart` lines ~538-895

**Tests**: `test/action_validation_test.dart` - "A3: Static vs deferred resolution" group (3 tests)

## A4: Independent Fallback Validation

**Specification**:
- Fallback values must be validated independently of the primary binding path
- Fallbacks cannot contain bindings (must be literal values)
- Type checking applies to fallbacks regardless of whether the primary path exists

**Implementation**:
- Added `_containsBinding()` helper function to recursively detect `$bind` expressions
- In all three binding path branches (explicit source, string shorthand), before analyzing fallback:
  1. Check if fallback contains any bindings using `_containsBinding()`
  2. Report `action.bindingFallback` error if bindings found
  3. Analyze fallback value and return as `_KnownActionValue`
- Modified type-checking logic to detect when an error comes from a fallback and report the location as `$location/fallback`

**Location**: 
- Helper: `lib/src/validation/document_validator.dart` lines ~629-641
- Validation: lines ~755-772, ~781-798, ~820-836
- Type check location fix: lines ~464-486

**Tests**: `test/action_validation_test.dart` - "A4: Independent fallback validation" group (4 tests)

## A8: Showcase Bounded Viewport

**Specification**: When customer-list fixture is displayed in showcase, wrap the surface in a bounded viewport to prevent infinite scroll layout issues.

**Implementation**:
- Modified `workspace_page.dart` to detect CollectionView components in the active document
- When CollectionView is detected, wrap `GenuxSurfaceHost` in:
  ```dart
  Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: host,
    ),
  )
  ```
- Added navigation button in `customer-edit.genux.json` to navigate to customer list:
  - Added `openCustomerList` action
  - Added `customerListButton` button component
  - Incremented revision from r6 to r7

**Location**: 
- Viewport logic: `lib/showcase/pages/workspace_page.dart` lines ~599-619
- Navigation: `assets/views/customer-edit.genux.json`

**Tests**: Updated `test/widget_test.dart` to expect revision r7 instead of r6

## Code Cleanup

**Removed**:
- Old `_validateActionValue()` function (~180 lines)
- Old `_resolveActionValue()` function (~40 lines)
- Unused `_KnownJsonShape.scalar` enum value

These were replaced by the new analyzer-based approach.

## Test Results

**All A2-A4 tests**: 10/10 passing ✓
**Full test suite**: 89/89 passing (100%) ✓

All tests now pass! The keyboard focus tests that were initially failing were fixed by:
- Using `pumpAndSettle()` instead of `pump()` to allow focus state to fully settle
- Explicitly requesting focus on the Focus widget ancestor before sending keyboard events
- This ensures keyboard events are properly routed to the focused CollectionView items

## Key Design Decisions

1. **Analyzer Pattern**: Used a sealed class hierarchy (`_StaticActionResolution`) to represent the three possible outcomes of static analysis. This makes the control flow explicit and type-safe.

2. **Independent Fallback Validation**: Checked for bindings in fallbacks *before* analyzing them, ensuring we catch both state bindings (which would resolve) and item/event bindings (which would defer). This satisfies the "independent" requirement.

3. **Location Precision**: When type errors originate from fallbacks, report them at `$location/fallback` rather than `$location` to help developers identify the exact source of the error.

4. **Bounded Viewport Strategy**: Used component detection (`node.component.code == 'CollectionView'`) rather than view code matching, making the solution more robust and applicable to any view with CollectionView.

## Files Modified

- `lib/src/validation/document_validator.dart` - Core A2-A4 implementation
- `lib/showcase/pages/workspace_page.dart` - A8 bounded viewport
- `assets/views/customer-edit.genux.json` - Navigation to customer list
- `test/action_validation_test.dart` - New comprehensive tests for A2-A4 (545 lines)
- `test/widget_test.dart` - Updated revision expectations (r6 → r7)
- `test/collection_view_test.dart` - Fixed keyboard focus test timing issues

## Migration Notes

The old validation functions (`_validateActionValue` and `_resolveActionValue`) have been completely removed and replaced by the new analyzer. No migration is needed for existing code as the validation happens during document compilation.
