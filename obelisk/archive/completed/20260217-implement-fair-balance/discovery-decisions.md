## Fair Balance Team Generation | 2026-02-17

**Summary:**
Enhance team generation to prefer least-played-together partnerships based on global game history while maintaining daily non-repetition.

**Architecture / Design:**
- Generate-and-pick-best approach: create 3-5 match options, score by fairness, select best
- Extensible preference layer/service architecture for future scoring criteria
- On-demand partnership matrix computation from game history (no persistent storage)

**Business Logic:**
- Hard rule: Daily partnership blocking remains unchanged
- Soft preference: Global historical partnership counts guide selection
- Fairness convergence over time as core system behavior

**Deferred:**
None
