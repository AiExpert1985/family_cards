---
description: Initialize new Obelisk project
---
## Required Files

- `/obelisk/guidelines/ai-engineering.md`

---

## Forbidden Pre-Existing State

The following MUST NOT exist:

**State files:**

- `/obelisk/contracts/contracts-summary.md`
- `/obelisk/contracts/contracts-log.md`
- `/obelisk/design/design-summary.md`
- `/obelisk/design/design-log.md`
- `/obelisk/history/history-log.md`

If any exist → **STOP**.

**Output to user:**

> ⛔ PROJECT INIT ABORTED  
> This project appears to be already initialized.  
> Re-initialization is blocked to prevent accidental data loss.  
> If you intended to start fresh, ensure no existing project state remains.

---

# PHASE 1: DISCOVERY

Understand the project and identify contract and design candidates.  
**No files created yet.**

---

## Contract vs. Design Boundary

**Contract:** A business invariant that must remain true regardless of implementation.
If violated, business correctness or historical data integrity breaks.

**Design:** How the system is built (tech stack, schema, architecture, modules, UI, patterns).

**Boundary test:**
- Must stay true even if the system is rebuilt differently → Contract
- Describes structure, schema, tech, or implementation detail → Design

---

## Discovery Rules

**Questioning Rules**

- Ask only what materially affects contracts or long-lived design
- Do NOT assume missing information — surface it explicitly
- Prefer fewer, high-impact questions
- Skip obvious or deferrable details
- Group related clarifications into one question

**Allowed Topics**

- System identity and boundaries
- Core invariants
- Global or technical constraints
- Safety or irreversible risks
- Long-lived architectural or UX intent

**Forbidden Topics**

- Implementation details
- Edge cases or speculative future features
- Preferences likely to change
- Anything deferrable to task-level work or clearly inferable

---

## Discovery Flow

### 1. Open

Output exactly:

```
PHASE 1: DISCOVERY

Describe your system to help initialize contracts.
Type `skip` to use minimal defaults (not recommended).
```

**STOP. Wait for user response.**

- If `skip` → proceed to PHASE 2
- Otherwise → treat response as project description and proceed to Clarification

---

### 2. Clarification

#### Step 1 — Core Questions

Based on the project description provided by the user, ask questions that materially affect:
- System identity and boundaries
- Contracts and invariants
- Global constraints or risks
- Long-lived architectural or UX intent

Ask only what would change contracts or durable understanding.

---

#### Step 2 — Follow-up Questions

Ask follow-up questions **only if needed** to resolve ambiguity introduced by earlier answers.

---

### 3. Summary

Present confirmed understanding for review.

If ambiguity remains:

- Record unresolved items under **Open Questions**
- Treat them as task-level concerns, not blockers
- Proceed with initialization

**Summary Format**

```markdown
**System Identity:**
- What it is:
- What it is NOT:
- Users:

**Contract Candidates:**
- Core:
- [Feature]:

**Safety Concerns:**  
**Explicit Non-Goals:**  
**Open Questions:**
```

---

## Discovery Exit

Output exactly:

```
Review the summary above.
- Type `initialize` to create project files
- Or reply with corrections to update the summary

Awaiting input.
```

**STOP. Do not proceed until user responds.**

- If `initialize` → proceed to PHASE 2
- Otherwise → treat as corrections, update summary, confirm again

---

# PHASE 2: INITIALIZATION

Extract and persist confirmed project truth.  
**Non-interactive. Non-creative.**

---

## Rules

- Use ONLY explicitly established information
- Do NOT invent or strengthen intent
- Be minimal — over-specification is failure
- List unresolved items explicitly

---

## Initialization (Skipped Discovery)

If discovery was skipped:

- Populate only explicitly stated information
- Leave all other sections empty (no inference)

---

## Required Outputs

### 1. Canonical Logs (Must Remain Empty)

Create the following files and leave them completely empty:

- `/obelisk/contracts/contracts-log.md`
- `/obelisk/design/design-log.md`
- `/obelisk/history/history-log.md`

Rules:

- No placeholder text
- No additional headers
- These files must remain empty until first maintenance compaction.

---

### 2. Create Summaries with Structure

All initialization content MUST be written only under `## Unprocessed`.

Do NOT create `## Processed` or additional sections.  
Keep structured sections empty with placeholder text.

---

### **`/obelisk/contracts/contracts-summary.md`:**

``` markdown
# Contracts Summary

Generated: YYYY-MM-DD

## System Identity
_(empty — populated after first maintenance)_

## Active Contracts
_(empty — populated after first maintenance)_

## Non-Goals
_(empty — populated after first maintenance)_

## Unprocessed

[Append all initialization contracts here]
```

**Content allowed under `## Unprocessed`:**

- A rule is contract-worthy only if violating it risks system integrity, business correctness, or irreversible damage.
- System identity and boundaries
- Global business rules
- Safety-critical rules
- Explicit non-goals
- Open contract questions

---

### **`/obelisk/design/design-summary.md`:**

``` markdown

# Design Summary

Generated: YYYY-MM-DD

## System Architecture
_(empty — populated after maintenance)_

## Data Model
_(empty — populated after maintenance)_

## Core Design Principles
_(empty — populated after maintenance)_

## Modules
_(empty — populated after maintenance)_

## Open Design Questions
_(empty — populated after maintenance)_

## Unprocessed

[Append all initialization architecture & design decisions here]

```

**Content allowed under `## Unprocessed`:**

- Long-lived architectural decisions
- Module definitions and responsibilities
- Technology stack decisions
- Core design principles
- UX philosophy (not layout specifics)
- Open design questions

---

## Output

> ✅ PROJECT INITIALIZED

STOP.