# Obelisk Framework

_A contract-driven, phase-separated collaboration protocol for stateless AI work on long-lived systems._

---

## Why Obelisk Exists

> **AI does not fail because it is weak — it fails because long-term use is unmanaged.**

As projects grow:

- Conversations accumulate stale assumptions
- Sessions reset and models switch
- Critical knowledge is lost
- AI-generated changes silently break working systems
- What changed — and why — becomes unclear

Over time, AI-assisted development becomes unpredictable and difficult to trust.

Obelisk externalizes truth, design, intent, and history into explicit files so correctness does not depend on chat memory.

---

## What Obelisk Is

Obelisk is a structured collaboration framework that makes AI-assisted development:

- **Safe**
- **Repeatable**
- **Recoverable**

**Core mechanism:**  
External files replace chat as the source of truth.

**Key properties:**
- Model-independent (switch AI providers freely)
- Stateless (resume after months)
- Validation-enforced (prevents silent corruption)

It does not prevent failure. It prevents **silent damage**.

---

## How It Works

Obelisk separates five layers:

> **Contracts** define invariants  
> **Design** defines architecture  
> **Tasks** freeze intent  
> **Plans** constrain execution  
> **History** records events  

Higher layers constrain lower layers.  
Lower layers may not redefine higher ones.

---

## Designed For

Long-lived systems where:

- Correctness matters more than raw velocity
- Breaking changes damage trust or operations
- AI is used continuously in production

It intentionally trades early friction for long-term stability.

**Not Designed For:**

- Throwaway prototypes
- Maximum-speed experimentation
- Replacing manual testing
- Guaranteeing zero bugs

---

## Design Philosophy

### Core Failure Modes

**Context Window Trap**
- Knowledge trapped in chat
- Context exhaustion forces resets
- Decisions lost; only code remains

**Rushed Execution**
- Implementation before understanding
- Alternatives unexplored
- Architectural impact ignored

**Silent Corruption**
- Gradual drift from original intent
- Small changes accumulate unnoticed
- System runs, clarity erodes

### Why Obelisk Works

- Stateless collaboration via files
- Mandatory discovery before execution
- Validation against frozen intent
- Architecture preserved independently of tasks

---

## Commands

| Command | Purpose |
|----------|----------|
| `/init-project` | Initialize project structure |
| `/define-task [description]` | Define and freeze a task |
| `/run-task` | Plan, implement, review, archive |
| `/ask` | Query project knowledge |
| `/help` | Show available commands |

---

## Quick Start

**For projects using Obelisk in AI coding tools (Windsurf, Cursor, etc.):**

1. Initialize project:
```
/init-project
```

2. Define a task:
```
/define-task Add user authentication
```

3. Execute:
```
/run-task
```

4. Ask questions anytime:
```
/ask What contracts exist?
```

---

## Core Workflow

### Project Initialization (Once)

Discovery defines:

- System identity
- Core invariants
- Long-lived architectural intent

Outcome: durable foundation independent of chat sessions.

---

### Task Cycle (Repeats)
```
task → plan → implement → review → archive
```

Execution resumes from current phase if interrupted.

---

### Hotfix (Shortcut)

Used only when:

- Change is small and obvious
- No invariants are affected
- Fully reversible
- Diff explains itself

Hotfixes bypass planning but are always recorded in history.

---

### Task Execution

#### `/define-task`
Freeze intent before execution.  
Prevents guessing, scope drift, and accidental architecture.

#### `/run-task`
Plan → implement → review → archive.

- Planning constrains execution.
- Review validates against contracts and intent.
- Archive preserves traceability.

The system evolves with explicit authority and no silent drift.

---

## System Structure
```
/obelisk/
├── contracts/
│   ├── contracts-log.md        # Canonical invariants (append-only)
│   └── contracts-summary.md    # Active contract projection
├── design/
│   ├── design-log.md           # Canonical architectural decisions
│   └── design-summary.md       # Active architectural projection
├── history/
│   └── history-log.md          # Chronological task timeline
├── workspace/                  # Active task state
├── archive/
│   ├── completed/
│   ├── rejected/
│   └── aborted/
├── guidelines/
│   └── ai-engineering.md       # Execution constraints
└── internal/
```

---

## Authority & Knowledge Model

**Authority Hierarchy (Highest → Lowest):**
1. Contracts Log
2. Design Log  
3. Active Task
4. AI Engineering Rules
5. History Log
6. Derived Summaries
7. Chat History

**Canonical (Authoritative):**
- Contracts Log — append-only invariants
- Design Log — append-only architectural decisions
- History Log — chronological task record

**Derived (Disposable):**
- Contracts Summary — active projection (regenerated)
- Design Summary — active projection (regenerated)

Summaries never override logs.

---

Obelisk is a collaboration protocol.  
This repository is its reference implementation.