---
description: Plan and implement the active task in one workflow
---
## Required Files

- `/obelisk/workspace/active-task.md`
- `/obelisk/contracts/contracts-summary.md`
- `/obelisk/design/design-summary.md`
- `/obelisk/guidelines/ai-engineering.md`

Optional:
- `/obelisk/workspace/contract-changes.md`

If any required file is missing → STOP.

---

## Authority (Highest → Lowest)

1. **Contracts** — invariants (cannot be violated)
2. **Frozen Task** — scope and intent (cannot expand)
3. **Design** — system structure (should be respected)
4. **Plan** — execution blueprint (non-authoritative)

If conflict is detected → STOP and return to discovery.

If `contract-changes.md` exists, approved changes apply to this task only.

---

# Step 1 — Task Analysis (Required)

Read:
- `design-summary.md`
- Relevant code
- `active-task.md`

You MUST:
- Understand current structure and dependencies
- Identify affected modules
- Confirm feasibility
- Identify risks and edge cases

You MUST NOT:
- Expand scope
- Introduce new requirements
- Modify contracts
- Override design without explicit task intent

If task is contradictory or infeasible → STOP.

---

# Step 2 — Create Initial Plan (Before Code Changes)

Create `/obelisk/workspace/implementation-notes.md`:

```markdown
## active-plan: [Task Name]

### Goal
[From active-task.md]

### Initial Plan

**Approach:**
[3–5 sentence strategy]

**Affected Modules:**
[List modules]

**Files to modify:**
- `/path/file.ext` — [change]

**Files to create:**
- `/path/new-file.ext` — [purpose]

**Key Steps:**
1. [Step]
2. [Step]
3. [Step]

**Constraints:**
- Preserve contracts
- Respect design
- Do not expand scope

---

## Plan Revisions

---

## Execution Summary

```

`## Initial Plan` MUST NOT be modified after creation.

All sections required. Use “None” if applicable.

---

# Step 3 — Implementation

Execute the plan.

Adaptation allowed ONLY if ALL true:

1. Task goal unchanged
2. No contract violated (unless approved in `contract-changes.md`)
3. Scope preserved
4. No new features introduced
If adapting, append under `## Plan Revisions`:

``` markdown
**Revision [N]:**
- **Original plan:** [what initial plan said]
- **Actual approach:** [what you did instead]
- **Reason:** [why revision was necessary]

```

Do NOT modify `## Initial Plan`.

---

# STOP Conditions

STOP immediately if:

- Goal requires reinterpretation
- Scope must expand
- A contract would be violated
- A major architectural decision is required
- Task is infeasible
- Continuing risks irreversible damage

If uncertain about scope, contracts, or design → STOP.

---

# Completion

Append under `## Execution Summary`:

``` markdown
**Final approach:** [Brief description]

**Deferred items:** [If any]

```

---

OUTPUT:

> ✓ EXECUTION COMPLETE — implementation-notes.md created