## 20260401-0000 | Diff-Based Player Ranking | TASK

**Task:** Changed all 4 ranking contexts (overall, daily, partner/teammate, opponent/head-to-head) from win-rate percentage to diff (wins − losses), with tiebreak by total games played (both tied players share the same rank number). The overall ranking additionally splits below-threshold players (those with fewer than 50% of average games played) into a separate section at the bottom labeled in Arabic, rather than mixing them into the ranked list. The win rate percentage is preserved in the UI as small text on the wins/losses row, while the main badge now shows the diff with +/− prefix colored green/orange/red. The champions tab (الابطال) is unaffected and retains win-rate-based first-place determination.

**Rejected:** Excluding below-threshold players entirely from the overall list — rejected in favor of showing them in a visually distinct section so players understand why they are not ranked.

---
