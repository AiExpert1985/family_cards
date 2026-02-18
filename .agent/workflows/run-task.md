---
description: Auto-execute task until the end
---

## Required Files

- `/obelisk/workspace/active-task.md` **MUST exist**

If missing → **STOP**

```
No active task.
Use /define-task to create one.
```

---

## Phase Detection

Determine state from workspace files:

| Files Present             | State       | Next                                |
| ------------------------- | ----------- | ----------------------------------- |
| `active-task.md`          | DEFINED     | Plan & Implement → Review & Archive |
| `implementation-notes.md` | IMPLEMENTED | Review & Archive                    |

---

## Execution

Run all remaining phases in order until completion or STOP.

## Phase Workflows

| Phase            | Workflow                                    |
| ---------------- | ------------------------------------------- |
| Plan & Implement | `/obelisk/internal/plan-implement-task.md` |
| Review & Archive | `/obelisk/internal/review-archive-task.md` |


**Rules:**
- Read workflow and execute as instructions
- Missing required files → **STOP**, report paths
- Workflow STOP → halt immediately