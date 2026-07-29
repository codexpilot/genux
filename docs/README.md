# Genux Documentation

This directory contains documentation for the Genux runtime frontend framework.

## Core Documentation

### Architecture & Design
- [architecture.md](architecture.md) - System architecture and component overview
- [binding-model.md](binding-model.md) - Data binding and state management
- [storage-model.md](storage-model.md) - State storage and transaction model
- [protocol-v1-draft.md](protocol-v1-draft.md) - JSON protocol specification draft

### Features
- [multiview.md](multiview.md) - Multi-view navigation and view stack management
- [dataview-components.md](dataview-components.md) - DataView and CollectionView components
- [component-lab.md](component-lab.md) - Component testing and catalog

### Implementation Details
- [adr-evaluation-context.md](adr-evaluation-context.md) - Architecture decision record for evaluation context
- [opus-a2-a8-implementation.md](opus-a2-a8-implementation.md) - Implementation details for specifications A2-A8
- [FINAL-IMPLEMENTATION-REPORT.md](FINAL-IMPLEMENTATION-REPORT.md) - Complete implementation report for A2-A8

### Enterprise & Use Cases
- [enterprise-applications.md](enterprise-applications.md) - Enterprise application patterns and best practices

### Handover Documents
- [genux-opus-coding-handover.md](genux-opus-coding-handover.md) - Development handover guide
- [handover-dataview-foundation.md](handover-dataview-foundation.md) - DataView foundation handover
- [package-a-final-report.md](package-a-final-report.md) - Package A implementation final report

## Quick Start

1. Read [architecture.md](architecture.md) for system overview
2. Review [binding-model.md](binding-model.md) to understand data flow
3. Check [protocol-v1-draft.md](protocol-v1-draft.md) for JSON document format
4. See [component-lab.md](component-lab.md) to explore available components

## Recent Updates

### July 2026
- **A2-A8 Specifications**: Completed implementation with 100% test coverage
- **Showcase Redesign**: Restructured to DartPad-style two-pane layout (JSON editor + runtime view)
- **Action Validation**: Enhanced compile-time validation for action arguments
- **CollectionView**: Fixed keyboard focus tests and added bounded viewport support

## Diagrams

Visual diagrams for architecture and data flow are available in the [diagrams/](diagrams/) directory.

## Contributing

When adding new documentation:
1. Use clear, concise English
2. Include code examples where appropriate
3. Link to related documents
4. Update this README with the new file
5. Keep implementation details separate from architectural overview

## Maintenance

Documentation should be kept in sync with code changes. Major feature additions should include:
- Architecture documentation updates
- Protocol changes (if applicable)
- Example code snippets
- Migration guides (if breaking changes)
