# Genux Project Diagrams - README

This directory contains comprehensive architecture and implementation diagrams for the Genux project.

## Diagram Files

### 1. [architecture-overview.md](./architecture-overview.md)
High-level system architecture and component relationships.

**Contents:**
- System Overview (CloudX → Aix → Genux Client)
- Wire Protocol: aix.genux/1.0
- Component Catalog Model
- Compilation Pipeline
- MultiView Stack Model
- Open Pipeline with Race Protection
- State Transaction Flow
- Action Dispatch Flow
- Binding Resolution
- Component Rendering Architecture
- Security Boundaries
- Project Structure

**Key Diagrams:**
- Full system flow from authoring to rendering
- Document structure and schema
- Catalog component definitions
- Two-stage compilation boundaries
- Security zones and validation gates

---

### 2. [multiview-details.md](./multiview-details.md)
Deep dive into MultiView implementation with navigation and state management.

**Contents:**
- Stack Navigation Flow
- Detailed Open Pipeline (all failure paths)
- Pop Operation Flow
- Race Condition Scenarios
- State Subscription Model
- Identity Resolution Rules
- Semantic Navigation Handling
- Dirty Path Tracking
- Session Lifecycle States
- Complete Customer Workflow Example
- Performance Characteristics

**Key Diagrams:**
- Latest-request-wins race protection
- Token-based superseding logic
- Session preservation and restoration
- Path-based subscription filtering
- Identity conflict detection

---

### 3. [data-flow-components.md](./data-flow-components.md)
Detailed data flow from user input through state management to server.

**Contents:**
- Complete Data Flow: User Input to Server
- Catalog Component Definition Model
- Node Compilation Process
- Value Resolution (Literal vs Binding vs Expression)
- Component Rendering Lifecycle
- JSON Pointer Path Resolution
- State Store Transaction Isolation
- 10 Core Components Overview
- Capability Registry & Dispatch
- Memory Model: Immutability
- Error Handling & Diagnostics

**Key Diagrams:**
- TextField input → state transaction → server call
- Binding compilation and resolution
- Transaction isolation and locking
- Copy-on-write state updates
- Component catalog structure

---

### 4. [dataview-architecture.md](./dataview-architecture.md)
DataView components: ListView, GridView, TableView with virtualization.

**Contents:**
- DataView Component Model
- Item Context Binding Model
- ListView Data Flow
- GridView Layout
- TableView with Sorting
- Performance: Virtualization
- State Update and Rebuild
- Complete Example: Customer List

**Key Diagrams:**
- Item template rendering with `/item/*` bindings
- Scoped session for item context
- Virtualized scrolling with 10,000 items
- Sort state management
- Memory efficiency visualization

---

## Quick Reference

### Core Concepts

| Concept | Diagram Location |
|---------|------------------|
| System Overview | architecture-overview.md → System Overview |
| Wire Protocol | architecture-overview.md → Wire Protocol |
| MultiView Stack | architecture-overview.md → MultiView Stack Model |
| Open Pipeline | multiview-details.md → Detailed Open Pipeline |
| Race Protection | multiview-details.md → Race Condition Scenarios |
| State Transaction | data-flow-components.md → State Store Transaction Isolation |
| User Input Flow | data-flow-components.md → Complete Data Flow |
| Binding Resolution | architecture-overview.md → Binding Resolution |
| Security Model | architecture-overview.md → Security Boundaries |
| DataView Components | dataview-architecture.md → DataView Component Model |
| Item Context | dataview-architecture.md → Item Context Binding Model |
| Virtualization | dataview-architecture.md → Performance: Virtualization |

### Implementation Details

| Feature | Diagram Location |
|---------|------------------|
| View Coordinator | multiview-details.md → Stack Navigation Flow |
| Session Lifecycle | multiview-details.md → Session Lifecycle |
| State Subscriptions | multiview-details.md → State Subscription Model |
| Component Rendering | data-flow-components.md → Component Rendering Lifecycle |
| JSON Pointer | data-flow-components.md → JSON Pointer Path Resolution |
| Dirty Tracking | multiview-details.md → Dirty Path Tracking |
| Capability Dispatch | data-flow-components.md → Capability Registry & Dispatch |
| Error Handling | data-flow-components.md → Error Handling & Diagnostics |

---

## Understanding the Diagrams

### Mermaid Syntax
All diagrams use [Mermaid](https://mermaid.js.org/) syntax, which renders in:
- GitHub (natively)
- GitLab
- VS Code (with Mermaid extension)
- Most modern markdown viewers

### Color Coding

Throughout the diagrams, consistent color coding is used:

- 🟢 **Green (#e8f5e9)**: Success states, completed operations, valid data
- 🔵 **Blue (#e1f5ff)**: Active operations, processing states, data in flight
- 🟡 **Yellow (#fff4e1)**: Neutral states, intermediate steps, warnings
- 🔴 **Red (#ffebee)**: Failures, errors, rejected operations
- 🟣 **Purple (#fce4ec)**: Display/UI components, user-facing elements

### Diagram Types Used

- **Flowchart**: Step-by-step processes and decision trees
- **Sequence Diagram**: Time-based interactions between components
- **State Diagram**: Lifecycle and state transitions
- **Class Diagram**: Object models and relationships
- **Graph**: Component relationships and dependencies

---

## Architecture Principles

The diagrams illustrate these key architectural principles:

### 1. **Dynamic UI Without Schema-less UI**
- Strict validation at compile time
- Immutable runtime artifacts
- No reflection, no eval, no dynamic code

### 2. **Two Compilation Boundaries**
- Server-side: CloudX → Aix artifact
- Client-side: Wire document → Compiled plan

### 3. **MultiView Above Wire Protocol**
- Each view is complete independent document
- Stack coordination is client-side only
- No multiple roots in wire format

### 4. **Security by Design**
- Validation gates before activation
- Capability-based action dispatch
- Semantic actions only (no URLs, routes, SQL)

### 5. **State Isolation**
- Independent session per view
- Copy-on-write transactions
- Dirty path tracking

### 6. **Race Protection**
- Latest-request-wins navigation
- Token-based superseding
- Atomic state commits

---

## Example Workflows

### Opening a New View
1. See: `multiview-details.md` → "Detailed Open Pipeline"
2. Follow: Token generation → Load → Compile → Verify → Activate
3. Understand: All failure paths preserve current view

### User Input Handling
1. See: `data-flow-components.md` → "Complete Data Flow"
2. Follow: Widget → Scope → Binding → Transaction → Store → Rebuild
3. Understand: Type validation, constraint checking, atomic commits

### Navigation Between Views
1. See: `multiview-details.md` → "Complete Example: Customer Workflow"
2. Follow: Edit → Open summary → Back to edit with preserved state
3. Understand: Session preservation, dirty tracking, restoration

### Action Dispatch
1. See: `architecture-overview.md` → "Action Dispatch Flow"
2. Follow: Event → Session → Dispatcher → Application handler
3. Understand: Semantic capabilities, validation, security checks

---

## Document Status

| Document | Lines | Diagrams | Status |
|----------|-------|----------|--------|
| architecture-overview.md | ~350 | 12 | ✅ Complete |
| multiview-details.md | ~450 | 11 | ✅ Complete |
| data-flow-components.md | ~550 | 13 | ✅ Complete |

**Total**: ~1,350 lines, 36 comprehensive diagrams

---

## Contributing

When adding new diagrams:

1. **Choose the right file**:
   - System architecture → architecture-overview.md
   - MultiView/navigation → multiview-details.md
   - Data flow/components → data-flow-components.md

2. **Follow conventions**:
   - Use consistent color coding
   - Add clear titles and descriptions
   - Include failure paths, not just happy paths
   - Show security boundaries

3. **Keep diagrams focused**:
   - One concept per diagram
   - Maximum 20-30 nodes per flowchart
   - Break complex flows into multiple diagrams

4. **Update this README**:
   - Add diagram to Quick Reference
   - Update line/diagram counts
   - Add to relevant Example Workflows if applicable

---

## Related Documentation

- [Architecture](../architecture.md) - Text description of architecture
- [MultiView Runtime](../multiview.md) - MultiView implementation details
- [Binding Model](../binding-model.md) - State binding rules
- [Protocol v1 Draft](../protocol-v1-draft.md) - Wire format specification
- [Component Lab](../component-lab.md) - Catalog coverage

---

## Viewing Tips

### In GitHub
Diagrams render automatically. Click "Raw" to see Mermaid source.

### In VS Code
Install "Markdown Preview Mermaid Support" extension for live preview.

### In CLI
Use `mermaid-cli` to generate PNG/SVG:
```bash
npm install -g @mermaid-js/mermaid-cli
mmdc -i architecture-overview.md -o architecture-overview.pdf
```

### Online
Copy diagram code to [Mermaid Live Editor](https://mermaid.live/) for interactive editing.

---

## Questions?

For questions about:
- **Architecture**: See architecture-overview.md → System Overview
- **MultiView**: See multiview-details.md → Stack Navigation Flow
- **State Management**: See data-flow-components.md → State Store Transaction
- **Security**: See architecture-overview.md → Security Boundaries

For implementation details, check the source code:
- `lib/src/runtime/view_coordinator.dart` - MultiView coordination
- `lib/src/state/surface_store.dart` - State management
- `lib/src/compiler/document_compiler.dart` - Document compilation
- `lib/src/runtime/surface_session.dart` - Session & action dispatch

