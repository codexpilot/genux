# MultiView Implementation Details

## Stack Navigation Flow

```mermaid
stateDiagram-v2
    [*] --> Empty: coordinator created
    
    Empty --> Entry1: open(customer.edit)
    Entry1: customer.edit session v0
    
    Entry1 --> Entry1_Dirty: user edits name
    Entry1_Dirty: customer.edit session v3<br/>dirty: [/draft/name]
    
    Entry1_Dirty --> Entry2: open(customer.summary)
    Entry2: Stack depth 2<br/>current: customer.summary v0<br/>preserved: customer.edit v3
    
    Entry2 --> Entry1_Restored: pop()
    Entry1_Restored: customer.edit session v3<br/>dirty paths still present<br/>edits preserved
    
    Entry1_Restored --> Entry1_Clean: save & acknowledge
    Entry1_Clean: customer.edit session v4<br/>dirty: []
    
    Entry1_Clean --> [*]: app exit
```

## Detailed Open Pipeline

```mermaid
flowchart TD
    Start[coordinator.open target] --> Token[Generate navigation token<br/>token = ++latestRequest]
    
    Token --> CheckCurrent{Already current?}
    CheckCurrent -->|viewCode + instanceKey match| CheckParams{Parameters equal?}
    CheckParams -->|No| RejectConflict[Return GenuxViewOpenFailure<br/>stage: request<br/>Different params for same identity]
    CheckParams -->|Yes| ReturnNoop[Return GenuxViewOpenNoop<br/>reason: alreadyCurrent]
    
    CheckCurrent -->|No| LoadSource[await sourceLoader target]
    LoadSource -->|Exception| LoadFailed{Token still valid?}
    LoadFailed -->|No| Superseded1[Return GenuxViewOpenNoop<br/>reason: superseded]
    LoadFailed -->|Yes| ReturnLoadFailure[Return GenuxViewOpenFailure<br/>stage: load<br/>Include error + stackTrace]
    
    LoadSource -->|Success| CheckToken1{Token == latest?}
    CheckToken1 -->|No| Superseded1
    CheckToken1 -->|Yes| CompileDoc[compiler.compileJson source]
    
    CompileDoc -->|Exception| ReturnCompileError[Return GenuxViewOpenFailure<br/>stage: compile<br/>Include error + stackTrace]
    CompileDoc -->|GenuxCompileFailure| ReturnDiagnostics[Return GenuxViewOpenFailure<br/>stage: compile<br/>Include diagnostics]
    CompileDoc -->|GenuxCompileSuccess| VerifyIdentity{view.code matches requested?}
    
    VerifyIdentity -->|No| ReturnIdentityFailure[Return GenuxViewOpenFailure<br/>stage: identity<br/>diagnostic: view.codeMismatch]
    VerifyIdentity -->|Yes| CheckKind{view.kind == 'view'?}
    
    CheckKind -->|No| ReturnKindFailure[Return GenuxViewOpenFailure<br/>stage: identity<br/>diagnostic: view.kindNotNavigable]
    CheckKind -->|Yes| CheckToken2{Token == latest?}
    
    CheckToken2 -->|No| Superseded2[Return GenuxViewOpenNoop<br/>reason: superseded]
    CheckToken2 -->|Yes| ActivateSession[Create GenuxSurfaceSession<br/>with compiled document]
    
    ActivateSession --> CreateEntry[Create GenuxViewStackEntry<br/>target + session]
    CreateEntry --> PushStack[stack.add entry]
    PushStack --> IncrementVersion[version++]
    IncrementVersion --> NotifyListeners[Publish GenuxViewStackChange<br/>kind: pushed]
    NotifyListeners --> ReturnSuccess[Return GenuxViewOpenSuccess<br/>with entry]
    
    style ReturnSuccess fill:#e8f5e9
    style ReturnNoop fill:#fff4e1
    style RejectConflict fill:#ffebee
    style ReturnLoadFailure fill:#ffebee
    style ReturnCompileError fill:#ffebee
    style ReturnDiagnostics fill:#ffebee
    style ReturnIdentityFailure fill:#ffebee
    style Superseded1 fill:#e1f5ff
    style Superseded2 fill:#e1f5ff
```

## Pop Operation Flow

```mermaid
flowchart TD
    Start[coordinator.pop] --> IncrementToken[latestRequest++<br/>Supersede any pending opens]
    
    IncrementToken --> CheckStack{Stack state?}
    
    CheckStack -->|Empty| ReturnEmpty[Return GenuxViewPopNoop<br/>reason: empty<br/>current: null]
    CheckStack -->|Single entry| ReturnRoot[Return GenuxViewPopNoop<br/>reason: atRoot<br/>current: root entry]
    CheckStack -->|2+ entries| RemoveCurrent[removed = stack.removeLast]
    
    RemoveCurrent --> GetRevealed[revealed = stack.last]
    GetRevealed --> IncrementVersion[version++]
    IncrementVersion --> NotifyListeners[Publish GenuxViewStackChange<br/>kind: popped]
    NotifyListeners --> ReturnPopped[Return GenuxViewPopped<br/>removed + revealed]
    
    style ReturnPopped fill:#e8f5e9
    style ReturnEmpty fill:#fff4e1
    style ReturnRoot fill:#fff4e1
```

## Race Condition Scenarios

```mermaid
sequenceDiagram
    participant User
    participant Coordinator
    participant LoaderA as Loader (viewA)
    participant LoaderB as Loader (viewB)
    participant Stack
    
    Note over Coordinator: Initial: empty stack
    
    User->>Coordinator: open(viewA)
    activate Coordinator
    Note over Coordinator: token = 1
    Coordinator->>LoaderA: Load viewA
    deactivate Coordinator
    
    User->>Coordinator: open(viewB)
    activate Coordinator
    Note over Coordinator: token = 2 (supersedes 1)
    Coordinator->>LoaderB: Load viewB
    deactivate Coordinator
    
    LoaderB-->>Coordinator: viewB JSON
    activate Coordinator
    Coordinator->>Coordinator: Check token == 2 ✓
    Coordinator->>Coordinator: Compile success
    Coordinator->>Coordinator: Check token == 2 ✓
    Coordinator->>Stack: Push viewB entry
    Coordinator->>User: GenuxViewOpenSuccess(viewB)
    deactivate Coordinator
    
    LoaderA-->>Coordinator: viewA JSON
    activate Coordinator
    Coordinator->>Coordinator: Check token == 2 (1 != 2) ✗
    Coordinator->>User: GenuxViewOpenNoop(superseded)
    deactivate Coordinator
    
    Note over Stack: Final: [viewB]<br/>viewA never committed
```

## State Subscription Model

```mermaid
graph TB
    subgraph "View Stack"
        Entry1[Entry 1: customer.edit<br/>Session + Store v5]
        Entry2[Entry 2: customer.summary<br/>Session + Store v1]
    end
    
    subgraph "NodeHost Subscriptions"
        Host1[TextField NodeHost<br/>subscribes to /draft/name]
        Host2[Button NodeHost<br/>subscribes to /ui/saving]
        Host3[Text NodeHost<br/>subscribes to /summary/name]
    end
    
    subgraph "State Changes"
        Change1[User types in TextField<br/>writes /draft/name]
        Change2[Save button pressed<br/>writes /ui/saving]
    end
    
    Entry1 --> Host1
    Entry1 --> Host2
    Entry2 --> Host3
    
    Change1 --> Entry1
    Entry1 -.notify.-> Host1
    Entry1 -.no notify.-> Host2
    
    Change2 --> Entry1
    Entry1 -.no notify.-> Host1
    Entry1 -.notify.-> Host2
    
    Note1[Only subscribed<br/>intersecting paths<br/>trigger rebuild] -.-> Host1
    
    style Change1 fill:#e1f5ff
    style Change2 fill:#e1f5ff
    style Host1 fill:#e8f5e9
    style Host2 fill:#fff4e1
```

## Identity Resolution

```mermaid
graph TD
    subgraph "Identity Components"
        ViewCode[viewCode<br/>stable: 'customer.edit']
        InstanceKey[instanceKey<br/>logical: 'customer:1001']
        Parameters[parameters<br/>immutable: {customerId: 1001}]
    end
    
    subgraph "Identity Rules"
        Rule1[Same viewCode + instanceKey<br/>+ same parameters<br/>→ No-op do not reload]
        Rule2[Same viewCode + instanceKey<br/>+ different parameters<br/>→ Reject as conflict]
        Rule3[Different viewCode OR instanceKey<br/>→ New independent session]
    end
    
    ViewCode --> Identity[View Target Identity<br/>viewCode, instanceKey]
    InstanceKey --> Identity
    Parameters -.provided to.-> Loader[Source Loader]
    
    Identity --> Rule1
    Identity --> Rule2
    Identity --> Rule3
    
    Rule1 --> Noop[GenuxViewOpenNoop<br/>alreadyCurrent]
    Rule2 --> Failure[GenuxViewOpenFailure<br/>request stage]
    Rule3 --> Success[GenuxViewOpenSuccess<br/>new stack entry]
    
    style Identity fill:#fff4e1
    style Rule1 fill:#e8f5e9
    style Rule2 fill:#ffebee
    style Rule3 fill:#e1f5ff
```

## Semantic Navigation Handling

```mermaid
sequenceDiagram
    participant Document as View Document
    participant Button as Button Component
    participant Session as Surface Session
    participant Dispatcher as Action Dispatcher
    participant AppCode as Application Code
    participant Coordinator as View Coordinator
    
    Note over Document: Action defined:<br/>{capability: 'view.open',<br/>args: {viewCode: 'customer.summary'}}
    
    Button->>Session: emit('pressed')
    Session->>Session: Resolve node.events['pressed']
    Session->>Session: Get action by ID
    Session->>Session: Resolve args from current state
    
    Session->>Dispatcher: dispatch(invocation)
    Note over Dispatcher: invocation contains:<br/>session, action, stateVersion
    
    Dispatcher->>AppCode: Handle capability
    
    AppCode->>AppCode: Check capability == 'view.open'
    AppCode->>AppCode: Verify invocation.session == currentSession
    Note over AppCode: Security: reject stale sessions
    
    AppCode->>AppCode: Extract viewCode argument
    AppCode->>AppCode: Check viewCode in allowlist
    Note over AppCode: Security: only allowlisted views
    
    AppCode->>Coordinator: open(target)
    Coordinator-->>AppCode: GenuxViewOpenSuccess
    
    AppCode-->>Dispatcher: Complete
    Dispatcher-->>Session: Complete
    
    Note over Document,Coordinator: Document never contains:<br/>- Flutter routes<br/>- URLs<br/>- File paths<br/>- SQL queries
```

## Dirty Path Tracking

```mermaid
flowchart TD
    Start[Initial State] --> UserEdit[User edits TextField<br/>/draft/name: 'Mya' → 'Maya']
    
    UserEdit --> Transaction[StateStore.transact<br/>origin: user]
    Transaction --> Apply[Apply change to state]
    Apply --> Compare{Value changed?}
    
    Compare -->|No| Noop[StateNoop]
    Compare -->|Yes| Commit[Commit new state]
    
    Commit --> MarkDirty[dirtyPaths.add '/draft/name']
    MarkDirty --> StateV1[State v1<br/>dirty: /draft/name]
    
    StateV1 --> UserEdit2[User edits another field<br/>/draft/marketingOptIn]
    UserEdit2 --> Transaction2[StateStore.transact<br/>origin: user]
    Transaction2 --> MarkDirty2[dirtyPaths.add '/draft/marketingOptIn']
    MarkDirty2 --> StateV2[State v2<br/>dirty: /draft/name, /draft/marketingOptIn]
    
    StateV2 --> Save[User saves customer]
    Save --> ServerSync[Server confirms save]
    ServerSync --> Acknowledge[store.acknowledge /draft]
    
    Acknowledge --> ClearDirty[Remove all paths<br/>intersecting /draft]
    ClearDirty --> StateV3[State v3<br/>dirty: empty]
    
    StateV3 --> RemoteUpdate{Remote update arrives}
    RemoteUpdate -->|Intersects dirty path| Reject[Reject with dirtyConflict]
    RemoteUpdate -->|No intersection| Accept[Accept remote changes]
    
    style StateV1 fill:#fff4e1
    style StateV2 fill:#fff4e1
    style StateV3 fill:#e8f5e9
    style Reject fill:#ffebee
    style Accept fill:#e8f5e9
```

## Session Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Created: GenuxSurfaceSession.activate
    
    Created --> Active: Added to view stack
    note right of Active
        Session contains:
        - GenuxCompiledDocument
        - GenuxStateStore
        - ActionDispatcher
    end note
    
    Active --> Dirty: User interactions<br/>modify state
    Dirty --> Dirty: More edits
    Dirty --> Syncing: Save action
    Syncing --> Clean: Acknowledge dirty paths
    Clean --> Dirty: More edits
    
    Active --> Covered: New view pushed<br/>on top
    note right of Covered
        Session preserved:
        - State version maintained
        - Dirty paths kept
        - Subscriptions alive
    end note
    
    Covered --> Active: Pop reveals<br/>this session
    note left of Active
        Exact same session restored:
        - No recompilation
        - No reload
        - State unchanged
    end note
    
    Active --> Removed: Pop from stack
    Removed --> [*]: Garbage collected
```

## Complete Example: Customer Workflow

```mermaid
sequenceDiagram
    participant User
    participant Shell as Native Shell
    participant Coord as ViewCoordinator
    participant EditSession as customer.edit Session
    participant EditStore as edit StateStore
    participant SummarySession as customer.summary Session
    participant SummaryStore as summary StateStore
    
    Shell->>Coord: open(customer.edit, customer:1001)
    Coord->>EditSession: Create + activate
    EditSession->>EditStore: Initialize state v0
    Note over EditStore: {draft: {name: 'Mya',...}}
    Coord-->>Shell: Success
    
    User->>EditSession: Edit name: 'Mya' → 'Maya'
    EditSession->>EditStore: transact(set /draft/name, 'Maya')
    EditStore->>EditStore: version: 0 → 1<br/>dirtyPaths: [/draft/name]
    EditStore-->>EditSession: StateCommitted
    
    User->>EditSession: Edit type: 2 → 1
    EditSession->>EditStore: transact(set /draft/customerType, 1)
    EditStore->>EditStore: version: 1 → 2<br/>dirtyPaths: [/draft/name, /draft/customerType]
    
    User->>EditSession: Click "Open summary"
    EditSession->>EditSession: emit('pressed', action: view.open)
    EditSession->>Shell: dispatch(view.open, {viewCode: 'customer.summary'})
    
    Shell->>Coord: open(customer.summary, customer.summary:showcase)
    Note over EditSession,EditStore: Edit session preserved<br/>v2, dirty paths kept
    
    Coord->>SummarySession: Create + activate
    SummarySession->>SummaryStore: Initialize state v0
    Note over SummaryStore: {summary: {name: 'Maya',...}}
    Coord-->>Shell: Success
    
    Note over Coord: Stack: [edit v2, summary v0]
    
    User->>SummarySession: Click "Back to editor"
    SummarySession->>SummarySession: emit('pressed', action: view.back)
    SummarySession->>Shell: dispatch(view.back)
    
    Shell->>Coord: pop()
    Coord->>Coord: Remove summary<br/>Reveal edit
    Note over Coord: Stack: [edit v2]
    
    Note over EditSession,EditStore: Exact same session restored<br/>v2, name still 'Maya'<br/>dirtyPaths still present
    
    User->>EditSession: Click "Save"
    EditSession->>Shell: dispatch(customer.save)
    Shell->>EditStore: transact(set /ui/saving, true)
    Shell->>Shell: await serverSave()
    Shell->>EditStore: acknowledge([/draft])
    Note over EditStore: dirtyPaths cleared
    Shell->>EditStore: transact(set /ui/saving, false)
    EditStore->>EditStore: version: 2 → 4<br/>dirtyPaths: []
```

## Performance Characteristics

```mermaid
graph TB
    subgraph "Compile Once"
        JSON[JSON Document<br/>~20KB]
        Parse[JSON.decode<br/>~5ms]
        Validate[Semantic validation<br/>~10ms]
        Compile[Resolve handles<br/>~5ms]
        Freeze[Deep freeze<br/>~3ms]
        Plan[Compiled Plan<br/>immutable]
    end
    
    subgraph "Render Many"
        Build1[Build 1<br/>0ms compile]
        Build2[Build 2<br/>0ms compile]
        Build3[Build 3<br/>0ms compile]
        BuildN[Build N<br/>0ms compile]
    end
    
    JSON --> Parse
    Parse --> Validate
    Validate --> Compile
    Compile --> Freeze
    Freeze --> Plan
    
    Plan -.reuse.-> Build1
    Plan -.reuse.-> Build2
    Plan -.reuse.-> Build3
    Plan -.reuse.-> BuildN
    
    Note1[Total compile: ~23ms<br/>Paid once per view open] -.-> Plan
    Note2[Widget build: direct handle access<br/>No string parsing or lookups] -.-> Build1
    
    style Plan fill:#e8f5e9
    style Build1 fill:#e1f5ff
    style Build2 fill:#e1f5ff
    style Build3 fill:#e1f5ff
```

