import 'dart:math';

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

    final random = Random(DateTime.now().microsecondsSinceEpoch);

    final selectedPlayers = allPlayers.where((p) => selectedPlayerIds.contains(p.id)).toList();

    final totalSelected = selectedPlayers.length;
    final restingCount = totalSelected % 4 == 0 ? 0 : totalSelected % 4;

    if (restingCount == 0) {
      selectedPlayers.shuffle(random);
      final teams = <List<Player>>[];
      for (int i = 0; i < selectedPlayers.length; i += 2) {
        teams.add([selectedPlayers[i], selectedPlayers[i + 1]]);
      }
      return TeamGenerationResult(teams: teams, restingPlayers: []);
    }

    final notRestedYet = selectedPlayers.where((p) => !restedPlayerIds.contains(p.id)).toList();

    final restingPlayers = <Player>[];

    if (notRestedYet.length >= restingCount) {
      // Normal case
      notRestedYet.shuffle(random);
      restingPlayers.addAll(notRestedYet.take(restingCount));
    } else {
      // Edge case: cycle reset needed
      restingPlayers.addAll(notRestedYet);

      final eligibleForNewCycle =
          selectedPlayers.where((p) => !restingPlayers.contains(p)).toList()
            ..shuffle(random);

      final stillNeeded = restingCount - notRestedYet.length;
      restingPlayers.addAll(eligibleForNewCycle.take(stillNeeded));
    }

    final playingPlayers =
        selectedPlayers.where((p) => !restingPlayers.any((resting) => resting.id == p.id)).toList()
          ..shuffle(random);

    final teams = <List<Player>>[];
    for (int i = 0; i < playingPlayers.length; i += 2) {
      if (i + 1 < playingPlayers.length) {
        teams.add([playingPlayers[i], playingPlayers[i + 1]]);
      }
    }

    return TeamGenerationResult(teams: teams, restingPlayers: restingPlayers);
  }
}
