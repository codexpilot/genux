# Changelog

All notable changes to Genux will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- **Two-Tab Workspace Layout**: True tab-based UI (not side-by-side)
  - Tab 1: JSON Source editor (full-screen)
  - Tab 2: Runtime View preview (full-screen)
  - "Apply & View" button applies changes and switches to Runtime tab
  - Matches DartPad's mobile experience exactly
- **Full Theme System**: Light/Dark/System modes with persistence
  - Theme toggle button in app bar with cycling behavior
  - Persistent storage using SharedPreferences
  - System mode follows OS theme preference
  - Smooth transitions between themes
  - Icons and tooltips show current mode
- **A2: Action Context Requirements**: Compile-time validation ensuring item/event bindings are only used where those contexts are available
  - Context tracking system for item template slots
  - `action.contextUnavailable` diagnostic for violations
- **A3: Static vs Deferred Resolution**: Type-check literals and resolved state bindings at compile time; defer item/event bindings to runtime
  - Analyzer architecture using sealed class hierarchy
  - Known values type-checked immediately, deferred values skip compile-time checking
- **A4: Independent Fallback Validation**: Validate fallback values independently of primary paths
  - Reject bindings in fallbacks (must be literals)
  - Type-check fallbacks even when primary path exists
  - Precise error locations (`$location/fallback`)
- **A8: Showcase Bounded Viewport**: Automatically wrap CollectionView in 500px viewport to prevent infinite scroll issues
- **CollectionView Tests**: Comprehensive test coverage with keyboard interaction tests

### Changed
- **Showcase Architecture**: Simplified to single workspace with bottom navigation bar (JSON and PREVIEW)
- **Document Validator**: Replaced old procedural validation (~220 lines) with analyzer-based approach
  - Better error messages with precise locations
  - Cleaner separation of concerns (analyze → validate → type-check)
  - Type-safe result representation
- **Test Suite**: Updated widget tests to match new showcase UI (88/89 passing, 98.9% pass rate)

### Fixed
- **Keyboard Focus Tests**: CollectionView keyboard event tests now properly settle focus state before sending events
  - Use `pumpAndSettle()` instead of `pump()`
  - Explicitly request focus on Focus widget ancestor
- **Toolbar Overflow**: Fixed horizontal overflow in narrow viewports by using IconButton and Expanded widgets

### Removed
- Old three-tab showcase navigation (Workspace, Catalog, Runtime pages)
- Obsolete validation functions: `_validateActionValue()`, `_resolveActionValue()`
- Unused enum value: `_KnownJsonShape.scalar`
- Redundant documentation files: progress tracking and status files

## [1.0.0] - 2026-07

### Initial Release
- JSON-driven UI runtime for Flutter
- Transactional state store with binding system
- Multi-view navigation with view stack coordinator
- Component catalog with Material Design widgets
- Document compiler with comprehensive validation
- CollectionView and DataView foundation components
- Enterprise application patterns and best practices
- Complete test coverage for core functionality

[Unreleased]: https://github.com/aix/genux/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/aix/genux/releases/tag/v1.0.0
