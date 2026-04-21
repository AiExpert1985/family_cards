## 20260401-0000 | Diff-Based Player Ranking | TASK

**Task:** Changed all 4 ranking contexts (overall, daily, partner/teammate, opponent/head-to-head) from win-rate percentage to diff (wins − losses), with tiebreak by total games played (both tied players share the same rank number). The overall ranking additionally splits below-threshold players (those with fewer than 50% of average games played) into a separate section at the bottom labeled in Arabic, rather than mixing them into the ranked list. The win rate percentage is preserved in the UI as small text on the wins/losses row, while the main badge now shows the diff with +/− prefix colored green/orange/red. The champions tab (الابطال) is unaffected and retains win-rate-based first-place determination.

**Rejected:** Excluding below-threshold players entirely from the overall list — rejected in favor of showing them in a visually distinct section so players understand why they are not ranked.

---

## 20260401-0002 | Import Override for Existing Games and Players | TASK

**Task:** Changed the JSON import merge logic so that imported games and players override existing records when their IDs match, rather than being skipped. Local records not present in the imported file are preserved. New records from the import are still added.

---

## 20260401-0001 | Calendar Dot Markers for Days With Games | TASK

**Task:** Replaced the built-in `showDatePicker` in the daily stats tab with a `table_calendar`-based bottom sheet that shows dot markers on days that have at least one game recorded. Dots are teal-colored, matching the app theme. The `intl` dependency was bumped to `^0.20.2` to satisfy `table_calendar 3.2.0`'s requirement.

---

## 20260421-0000 | Dual Stats Pages + Redesigned Main Screen | TASK

**Task:** Split the single Statistics screen into two dedicated pages — Overall Stats and Daily Stats — each with three tabs: Ranking, Cups, and Games. The Games tab in Overall Stats absorbed the standalone Games screen, which was removed from the home page app bar. Daily Cups awards gold cups based on single-day diff (wins−losses), with all tied winners receiving the same gold cup. Tapping any cup in either page shows a standings snapshot for the date that produced that cup: cumulative for overall cups, single-day for daily cups. The Daily Stats page auto-selects the last day with games and provides a calendar picker (with game-day dot markers) in the app bar. The main screen was redesigned with two rectangular stat buttons (teal for Overall, purple for Daily) and a small circular icon button for random team generation.

**Rejected:** Different cup colors for tied daily cup winners — rejected in favor of uniform gold for simplicity.

---

## 20260421-0001 | Main Screen Action Buttons + Modern Games UX | TASK

**Task:** Added a second circular icon button beside the existing challenge button on the main screen — a green "add result" button that navigates directly to the add-game flow. The challenge button icon was changed to a crossed-swords symbol. The Games tab in Overall Stats was simplified to a pure history list: the add button, player filter dropdown, and section title were removed. Game card edit and delete actions were modernised — long press opens the edit flow, swipe left deletes immediately with a 4-second undo snackbar.

**Rejected:** Using `font_awesome_flutter` for the swords icon — the crossed-swords icon is Pro-only in Font Awesome; Unicode ⚔️ was used instead with no new dependency.

---
