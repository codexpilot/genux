# Data Flow & Component Model Diagrams

## Complete Data Flow: User Input to Server

```mermaid
flowchart TB
    subgraph "User Interaction"
        User[User types in TextField]
    end
    
    subgraph "Flutter Widget Layer"
        TextField[TextField Widget]
        OnChanged[onChanged callback]
    end
    
    subgraph "Component Scope"
        Scope[GenuxComponentScope]
        Write[write channel, value]
    end
    
    subgraph "Binding Layer"
        Binding[GenuxCompiledBinding<br/>name: 'value'<br/>pointer: /draft/name<br/>direction: state]
        TypeCheck[Type validation<br/>String expected]
        ConstraintCheck[Constraint validation<br/>maxLength: 16384]
    end
    
    subgraph "State Transaction"
        Transaction[GenuxStateTransaction]
        FreezeCopy[Freeze value copy]
        DraftState[Create mutable draft]
        Traverse[Traverse pointer path]
        SetValue[Set leaf value]
        Compare[Compare old vs new]
    end
    
    subgraph "State Store"
        Store[GenuxStateStore]
        VersionInc[version++]
        MarkDirty[Add to dirtyPaths]
        FreezeState[Freeze entire state]
        SwapState[Atomic swap state]
    end
    
    subgraph "Notification"
        Subscribers[Find subscribers]
        CheckIntersection[Check path intersection]
        NotifyWidgets[Notify matching NodeHosts]
        Rebuild[Widget setState → rebuild]
    end
    
    subgraph "Event Emission"
        CheckEvent{Event handler bound?}
        ResolveAction[Resolve action]
        ResolveArgs[Resolve args from state]
        CreateInvocation[Create GenuxActionInvocation]
        Dispatch[Call dispatcher]
    end
    
    subgraph "Application Handler"
        AppCode[Application Code]
        ValidateSession[Verify current session]
        BusinessLogic[Execute business logic]
        ServerCall[Call backend API]
    end
    
    User --> TextField
    TextField --> OnChanged
    OnChanged --> Scope
    Scope --> Write
    
    Write --> Binding
    Binding --> TypeCheck
    TypeCheck -->|Fail| RejectType[Return GenuxStateRejected]
    TypeCheck -->|Pass| ConstraintCheck
    ConstraintCheck -->|Fail| RejectConstraint[Return GenuxStateRejected]
    ConstraintCheck -->|Pass| Transaction
    
    Transaction --> FreezeCopy
    FreezeCopy --> DraftState
    DraftState --> Traverse
    Traverse --> SetValue
    SetValue --> Compare
    Compare -->|No change| ReturnNoop[Return GenuxStateNoop]
    Compare -->|Changed| Store
    
    Store --> VersionInc
    VersionInc --> MarkDirty
    MarkDirty --> FreezeState
    FreezeState --> SwapState
    SwapState --> Subscribers
    
    Subscribers --> CheckIntersection
    CheckIntersection --> NotifyWidgets
    NotifyWidgets --> Rebuild
    
    SwapState --> CheckEvent
    CheckEvent -->|No handler| Done[Done]
    CheckEvent -->|Handler exists| ResolveAction
    ResolveAction --> ResolveArgs
    ResolveArgs --> CreateInvocation
    CreateInvocation --> Dispatch
    
    Dispatch --> AppCode
    AppCode --> ValidateSession
    ValidateSession --> BusinessLogic
    BusinessLogic --> ServerCall
    
    style RejectType fill:#ffebee
    style RejectConstraint fill:#ffebee
    style ReturnNoop fill:#fff4e1
    style SwapState fill:#e8f5e9
    style Rebuild fill:#e1f5ff
    style ServerCall fill:#e8f5e9
```

## Catalog Component Definition Model

```mermaid
classDiagram
    class TextField {
        <<Component>>
        +code: "TextField"
        +version: 1
    }
    
    class TextFieldProperties {
        +label: string [maxLength: 256]
        +hint: string [maxLength: 512]
        +maxLines: integer [1..20]
    }
    
    class TextFieldChannels {
        +value: state string [required, maxLength: 16384]
        +enabled: input boolean
        +readOnly: input boolean
        +errorText: input nullable string [maxLength: 1024]
    }
    
    class TextFieldEvents {
        +changed: payload string
        +submitted: payload string
    }
    
    TextField --> TextFieldProperties : properties
    TextField --> TextFieldChannels : channels
    TextField --> TextFieldEvents : events
    
    note for TextFieldChannels "state channels are read-write\ninput channels are read-only"
    
    class FormComponent {
        <<Component>>
        +code: "Form"
        +version: 1
    }
    
    class FormChannels {
        +busy: input boolean
        +errors: input nullable object
    }
    
    class FormEvents {
        +submitted: no payload
        +cancelled: no payload
    }
    
    class FormSlots {
        +content: [1..100 children]
        +actions: [0..10 children]
    }
    
    FormComponent --> FormChannels : channels
    FormComponent --> FormEvents : events
    FormComponent --> FormSlots : slots
```

## Node Compilation Process

```mermaid
flowchart TD
    subgraph "Wire Format"
        WireNode[Wire Node JSON]
        WireComponent["component: 'TextField'"]
        WireProps["props: {label: 'Name', maxLines: 1}"]
        WireBindings["bind: {value: '/draft/name'}"]
        WireEvents["events: {submitted: 'saveCustomer'}"]
    end
    
    subgraph "Catalog Resolution"
        LookupComponent[catalog.component 'TextField']
        ComponentDef[GenuxComponentDefinition<br/>TextField v1]
        ChannelDefs[Channel definitions]
        EventDefs[Event definitions]
    end
    
    subgraph "Property Processing"
        SplitProps{Split props}
        CatalogProps[Properties in catalog<br/>→ properties map]
        LiteralInputs[Not in catalog<br/>→ literalInputs map]
        FreezeProps[Deep freeze all values]
    end
    
    subgraph "Binding Compilation"
        ParsePointer[Parse JSON Pointer<br/>'/draft/name']
        PointerSegments[segments: 'draft', 'name']
        CompiledBinding[GenuxCompiledBinding<br/>pointer, definition, fallback]
    end
    
    subgraph "Event Compilation"
        LookupAction[Lookup action by ID<br/>'saveCustomer']
        CompiledAction[GenuxCompiledAction<br/>capability, args]
        CompiledEvent[GenuxCompiledEvent<br/>name, definition, action]
    end
    
    subgraph "Result"
        CompiledNode[GenuxCompiledNode<br/>immutable, resolved handles]
    end
    
    WireNode --> WireComponent
    WireNode --> WireProps
    WireNode --> WireBindings
    WireNode --> WireEvents
    
    WireComponent --> LookupComponent
    LookupComponent --> ComponentDef
    ComponentDef --> ChannelDefs
    ComponentDef --> EventDefs
    
    WireProps --> SplitProps
    SplitProps --> CatalogProps
    SplitProps --> LiteralInputs
    CatalogProps --> FreezeProps
    LiteralInputs --> FreezeProps
    
    WireBindings --> ParsePointer
    ParsePointer --> PointerSegments
    PointerSegments --> CompiledBinding
    ChannelDefs --> CompiledBinding
    
    WireEvents --> LookupAction
    LookupAction --> CompiledAction
    CompiledAction --> CompiledEvent
    EventDefs --> CompiledEvent
    
    FreezeProps --> CompiledNode
    CompiledBinding --> CompiledNode
    CompiledEvent --> CompiledNode
    ComponentDef --> CompiledNode
    
    style CompiledNode fill:#e8f5e9
```

## Value Resolution: Literal vs Binding vs Expression

```mermaid
flowchart TD
    subgraph "Action Argument"
        ActionArg[Action argument<br/>in wire JSON]
    end
    
    ActionArg --> CheckType{Value type?}
    
    CheckType -->|Scalar/Array| CompileLiteral[GenuxLiteralValue]
    CheckType -->|Object with $bind| CompileBinding[GenuxStateValue<br/>pointer + fallback]
    CheckType -->|Plain Object| CompileObject[GenuxObjectValue<br/>recurse on fields]
    CheckType -->|Array| CompileArray[GenuxListValue<br/>recurse on items]
    
    subgraph "Resolution Time"
        Resolve[resolve state]
    end
    
    CompileLiteral --> Resolve
    CompileBinding --> Resolve
    CompileObject --> Resolve
    CompileArray --> Resolve
    
    Resolve --> LiteralReturn[Literal: return value directly]
    Resolve --> BindingRead[Binding: pointer.read state]
    Resolve --> ObjectRecurse[Object: resolve each field]
    Resolve --> ArrayRecurse[Array: resolve each item]
    
    BindingRead --> CheckExists{Path exists?}
    CheckExists -->|Yes| ReturnValue[Return value from state]
    CheckExists -->|No, has fallback| ReturnFallback[Return fallback value]
    CheckExists -->|No, no fallback| ThrowError[Throw StateError]
    
    style CompileLiteral fill:#e1f5ff
    style CompileBinding fill:#fff4e1
    style CompileObject fill:#fce4ec
    style ReturnValue fill:#e8f5e9
    style ThrowError fill:#ffebee
```

## Component Rendering Lifecycle

```mermaid
sequenceDiagram
    participant Framework as Flutter Framework
    participant Host as GenuxNodeHost
    participant Store as StateStore
    participant Scope as ComponentScope
    participant Catalog as FlutterCatalog
    participant Builder as Component Builder
    participant Widget as Material Widget
    
    Framework->>Host: initState()
    Host->>Store: subscribe(binding paths)
    Note over Host,Store: Subscribe only to paths<br/>this node binds to
    
    Framework->>Host: build(context)
    Host->>Catalog: builderFor(component)
    Catalog-->>Host: Component builder function
    
    Host->>Scope: Create ComponentScope
    Note over Scope: Scope provides:<br/>- property(name)<br/>- value(channel)<br/>- write(channel, value)<br/>- emit(event)<br/>- slot(name)
    
    Host->>Builder: builder(context, scope)
    
    Builder->>Scope: property('label')
    Scope-->>Builder: 'Customer name'
    
    Builder->>Scope: value('value')
    Scope->>Store: binding.read(state)
    Store-->>Scope: 'Mya'
    Scope-->>Builder: 'Mya'
    
    Builder->>Widget: Create Material TextField
    Widget-->>Builder: Widget tree
    Builder-->>Host: Widget tree
    Host-->>Framework: Widget tree
    
    Note over Framework,Widget: User types 'Maya'
    
    Widget->>Builder: onChanged('Maya')
    Builder->>Scope: write('value', 'Maya')
    Scope->>Store: transact(set pointer, value)
    Store->>Store: Validate, commit, notify
    Store-->>Host: State changed notification
    
    Host->>Framework: setState(() {})
    Framework->>Host: build(context)
    
    Note over Host,Widget: Rebuild with new value
```

## JSON Pointer Path Resolution

```mermaid
flowchart TD
    Start[State: {draft: {name: 'Mya', type: 2}}] --> Pointer[Pointer: /draft/name]
    
    Pointer --> Split[Split by /<br/>segments: 'draft', 'name']
    Split --> Current[current = root state]
    
    Current --> Segment1[Traverse: 'draft']
    Segment1 --> Check1{current is Map?}
    Check1 -->|No| Error1[Throw: not a collection]
    Check1 -->|Yes| Get1[current = current'draft']
    
    Get1 --> Exists1{Key exists?}
    Exists1 -->|No| NotFound[Return: exists=false]
    Exists1 -->|Yes| Segment2[Traverse: 'name']
    
    Segment2 --> Check2{current is Map?}
    Check2 -->|No| Error2[Throw: not a collection]
    Check2 -->|Yes| Get2[current = current'name']
    
    Get2 --> Exists2{Key exists?}
    Exists2 -->|No| NotFound
    Exists2 -->|Yes| Found[Return: exists=true<br/>value='Mya']
    
    style Found fill:#e8f5e9
    style NotFound fill:#fff4e1
    style Error1 fill:#ffebee
    style Error2 fill:#ffebee
```

## State Store Transaction Isolation

```mermaid
sequenceDiagram
    participant Thread1 as Transaction 1
    participant Thread2 as Transaction 2
    participant Store as StateStore
    participant Lock as Transaction Lock
    
    Thread1->>Store: transact(callback1)
    Store->>Lock: Acquire lock
    Lock-->>Store: Locked
    Store->>Store: _transactionOpen = true
    
    Thread2->>Store: transact(callback2)
    Store->>Lock: Check if open
    Lock-->>Store: Already locked
    Store-->>Thread2: GenuxStateRejected<br/>nestedTransaction
    
    Store->>Thread1: Execute callback1
    Thread1->>Store: transaction.set(path1, value1)
    Thread1->>Store: transaction.set(path2, value2)
    Thread1-->>Store: Callback complete
    
    Store->>Store: Apply all writes
    Store->>Store: Compare states
    Store->>Store: Commit if changed
    Store->>Store: version++
    Store->>Store: Mark dirty paths
    Store->>Store: Freeze new state
    Store->>Store: _transactionOpen = false
    Store->>Lock: Release lock
    
    Store->>Store: Notify subscribers
    Store-->>Thread1: GenuxStateCommitted
    
    Note over Store: Lock released,<br/>new transaction can start
```

## 10 Core Components Overview

```mermaid
graph TB
    subgraph "Layout Components"
        Column[Column<br/>vertical flex layout<br/>gap, alignment]
        Row[Row<br/>horizontal flex layout<br/>gap, alignment]
        Card[Card<br/>material container<br/>padding]
        Divider[Divider<br/>visual separator<br/>thickness, indent]
    end
    
    subgraph "Input Components"
        TextField[TextField<br/>text input<br/>state channel: value]
        Checkbox[Checkbox<br/>boolean input<br/>state channel: value]
        ComboBox[ComboBox<br/>choice selection<br/>state channel: value<br/>input: items]
        Button[Button<br/>action trigger<br/>event: pressed]
    end
    
    subgraph "Display Components"
        Text[Text<br/>read-only text<br/>input channel: text]
    end
    
    subgraph "Container Components"
        Form[Form<br/>validation container<br/>input: busy, errors<br/>events: submitted, cancelled<br/>slots: content, actions]
    end
    
    Form -.contains.-> Column
    Form -.contains.-> Row
    Form -.contains.-> Card
    Column -.contains.-> TextField
    Column -.contains.-> Checkbox
    Column -.contains.-> ComboBox
    Row -.contains.-> Button
    Card -.contains.-> Text
    
    style Form fill:#fff4e1
    style TextField fill:#e1f5ff
    style Text fill:#fce4ec
```

## Capability Registry & Dispatch

```mermaid
flowchart TD
    subgraph "Capability Definition"
        Registry[GenuxCapabilityRegistry]
        Def1[view.open<br/>args: viewCode string required]
        Def2[view.back<br/>no args]
        Def3[customer.save<br/>args: customer object required]
        Def4[demo.event<br/>args: control, event, value]
    end
    
    Registry --> Def1
    Registry --> Def2
    Registry --> Def3
    Registry --> Def4
    
    subgraph "Document Action"
        ActionDef["saveCustomer:<br/>{capability: 'customer.save',<br/>args: {customer: {$bind: '/draft'}}}"]
    end
    
    subgraph "Compilation"
        ValidateCap{Capability exists<br/>in registry?}
        ValidateArgs{All required args<br/>present?}
        CompileArgs[Compile arg values<br/>resolve $bind]
        CompiledAction2[GenuxCompiledAction<br/>immutable, validated]
    end
    
    subgraph "Dispatch Time"
        Event[User triggers event]
        ResolveArgs2[Resolve $bind from<br/>current state]
        ValidateTypes{Arg types match<br/>definitions?}
        CreateInvocation2[GenuxActionInvocation]
        CallDispatcher[dispatcher invocation]
    end
    
    subgraph "Handler"
        AppHandler[Application Handler]
        Switch{Switch on capability}
        ViewOpen[Handle view.open]
        ViewBack[Handle view.back]
        CustomerSave[Handle customer.save]
    end
    
    ActionDef --> ValidateCap
    Registry --> ValidateCap
    ValidateCap -->|No| RejectCap[Compile failure<br/>capability.notFound]
    ValidateCap -->|Yes| ValidateArgs
    ValidateArgs -->|No| RejectArgs[Compile failure<br/>action.missingArg]
    ValidateArgs -->|Yes| CompileArgs
    CompileArgs --> CompiledAction2
    
    Event --> CompiledAction2
    CompiledAction2 --> ResolveArgs2
    ResolveArgs2 --> ValidateTypes
    ValidateTypes -->|No| FailDispatch[GenuxActionDispatchFailed]
    ValidateTypes -->|Yes| CreateInvocation2
    CreateInvocation2 --> CallDispatcher
    
    CallDispatcher --> AppHandler
    AppHandler --> Switch
    Switch --> ViewOpen
    Switch --> ViewBack
    Switch --> CustomerSave
    
    style CompiledAction2 fill:#e8f5e9
    style CreateInvocation2 fill:#e1f5ff
    style RejectCap fill:#ffebee
    style FailDispatch fill:#ffebee
```

## Memory Model: Immutability

```mermaid
flowchart TD
    subgraph "Wire Document (Mutable)"
        JSON[JSON String<br/>from network]
        Decoded[Decoded Map<br/>mutable structure]
    end
    
    subgraph "Compilation (Freezing)"
        Draft[GenuxDocument Draft<br/>temporary mutable]
        Validate2[Validation pass]
        Compile2[Compile nodes, bindings]
        DeepFreeze[Deep freeze all values]
    end
    
    subgraph "Runtime (Immutable)"
        CompiledDoc[GenuxCompiledDocument<br/>IMMUTABLE]
        Nodes2[nodes: Map IMMUTABLE]
        Actions2[actions: Map IMMUTABLE]
        State2[state: Map IMMUTABLE]
    end
    
    subgraph "State Changes (Copy-on-Write)"
        Transaction2[Transaction starts]
        MutableDraft[Create mutable copy]
        Modify[Apply modifications]
        FreezeNew[Freeze new state]
        AtomicSwap[Atomic swap reference]
    end
    
    JSON --> Decoded
    Decoded --> Draft
    Draft --> Validate2
    Validate2 --> Compile2
    Compile2 --> DeepFreeze
    DeepFreeze --> CompiledDoc
    
    CompiledDoc --> Nodes2
    CompiledDoc --> Actions2
    CompiledDoc --> State2
    
    State2 --> Transaction2
    Transaction2 --> MutableDraft
    MutableDraft --> Modify
    Modify --> FreezeNew
    FreezeNew --> AtomicSwap
    AtomicSwap --> State2
    
    Note1[Document never changes<br/>after compilation] -.-> CompiledDoc
    Note2[State changes via<br/>copy-on-write] -.-> AtomicSwap
    
    style CompiledDoc fill:#e8f5e9
    style State2 fill:#e1f5ff
    style FreezeNew fill:#fff4e1
```

## Error Handling & Diagnostics

```mermaid
flowchart TD
    Start[User request] --> Load[Load source]
    
    Load -->|Network error| LoadError[GenuxViewOpenFailure<br/>stage: load<br/>error + stackTrace]
    Load -->|Success| Parse2[Parse JSON]
    
    Parse2 -->|Syntax error| ParseError[GenuxCompileFailure<br/>code: syntax.invalid]
    Parse2 -->|Success| Validate3[Validate]
    
    Validate3 --> CheckCatalog2{Catalog valid?}
    CheckCatalog2 -->|No| CatalogError[GenuxCompileFailure<br/>code: catalog.mismatch]
    CheckCatalog2 -->|Yes| CheckComponents{Components exist?}
    
    CheckComponents -->|No| ComponentError[GenuxCompileFailure<br/>code: component.notFound<br/>location: /nodes/3/component]
    CheckComponents -->|Yes| CheckBindings2{Bindings valid?}
    
    CheckBindings2 -->|No| BindingError[GenuxCompileFailure<br/>code: binding.pathInvalid<br/>location: /nodes/5/bind/value]
    CheckBindings2 -->|Yes| CheckGraph2{Graph valid?}
    
    CheckGraph2 -->|Cycle| GraphError[GenuxCompileFailure<br/>code: graph.cycle<br/>location: /nodes]
    CheckGraph2 -->|Valid| Success2[GenuxCompileSuccess]
    
    Success2 --> Render2[Render]
    Render2 -->|Widget error| RenderError[Call onRenderError<br/>Show error boundary]
    Render2 -->|Success| Display[Display to user]
    
    LoadError -.-> UserFeedback[Show diagnostics<br/>Keep last-known-good view]
    ParseError -.-> UserFeedback
    CatalogError -.-> UserFeedback
    ComponentError -.-> UserFeedback
    BindingError -.-> UserFeedback
    GraphError -.-> UserFeedback
    RenderError -.-> UserFeedback
    
    style Success2 fill:#e8f5e9
    style Display fill:#e8f5e9
    style LoadError fill:#ffebee
    style ParseError fill:#ffebee
    style ComponentError fill:#ffebee
```

