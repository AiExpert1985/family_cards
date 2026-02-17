---
description: Abort & document current task
---
## Required Files

- `/obelisk/workspace/active-task.md`
- `/obelisk/history/history-log.md`

If missing → STOP and report missing path.

---

## Input

Triggered when user expresses abort intent:
- `abort [reason]` → use provided reason
- `abort` → Reason defaults to "User requested"

---

## Determine Task Name

Extract from `active-task.md` header.

---

## Write History (Always)

Append to `/obelisk/history/history-log.md`:

```markdown
## YYYY-MM-DD | [Task Name] | ABORTED

---
```


---

## Archive Workspace

Destination:  
`/obelisk/archive/aborted/YYYYMMDD-[task-name]/`

Steps:

1. Create destination directory
2. Move ALL files from `/obelisk/workspace/` to destination
3. Verify `/obelisk/workspace/` is empty

---

## Output
```
🛑 TASK ABORTED

Archived: /obelisk/archive/aborted/YYYYMMDD-[task-name]/
Reason: [Abort reason]

Workspace cleared. Ready for next task.
```

STOP.