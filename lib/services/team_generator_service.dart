// ============== services/team_generator_service.dart ==============
import '../models/player.dart';
import '../models/team_generation_result.dart';

class TeamGeneratorService {
  TeamGenerationResult generateTeams({
    required List<Player> allPlayers,
    required Set<String> selectedPlayerIds,
    required Set<String> restedPlayerIds,
  }) {
    if (selectedPlayerIds.length < 4) {
      return const TeamGenerationResult(
        teams: [],
        restingPlayers: [],
        errorMessage: 'يجب اختيار 4 لاعبين على الأقل لتكوين فرق',
      );
    }

    final selectedPlayers = allPlayers.where((p) => selectedPlayerIds.contains(p.id)).toList();

    // Find players who haven't rested yet in this cycle
    final notRestedYet = selectedPlayers.where((p) => !restedPlayerIds.contains(p.id)).toList();

    // Reset cycle if everyone has rested (no one left who hasn't rested)
    final playersToChooseFrom = notRestedYet.isEmpty ? selectedPlayers : notRestedYet;

    // Calculate rest count: remainder when dividing by 4
    final totalSelected = selectedPlayers.length;
    final restingCount = totalSelected % 4 == 0 ? 0 : totalSelected % 4;

    // If no one needs to rest (multiple of 4), everyone plays
    if (restingCount == 0) {
      selectedPlayers.shuffle();
      final teams = <List<Player>>[];
      for (int i = 0; i < selectedPlayers.length; i += 2) {
        teams.add([selectedPlayers[i], selectedPlayers[i + 1]]);
      }
      return TeamGenerationResult(teams: teams, restingPlayers: []);
    }

    // Select resting players randomly from eligible players
    playersToChooseFrom.shuffle();
    final restingPlayers = playersToChooseFrom.take(restingCount).toList();

    // Remaining players form teams
    final playingPlayers =
        selectedPlayers.where((p) => !restingPlayers.any((resting) => resting.id == p.id)).toList()
          ..shuffle();

    // Create teams of 2 players each
    final teams = <List<Player>>[];
    for (int i = 0; i < playingPlayers.length; i += 2) {
      teams.add([playingPlayers[i], playingPlayers[i + 1]]);
    }

    return TeamGenerationResult(teams: teams, restingPlayers: restingPlayers);
  }
}
