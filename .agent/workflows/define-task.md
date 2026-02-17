---
description: Creates a new Obelisk task
---

## Required Files

- `/obelisk/contracts/contracts-summary.md`
- `/obelisk/design/design-summary.md`
- `/obelisk/guidelines/ai-engineering.md`

**If any file is missing:**
- STOP and report missing file
- OUTPUT: Use `/init-project` to initialize the project.


---

### Clean Workspace

Delete all files in `/obelisk/workspace/` before proceeding.

---
## EXECUTION GUARD (CRITICAL)

Task Discovery defines intent.

You MUST NOT plan, implement, or modify code during this phase.  
If execution is triggered at any point → **STOP immediately**.

---

## Entry Point Detection

**Check if task description was provided:**

**IF user provided description:**

```
/define-task Add image picker to main screen
```

- Extract task_description = "Add image picker to main screen"


**IF no description:**

```
/define-task
```

- Output: "Describe your task:"
- Call `/obelisk/internal/suggest-task.md` (outputs suggestions below)
- Wait for response
- Set task_description = [response]

---

## Hotfix Assessment (If Description Provided)

Before starting discovery, assess whether the task qualifies as a hotfix.

**A task qualifies as hotfix if:**
- Scope is narrow, low-risk and clearly defined
- Change is mechanical and localized
- No design or architectural decisions required
- No contract changes required

**Common examples (non-exhaustive):**
- Typo, formatting, or whitespace fix
- Simple rename (variable, function, file)
- Add missing import or dependency
- Trivial bug fix (null check, off-by-one)
- Pure UI changes

**If criteria met:**
- Output: "Detected simple fix. Running hotfix path."
- Hotfix is a special execution path and is allowed to execute immediately from this workflow.
- Call `obelisk/internal/hotfix.md` with task_description
- STOP


---

## Code Reconnaissance (Optional, Bounded)

You MAY read code during Task Discovery, but ONLY to answer:
- **"Where does this change live?"**
- **"Which modules / files are likely affected?"**
- **"Do existing contracts already cover this area?"**

If you find yourself reasoning about *how* to implement → STOP.

**After reconnaissance, output only:** > "Related code reviewed."

---

## Contract vs. Design Boundary

**Contract:** A business invariant that must remain true regardless of implementation.
If violated, business correctness or historical data integrity breaks.

**Design:** How the system is built (tech stack, schema, architecture, modules, UI, patterns).

**Boundary test:**
- Must stay true even if the system is rebuilt differently → Contract
- Describes structure, schema, tech, or implementation detail → Design

---

## Discovery Questions

### Question Rules

These rules apply to all discovery questions in all sets.

**Ask ONLY questions affecting:**
- Task definition or intent
- Scope boundaries
- Feasibility or approach
- Required constraints

**Do NOT ask about:**
- Information already explicitly stated in contracts-summary, design-summary, the task description, or prior answers
- Implementation details (for planning phase)

**Keep questions high-impact. Skip obvious or low-value questions.**

---
## Providing Recommendations

Provide a brief recommendation only when one option is clearly preferable based on existing constraints (code, contracts, or established best practices).

Place the recommendation immediately after the question (never grouped separately).

**Format:**

``` markdown
[Question]

Recommendation: [Option] — [brief reason].

```

Skip recommendation if:
- No clear objective preference
- It depends on user preference
- It requires speculation

If one option is clearly wrong, state the correct choice positively.

---

### Set 1: Understanding (MANDATORY)

Always ask at least one clarification question.

**📌 Questions:**
- What, why, for whom
- Scope boundaries (what's in/out)
- Key constraints or dependencies (including required or preferred external libraries, if any)

**After Set 1:**
> "Understanding complete."

→ If no clarification gaps remain AND no contract require user input:
   - State: "No further questions are needed."
   - Proceed to Task Freeze

→ Otherwise: Continue to Set 2


---

### Set 2: Refinement (If Needed)

Resolve remaining issues in organized groups. Each group may be skipped if no issues were detected.

---

**📌 Group 1: Clarification** (if gaps remain)

- Resolve ambiguities from Set 1
- Important edge cases needing user input
- Approach selection when multiple valid options
- Flag if task should be split

*Skip if no clarification needed.*

---

**📋 Group 2: Contracts**

Check task against all loaded contracts with full context from Set 1.

**If conflict found:**
```
⚠️ **Contract Conflict**

Task: [specific step that conflicts]
Conflicts with: "[exact contract text]"

**Options:**
1. **Update task** — [what changes]
2. **Update contract** — [what exception needed]

**Recommendation:** [Option] because [reason]

Choose: [1/2]
```

**If new contract needed** (ONLY for business-critical rules):
```
📋 **Contract Addition**

Task introduces: [critical functionality]

— [Rule — why contract-worthy]

Add? [yes/no]
```

*Skip if no contract issues.*


---

## TASK FREEZE


### `active-task.md`

Write to `/obelisk/workspace/active-task.md`:

``` markdown

# Task: [One-line descriptive name]

## Goal
[What must be achieved and why]

## Scope
✓ Included: [clear list from discovery]
✗ Excluded: [clear list from discovery]

## Constraints
- [Contracts to preserve]
- [Technical/business limits]

## Open Questions (if any)
- [Unresolved ambiguities]

```

---

### `contract-changes.md` (conditional)

**Only create this file if contract changes were approved during discovery.**
Write to `/obelisk/workspace/contract-changes.md`:


``` markdown

# Contract Changes — [Task Name]

**Action:** update | create
**Change:**
- [exact text]

**Action:** create | update
**Change or Move:**
- [exact text]

```

- A rule is contract-worthy only if violating it risks system integrity, business correctness, or irreversible damage.
- **Only include contract changes explicitly approved by the user during discovery**

---

## `discovery-decisions.md`

Write to `/obelisk/workspace/discovery-decisions.md`

**Format**:

```markdown
## [TASK_NAME] | YYYY-MM-DD

**Summary:**
- [one-line task intent]

**Architecture / Design (if applicable):**
- [Long-lived structural decisions]
- [Module boundaries or UX philosophy changes]

**Business Logic (if applicable):**
- [Core behavior rules affecting system]

**Deferred:**
- [Unresolved items or "None"]

```


**Rules:**
- Include ONLY sections with content (skip empty sections).
- Focus on long-lived, system-level decisions.
- Exclude implementation details and cosmetic choices.
- Be concise (under 150 words).

---

### Display Task & Options

**Obelisk: Task Ready**

| **Task**      | [One-line name from header]                   |
| ------------- | --------------------------------------------- |
| **Goal**      | [One sentence]                                |
| **Scope**     | ✓ [2-3 key inclusions] ✗ [1-2 key exclusions] |
| **Contracts** | [brief change or "None"]                      |

**Full definition:** `/obelisk/workspace/active-task.md`

---


## TERMINAL STATE

Output EXACTLY this block. No additions.

``` markdown
**Task frozen:** `/obelisk/workspace/active-task.md`

**Next steps (user-initiated):**
- Execute: `/run-task`
- Edit: modify `/obelisk/workspace/active-task.md`, then run `/run-task`
```