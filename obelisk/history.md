## 20260401-0000 | Diff-Based Player Ranking | TASK

**Task:** Changed all 4 ranking contexts (overall, daily, partner/teammate, opponent/head-to-head) from win-rate percentage to diff (wins − losses), with tiebreak by total games played (both tied players share the same rank number). The overall ranking additionally splits below-threshold players (those with fewer than 50% of average games played) into a separate section at the bottom labeled in Arabic, rather than mixing them into the ranked list. The win rate percentage is preserved in the UI as small text on the wins/losses row, while the main badge now shows the diff with +/− prefix colored green/orange/red. The champions tab (الابطال) is unaffected and retains win-rate-based first-place determination.

**Rejected:** Excluding below-threshold players entirely from the overall list — rejected in favor of showing them in a visually distinct section so players understand why they are not ranked.

---

## 20260401-0001 | Calendar Dot Markers for Days With Games | TASK

**Task:** Replaced the built-in `showDatePicker` in the daily stats tab with a `table_calendar`-based bottom sheet that shows dot markers on days that have at least one game recorded. Dots are teal-colored, matching the app theme. The `intl` dependency was bumped to `^0.20.2` to satisfy `table_calendar 3.2.0`'s requirement.

---
