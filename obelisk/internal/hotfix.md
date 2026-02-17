---
description: Run small mechanical fix without full task flow
---
## Required Files

- `/obelisk/guidelines/ai-engineering.md`
- `/obelisk/contracts/contracts-summary.md`
- `/obelisk/history/history-log.md`

If any are missing → **STOP** and report


---

## Execution

Perform exactly the mechanical change described.

Before applying:
- Identify the exact file(s) and line(s) to modify
- Confirm the change preserves existing behavior and contracts

Then:
- Apply only the minimal necessary modification
- Do not expand scope, refactor, rename, or touch code outside the direct fix
- If scope grows or uncertainty appears → STOP and report
- If anything unexpected appears → STOP

---

## Write History

Append the following block as the last entry within the section `## Unprocessed`
in `/obelisk/history/history-log.md`:

``` markdown
## YYYY-MM-DD | [Hotfix Name] | HOTFIX

---

```
---

## Output
```
✅ HOTFIX APPLIED
Recorded in history-log.md
```

STOP.