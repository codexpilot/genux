# Genux Architecture Diagrams

## System Overview

```mermaid
graph TB
    subgraph "CloudX (Authoring)"
        Author[CloudX Authoring UI]
        Preview[Preview Tool]
        Publish[Publish Request]
    end
    
    subgraph "Aix Backend (Server)"
        Tables[(Relational GenUX Tables)]
        Compiler[Server-side Compiler]
        Validator[Validator & Policy]
        Artifact[(Immutable View Artifacts)]
        QueryHub[QueryHub Delivery]
    end
    
    subgraph "Genux Flutter Client"
        Loader[Source Loader]
        ClientCompiler[Client Compiler]
        Validator2[Document Validator]
        Coordinator[View Coordinator]
        Session[Surface Session]
        Store[State Store]
        Renderer[Flutter Renderers]
    end
    
    Author --> Tables
    Preview --> Tables
    Publish --> Compiler
    Tables --> Compiler
    Compiler --> Validator
    Validator --> Artifact
    Artifact --> QueryHub
    QueryHub --> Loader
    Loader --> ClientCompiler
    ClientCompiler --> Validator2
    Validator2 --> Coordinator
    Coordinator --> Session
    Session --> Store
    Session --> Renderer
    
    style Author fill:#e1f5ff
    style Compiler fill:#fff4e1
    style ClientCompiler fill:#e8f5e9
    style Renderer fill:#e8f5e9
```

## Wire Protocol: aix.genux/1.0

```mermaid
graph LR
    subgraph "Document Structure"
        Doc[aix.genux/1.0 Document]
        View[View Identity]
        Catalog[Catalog Reference]
        Root[Root Node ID]
        State[Initial State JSON]
        Actions[Action Definitions]
        Nodes[Node Graph]
    end
    
    Doc --> View
    Doc --> Catalog
    Doc --> Root
    Doc --> State
    Doc --> Actions
    Doc --> Nodes
    
    View --> |view.code|VC[customer.edit]
    View --> |view.revision|VR[6]
    View --> |view.kind|VK[view]
    
    Catalog --> |catalog.id|CI[aix.core]
    Catalog --> |catalog.version|CV[1]
    Catalog --> |catalog.checksum|CS[sha256:...]
    
    State --> |JSON paths|SP[/draft/name<br/>/ui/saving<br/>/lookups/types]
    
    Nodes --> |Component instances|N1[Form]
    Nodes --> N2[TextField]
    Nodes --> N3[Button]
    
    style Doc fill:#fff4e1
    style View fill:#e1f5ff
    style Catalog fill:#fce4ec
    style State fill:#e8f5e9
```

## Component Catalog Model

```mermaid
classDiagram
    class GenuxCatalog {
        +String id
        +int version
        +String checksum
        +Map components
    }
    
    class GenuxComponent {
        +String code
        +int version
        +Map properties
        +Map channels
        +Map events
        +Map slots
    }
    
    class GenuxProperty {
        +GenuxValueType type
        +bool required
        +GenuxConstraint constraint
    }
    
    class GenuxChannel {
        +GenuxValueType type
        +GenuxChannelDirection direction
        +bool required
        +GenuxConstraint constraint
    }
    
    class GenuxEvent {
        +String name
        +GenuxValueType payload
    }
    
    class GenuxSlot {
        +String name
        +int minChildren
        +int maxChildren
    }
    
    GenuxCatalog "1" --> "*" GenuxComponent
    GenuxComponent "1" --> "*" GenuxProperty
    GenuxComponent "1" --> "*" GenuxChannel
    GenuxComponent "1" --> "*" GenuxEvent
    GenuxComponent "1" --> "*" GenuxSlot
    
    note for GenuxChannel "direction: input (read-only)\n or state (read-write)"
```

## Compilation Pipeline

```mermaid
flowchart TD
    Start[JSON Document String] --> ByteCheck{Byte limit OK?}
    ByteCheck -->|No| Reject1[Reject: limit.documentBytes]
    ByteCheck -->|Yes| Parse[JSON.decode]
    
    Parse -->|Exception| Reject2[Reject: syntax.invalid]
    Parse -->|Success| Draft[GenuxDocument Draft]
    
    Draft --> Validate[Semantic Validation]
    Validate --> CheckCatalog{Catalog exists?}
    CheckCatalog -->|No| Reject3[Reject: catalog.notFound]
    CheckCatalog -->|Yes| CheckNodes{All components valid?}
    
    CheckNodes -->|No| Reject4[Reject: component.notFound]
    CheckNodes -->|Yes| CheckBindings{Bindings valid?}
    
    CheckBindings -->|No| Reject5[Reject: binding.invalid]
    CheckBindings -->|Yes| CheckActions{Actions valid?}
    
    CheckActions -->|No| Reject6[Reject: action.invalid]
    CheckActions -->|Yes| CheckGraph{Graph valid?}
    
    CheckGraph -->|No| Reject7[Reject: graph.cycle]
    CheckGraph -->|Yes| Compile[Compile to Immutable Plan]
    
    Compile --> Resolve[Resolve Handles]
    Resolve --> Freeze[Deep Freeze]
    Freeze --> Success[GenuxCompileSuccess]
    
    Reject1 --> Failure[GenuxCompileFailure]
    Reject2 --> Failure
    Reject3 --> Failure
    Reject4 --> Failure
    Reject5 --> Failure
    Reject6 --> Failure
    Reject7 --> Failure
    
    style Success fill:#e8f5e9
    style Failure fill:#ffebee
    style Compile fill:#e1f5ff
```

## MultiView Stack Model

```mermaid
graph TB
    subgraph "GenuxViewCoordinator"
        Stack[View Stack]
        Compiler2[Document Compiler]
        Loader2[Source Loader]
        Dispatcher[Action Dispatcher]
        Version[Stack Version Counter]
    end
    
    subgraph "Stack Entry 1: customer.edit"
        Target1[ViewTarget<br/>viewCode: customer.edit<br/>instanceKey: customer:1001]
        Session1[GenuxSurfaceSession]
        Store1[StateStore v5<br/>dirty: /draft/name]
        Doc1[GenuxCompiledDocument]
    end
    
    subgraph "Stack Entry 2: customer.summary"
        Target2[ViewTarget<br/>viewCode: customer.summary<br/>instanceKey: customer.summary:showcase]
        Session2[GenuxSurfaceSession]
        Store2[StateStore v1<br/>dirty: none]
        Doc2[GenuxCompiledDocument]
    end
    
    Stack --> Target1
    Stack --> Target2
    Target1 --> Session1
    Target2 --> Session2
    Session1 --> Store1
    Session1 --> Doc1
    Session2 --> Store2
    Session2 --> Doc2
    
    Compiler2 -.-> Doc1
    Compiler2 -.-> Doc2
    Loader2 -.-> Doc1
    Loader2 -.-> Doc2
    Dispatcher -.-> Session1
    Dispatcher -.-> Session2
    
    style Stack fill:#fff4e1
    style Session1 fill:#e8f5e9
    style Session2 fill:#e8f5e9
    style Store1 fill:#e1f5ff
    style Store2 fill:#e1f5ff
```

## Open Pipeline with Race Protection

```mermaid
sequenceDiagram
    participant User
    participant Coordinator
    participant Loader
    participant Compiler
    participant Stack
    participant Listeners
    
    User->>Coordinator: open(targetA)
    Coordinator->>Coordinator: token = 1
    Coordinator->>Coordinator: Check if already current
    
    User->>Coordinator: open(targetB)
    Note over Coordinator: token = 2 (supersedes 1)
    
    Coordinator->>Loader: Load targetB source
    Loader-->>Coordinator: JSON string
    
    Coordinator->>Coordinator: Check token == 2 ✓
    Coordinator->>Compiler: compileJson(source)
    Compiler-->>Coordinator: GenuxCompileSuccess
    
    Coordinator->>Coordinator: Verify view.code matches
    Coordinator->>Coordinator: Check token == 2 ✓
    
    Coordinator->>Stack: Push new entry
    Coordinator->>Coordinator: version++
    Coordinator->>Listeners: Notify(GenuxViewStackChange)
    
    Loader->>Coordinator: TargetA source ready
    Coordinator->>Coordinator: Check token == 2 (1 != 2) ✗
    Coordinator-->>User: GenuxViewOpenNoop(superseded)
    
    Note over Coordinator,User: TargetA load succeeded but<br/>was rejected due to newer request
```

## State Transaction Flow

```mermaid
flowchart TD
    Event[User Event: TextField.changed] --> Scope[ComponentScope]
    Scope --> Write{write channel}
    
    Write --> CheckWritable{Channel writable?}
    CheckWritable -->|No| RejectBind[Reject: invalidWrite]
    CheckWritable -->|Yes| CheckType{Type valid?}
    
    CheckType -->|No| RejectType[Reject: invalidWrite]
    CheckType -->|Yes| CheckConstraint{Constraint valid?}
    
    CheckConstraint -->|No| RejectConstraint[Reject: invalidWrite]
    CheckConstraint -->|Yes| Transaction[StateStore.transact]
    
    Transaction --> Freeze[Freeze value]
    Freeze --> Apply[Apply to draft state]
    Apply --> Compare{State changed?}
    
    Compare -->|No| Noop[StateNoop]
    Compare -->|Yes| Commit[Commit new state]
    
    Commit --> VersionInc[version++]
    VersionInc --> MarkDirty[Mark path dirty]
    MarkDirty --> Notify[Notify subscribers]
    Notify --> Rebuild[Widget rebuild]
    Rebuild --> Action{Event handler?}
    
    Action -->|Yes| Dispatch[Dispatch action]
    Action -->|No| Done[Done]
    
    style Commit fill:#e8f5e9
    style RejectBind fill:#ffebee
    style RejectType fill:#ffebee
    style RejectConstraint fill:#ffebee
```

## Action Dispatch Flow

```mermaid
sequenceDiagram
    participant Widget as Flutter Widget
    participant Scope as ComponentScope
    participant Session as SurfaceSession
    participant Store as StateStore
    participant Dispatcher as ActionDispatcher
    participant App as Application Code
    
    Widget->>Scope: emit('pressed')
    Scope->>Session: emit(nodeId, event)
    
    Session->>Session: Resolve node.events['pressed']
    Session->>Session: Validate payload type
    Session->>Store: Get current state
    Store-->>Session: state snapshot
    
    Session->>Session: Resolve action args from state
    Session->>Session: Validate capability args
    
    Session->>Session: Create GenuxActionInvocation
    Note over Session: Contains: session, action,<br/>sourceNodeId, arguments,<br/>stateVersion
    
    Session->>Dispatcher: dispatcher(invocation)
    Dispatcher->>App: Handle semantic action
    
    alt view.open capability
        App->>App: Verify session is current
        App->>App: Validate viewCode allowlisted
        App->>Coordinator: coordinator.open(target)
        Coordinator-->>App: GenuxViewOpenSuccess
    else view.back capability
        App->>App: Verify session is current
        App->>Coordinator: coordinator.pop()
        Coordinator-->>App: GenuxViewPopped
    else customer.save capability
        App->>Store: Set /ui/saving = true
        App->>App: Simulate network call
        App->>Store: Acknowledge dirty paths
        App->>Store: Set /ui/saving = false
    end
    
    Dispatcher-->>Session: Complete
    Session-->>Scope: GenuxActionDispatched
```

## Binding Resolution

```mermaid
graph TB
    subgraph "Document Structure"
        Node[Node: TextField]
        Binding["bind: {value: '/draft/name'}"]
        State["state: {draft: {name: 'Mya'}}"]
    end
    
    subgraph "Compilation"
        Compile[Compile Time]
        Pointer[GenuxJsonPointer<br/>segments: ['draft', 'name']]
        CompiledBinding[GenuxCompiledBinding<br/>pointer: /draft/name<br/>definition: TextField.value]
    end
    
    subgraph "Runtime"
        Build[Widget Build]
        Read[Read binding]
        Traverse[Traverse state path]
        Value[value = 'Mya']
        Render[Render TextField]
    end
    
    Node --> Binding
    Binding --> Compile
    State --> Compile
    Compile --> Pointer
    Pointer --> CompiledBinding
    
    CompiledBinding --> Build
    State --> Build
    Build --> Read
    Read --> Traverse
    Traverse --> Value
    Value --> Render
    
    style Compile fill:#fff4e1
    style Build fill:#e8f5e9
    style Value fill:#e1f5ff
```

## Component Rendering Architecture

```mermaid
graph TB
    subgraph "Flutter Layer"
        SurfaceHost[GenuxSurfaceHost]
        NodeHost[GenuxNodeHost<br/>per component]
        MaterialCatalog[GenuxMaterialCatalog<br/>Flutter builders]
        Widget[Material Widgets]
    end
    
    subgraph "Runtime Layer"
        Session2[GenuxSurfaceSession]
        Document[GenuxCompiledDocument]
        Node[GenuxCompiledNode]
        Store3[GenuxStateStore]
    end
    
    subgraph "Component Scope"
        Scope2[GenuxComponentScope]
        ReadProperty[property]
        ReadValue[value]
        WriteChannel[write]
        EmitEvent[emit]
        RenderSlot[slot]
    end
    
    SurfaceHost --> Session2
    SurfaceHost --> MaterialCatalog
    SurfaceHost --> NodeHost
    
    NodeHost --> Document
    NodeHost --> Node
    NodeHost --> Scope2
    NodeHost --> Store3
    
    Scope2 --> ReadProperty
    Scope2 --> ReadValue
    Scope2 --> WriteChannel
    Scope2 --> EmitEvent
    Scope2 --> RenderSlot
    
    MaterialCatalog --> Widget
    Scope2 --> Widget
    
    Store3 -.subscription.-> NodeHost
    
    style MaterialCatalog fill:#e1f5ff
    style Scope2 fill:#e8f5e9
    style Widget fill:#fce4ec
```

## Security Boundaries

```mermaid
graph TB
    subgraph "Untrusted Zone"
        JSON[JSON Document<br/>from network]
        UserInput[User Input]
    end
    
    subgraph "Validation Boundary"
        ByteLimit[Byte Limit Check]
        Syntax[JSON Syntax]
        Schema[Schema Validation]
        Catalog2[Catalog Verification]
        Graph[Graph Validation]
        Policy[Policy Enforcement]
    end
    
    subgraph "Trusted Zone"
        Compiled[GenuxCompiledDocument<br/>immutable, resolved]
        Registry[Capability Registry<br/>allowlist]
        Renderer2[Flutter Renderers<br/>trusted implementations]
        AppCode[Application Code<br/>navigation handler]
    end
    
    JSON --> ByteLimit
    JSON --> Syntax
    Syntax --> Schema
    Schema --> Catalog2
    Catalog2 --> Graph
    Graph --> Policy
    Policy --> Compiled
    
    UserInput --> Compiled
    Compiled --> Registry
    Registry --> AppCode
    AppCode --> Renderer2
    
    style JSON fill:#ffebee
    style Policy fill:#fff4e1
    style Compiled fill:#e8f5e9
    style Renderer2 fill:#e8f5e9
    
    note1[No reflection<br/>No eval<br/>No dynamic code] -.-> Compiled
    note2[Semantic actions only<br/>No URLs, routes, SQL] -.-> Registry
```

## Project Structure

```mermaid
graph TB
    subgraph "Public API"
        GenuxDart[genux.dart]
        GenuxFlutter[genux_flutter.dart]
    end
    
    subgraph "Core (Pure Dart)"
        Catalog3[catalog/]
        Model[model/]
        Compiler3[compiler/]
        Validation[validation/]
        State2[state/]
        Runtime[runtime/]
    end
    
    subgraph "Flutter Integration"
        FlutterCat[flutter/]
        MaterialImpl[Material renderers]
    end
    
    subgraph "Showcase App"
        Main[main.dart]
        Pages[pages/]
        ShowcaseRuntime[showcase_runtime.dart]
    end
    
    GenuxDart --> Catalog3
    GenuxDart --> Model
    GenuxDart --> Compiler3
    GenuxDart --> Validation
    GenuxDart --> State2
    GenuxDart --> Runtime
    
    GenuxFlutter --> GenuxDart
    GenuxFlutter --> FlutterCat
    FlutterCat --> MaterialImpl
    
    Main --> ShowcaseRuntime
    ShowcaseRuntime --> GenuxFlutter
    Pages --> GenuxFlutter
    
    style GenuxDart fill:#e1f5ff
    style GenuxFlutter fill:#e8f5e9
    style ShowcaseRuntime fill:#fff4e1
```

