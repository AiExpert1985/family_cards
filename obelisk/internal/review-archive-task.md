---
description: Review completed task, validate correctness, and archive results
---

## Required Files

- `/obelisk/workspace/active-task.md`
- `/obelisk/workspace/implementation-notes.md`
- `/obelisk/contracts/contracts-summary.md`
- `/obelisk/design/design-summary.md`

If any missing → STOP.

---

# Authority

- Contracts define invariants.
- Frozen Task defines scope and intent.
- Plan is informational only.

Review validates implementation against:
- Frozen Task
- Success Criteria
- Contracts
- Scope boundaries

---

# Review Phase

## Required Validation

You MUST:

1. Inspect actual source code (not summaries).
2. Confirm Task Goal is fully achieved.
3. Confirm Success Criteria are satisfied.
4. Confirm no contract is violated or weakened.
5. Confirm scope was not expanded.
6. Confirm implementation does not reinterpret or alter task intent.
7. Confirm no unrelated or speculative changes were introduced.

If any fail → Status = REJECTED.

---

## Anti-Hallucination Rule (Mandatory)

For every ✓ involving code validation, provide evidence:

- File path + function/class  
OR  
- Short code snippet  
OR  
- Precise observed logic  

If evidence cannot be shown → mark ✗.

---

# Review Output

Write to `/obelisk/workspace/review-notes.md`:

```markdown
# Review Outcome

**Status:** APPROVED | REJECTED

## Summary
[2–3 factual sentences]

## Validation Results
1. Goal Achieved: ✓ | ✗
2. Success Criteria Met: ✓ | ✗
3. Contracts Preserved: ✓ | ✗
4. Scope Preserved: ✓ | ✗
5. Intent Preserved: ✓ | ✗
6. No Hallucinated Changes: ✓ | ✗

## Files Verified
- [actual source files reviewed]

## Notes
- Factual observations only
```

# Status Gate

## If REJECTED

1. Append to `/obelisk/history/history-log.md`:

``` markdown
## YYYY-MM-DD | [Task Name] | REJECTED

---

```

2. Archive workspace to  
   `/obelisk/archive/rejected/YYYYMMDD-[task-name]/`
   
3. Clear `/obelisk/workspace/`

**Output:**

``` markdown
⚠️ TASK CLOSED — REJECTED
Archived: /obelisk/archive/rejected/YYYYMMDD-[task-name]/

```

STOP.

---

## If APPROVED

### 1 — Write History

Append to `/obelisk/history/history-log.md`:

``` markdown
## YYYY-MM-DD | [Task Name] | APPROVED

---

```

---

### 2 — Apply Contract Changes (If Present)

If `/obelisk/workspace/contract-changes.md` exists:

Append its content exactly as written to  
`/obelisk/contracts/contracts-summary.md → ## Unprocessed`

**Format:**

``` markdown
## YYYY-MM-DD | [Task Name]

[Contract change content]

---
```

**Rules:**
- Do NOT modify wording
- Do NOT reinterpret
- Preserve exact contract text

---

### 3 — Promote Design Decisions (If Applicable)

If `/obelisk/workspace/discovery-decisions.md` exists:

Append its content (excluding Summary and Deferred) to:

`/obelisk/design/design-summary.md` → `## Unprocessed`

**Format:**

``` markdown
## YYYY-MM-DD | [Task Name]

[Architecture / Design and Business Logic sections exactly as written]

---
```

---

### 4 — Archive Workspace

Archive all files to:
`/obelisk/archive/completed/YYYYMMDD-[task-name]/`

Clear `/obelisk/workspace/`

---

## Maintenance Auto-Trigger

If `/obelisk/contracts/contracts-summary.md` exceeds 2000 tokens:
→ Run `/obelisk/internal/maintain-contracts`

If `/obelisk/design/design-log.md` exceeds 4000 tokens:
→ Run `/obelisk/internal/maintain-design`

---

# Output

```
✅ TASK CLOSED — APPROVED
Archived: /obelisk/archive/completed/YYYYMMDD-[task-name]/
```


STOP.