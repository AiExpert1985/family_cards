# Task: Implement Fair Balance Team Generation

## Goal
Enhance the team generation algorithm to promote long-term fairness by preferring partnerships with the lowest historical play counts, while maintaining the existing daily non-repetition constraint. The system should generate multiple match options and select the one with the best fairness score.

## Scope
✓ Included:
- Build partnership matrix from all historical games (computed on-demand, not stored)
- Implement "generate N candidates and pick best" approach (3-5 options)
- Create fairness scoring function to evaluate match quality
- Create extensible preference layer/service for future criteria
- Maintain existing daily partnership blocking (hard rule)
- Replace current `_generateLeastUsedPairings()` to use global historical counts instead of daily counts

✗ Excluded:
- Any UI changes or mode toggles
- Storing partnership counts persistently
- Changing the Game or Player data models
- Modifying daily repetition blocking logic
- Adding weighted random selection approach

## Constraints
- **Daily Non-Repetition (Hard Rule):** No two players can partner together more than once in the same day, unless all possible partnerships have been exhausted and a new cycle begins
- **Global Fairness Preference (Soft Preference):** Prefer partnerships with lowest historical play counts across all games
- **No New Persistent Data:** Partnership counts calculated dynamically from game history each time
- **Minimal Code Changes:** Implement as a new layer/service to keep code extensible for future preferences
- **Backward Compatibility:** Preserve existing team generation behavior when retry logic is needed

## Open Questions
None
