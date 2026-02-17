---
description: Compact log and regenerate contracts summary
---
## Required Files

- `/obelisk/contracts/contracts-log.md`
- `/obelisk/contracts/contracts-summary.md`
- `/obelisk/design/design-log.md`

Missing → STOP.

---

## Stage 1 — Process Unprocessed

1. Move all entries from `contracts-summary.md → ## Unprocessed` to `contracts-log.md` (append).
2. Clear `## Unprocessed` in summary.

---

## Stage 2 — Regenerate Summary

### Inputs (Read-Only)

- `/obelisk/contracts/contracts-log.md` (authoritative)
- `/obelisk/design/design-log.md` (evolution context)
- Codebase (enforcement context only)

Contracts-log defines declared intent.  
Design-log provides context.  
Code does NOT override contracts.

---

## Analysis Rules

### Supersession

A contract is superseded if a later log entry:
- Explicitly replaces it
- Introduces conflicting requirement in the same domain
- Removes the domain entirely

If uncertain → keep both and flag.

---

### Consolidation

Merge contracts expressing the same constraint without altering meaning.

Do NOT merge:
- Orthogonal constraints
- Different actors or contexts

If uncertain → do not merge.

---

### Enforcement Gaps

If a contract is declared but not enforced in code:
- Keep it active
- Mark as: "Active but unenforced"

Do NOT remove contracts due to missing enforcement.

---

## Write Summary

Overwrite `/obelisk/contracts/contracts-summary.md`:

```markdown
# Contracts Summary

Generated: YYYY-MM-DD

## System Identity
[Consolidated identity]

## Active Contracts
[Each active contract]
[Mark enforcement gaps if applicable]

## Non-Goals
[Consolidated non-goals]

## Unprocessed
```

---

## Constraints

- contracts-log.md is immutable and authoritative.
- Remove contracts only if explicitly superseded.
- Do NOT invent, expand, or narrow contracts.
- Keep summary concise (less than 1000 tokens).
- `## Unprocessed` must remain present and empty.