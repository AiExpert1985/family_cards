## active-plan: Implement Fair Balance Team Generation

### Goal
Enhance the team generation algorithm to promote long-term fairness by preferring partnerships with the lowest historical play counts, while maintaining the existing daily non-repetition constraint. The system should generate multiple match options and select the one with the best fairness score.

### Initial Plan

**Approach:**
Create a new `FairnessService` to compute historical partnership matrices and score team configurations. Modify `TeamGeneratorService` to generate 3-5 candidate team sets, score each using fairness metrics, and select the best option. The `_generateLeastUsedPairings()` method will be updated to use global historical counts instead of daily counts. All partnership data will be computed on-demand from game history without persistent storage.

**Affected Modules:**
- Team generation service
- (New) Fairness evaluation service

**Files to modify:**
- `lib/services/team_generator_service.dart` — Update retry logic to generate multiple candidates and pick best; update `_generateLeastUsedPairings()` to use global counts

**Files to create:**
- `lib/services/fairness_service.dart` — Build partnership matrix from game history; score team configurations

**Key Steps:**
1. Create `FairnessService` with methods to build partnership matrix from all games and score team configurations
2. Update `TeamGeneratorService._generateTeamsWithRetry()` to generate 3-5 candidates and use fairness scoring to pick best
3. Update `TeamGeneratorService._generateLeastUsedPairings()` to accept partnership matrix and use global counts instead of daily counts
4. Ensure daily partnership blocking remains unchanged (hard rule preserved)
5. Verify behavior manually by generating teams multiple times with existing game history

**Constraints:**
- Preserve contracts: Daily non-repetition (hard rule) and long-term fairness (soft preference)
- Respect design: Services-based architecture, feature separation
- Do not expand scope: No UI changes, no data model changes, no persistent storage

---

## Plan Revisions

None required. Implementation followed initial plan.

---

## Execution Summary

**Final approach:** 
- Created `FairnessService` with methods to build partnership matrix from game history and score team configurations based on historical partnership counts
- Modified `TeamGeneratorService._generateTeamsWithRetry()` to generate 5 candidate team configurations, score each using fairness metrics, and select the candidate with the lowest score (fairest)
- Updated `TeamGeneratorService._generateLeastUsedPairings()` to accept and use global partnership matrix instead of daily `pairedWithToday` counts
- Added constructor to `TeamGeneratorService` requiring `FairnessService` and `List<Game>` dependencies
- Created `fairnessServiceProvider` and updated `teamGeneratorServiceProvider` in providers.dart to properly inject dependencies

**Deferred items:** None
