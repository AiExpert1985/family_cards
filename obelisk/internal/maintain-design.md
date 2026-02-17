---
description: Compact design log and regenerate summary
---
## Required Files

- `/obelisk/design/design-log.md`
- `/obelisk/design/design-summary.md`
- `/obelisk/contracts/contracts-log.md`

Missing → STOP

---

## Stage 1 — Process Unprocessed

1. Move all entries from `design-summary.md → ## Unprocessed` to `design-log.md` (append).
2. Clear `## Unprocessed`.

---

## Stage 2 — Regenerate Design Summary

### Inputs (Read-Only)

- `/obelisk/design/design-log.md` (authoritative design history)
- `/obelisk/contracts/contracts-log.md` (constraints context)

Authority:
- `design-log.md` defines declared design.
- `contracts-log.md` overrides on conflict.
- Code does NOT rewrite design.

---

## Consolidation Rules

**Supersession**
A decision is superseded if a later entry:
- Explicitly replaces it
- Clearly contradicts it in the same domain
- Removes the feature or module

Show current state only.  
If uncertain → keep both and flag in Open Design Questions.

---

**Merging**
Consolidate decisions about the same architectural element without altering meaning.

Do NOT merge:
- Orthogonal design decisions
- Different modules
- Conflicting approaches (flag instead)

---

**Contract Conflicts**
If design contradicts a contract:
- Trust contract
- Reflect contract in summary
- Note inconsistency in Open Design Questions

---

## Write Summary

Overwrite `/obelisk/design/design-summary.md`:

```markdown
# Design Summary

Generated: YYYY-MM-DD

## System Architecture
[Current architectural principles]

## Data Model
[Current schema decisions]

## Core Design Principles
[High-level decisions]

## Modules
[Active modules with responsibilities]

## Open Design Questions
[Unresolved decisions or detected conflicts]

## Unprocessed
```

## Constraints

- Do NOT invent, expand, or reinterpret design decisions.
- Do NOT infer design changes from code.
- Keep concise (<2000 tokens).
- `## Unprocessed` must exist (empty after regeneration).