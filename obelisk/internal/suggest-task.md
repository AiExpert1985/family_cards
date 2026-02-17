---
description: Suggest next tasks
---
## Required Files

- `/obelisk/design/design-summary.md`
- `/obelisk/contracts/contracts-summary.md`

If either missing → STOP.

---

## Analysis

### From design-summary.md:

- Active system architecture
- Defined modules and their status
- Core design principles
- Open design questions
- Deferred architectural work

### From contracts-summary.md:

- Active invariants
- Enforcement requirements
- System boundaries
- Explicit non-goals

---

## Task Categories (Priority Order)

1. **Deferred Design**
   - Open design questions requiring resolution
   - Deferred architectural decisions
   - Defined but unimplemented modules

2. **Contract Enforcement**
   - Declared invariants not yet implemented
   - Newly introduced constraints requiring integration

3. **Extension**
   - Logical next steps within existing modules
   - Structural refinements strengthening architecture
   - Completing partially implemented flows

---

## Rules

- Respect contracts and design boundaries
- Avoid speculative features outside declared architecture
- Do not re-suggest completed work
- Tasks must be concrete and scoped
- Prefer system-level impact over local optimization
- If design has many open questions, prioritize architectural clarity first

Select the **top 3 highest-impact tasks**.

---

## Output

```markdown
Here are suggested next tasks based on current system state:

1. **[Task Name]**  
   Why: [Concrete reason grounded in design-summary or contracts-summary]

2. **[Task Name]**  
   Why: [Concrete reason grounded in summaries]

3. **[Task Name]**  
   Why: [Concrete reason grounded in summaries]
```