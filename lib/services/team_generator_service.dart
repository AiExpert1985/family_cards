import 'dart:math';

// ============== services/team_generator_service.dart ==============
import '../models/player.dart';
import '../models/team_generation_result.dart';

class TeamGeneratorService {
  static const int _maxRetries = 100;

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
      return _generateTeamsWithRetry(selectedPlayers, [], random, allPlayers);
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
        selectedPlayers.where((p) => !restingPlayers.any((resting) => resting.id == p.id)).toList();

    return _generateTeamsWithRetry(playingPlayers, restingPlayers, random, allPlayers);
  }

  TeamGenerationResult _generateTeamsWithRetry(
    List<Player> playingPlayers,
    List<Player> restingPlayers,
    Random random,
    List<Player> allPlayers,
  ) {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      final shuffled = List<Player>.from(playingPlayers)..shuffle(random);
      final teams = <List<Player>>[];

      for (int i = 0; i < shuffled.length; i += 2) {
        if (i + 1 < shuffled.length) {
          teams.add([shuffled[i], shuffled[i + 1]]);
        }
      }

      if (!_hasRepeatedPairings(teams)) {
        final updatedPlayers = _updatePlayerPairings(teams, allPlayers);
        return TeamGenerationResult(
          teams: teams,
          restingPlayers: restingPlayers,
          updatedPlayers: updatedPlayers,
        );
      }
    }

    // Max retries reached, allow repeated pairings
    final teams = <List<Player>>[];
    playingPlayers.shuffle(random);
    for (int i = 0; i < playingPlayers.length; i += 2) {
      if (i + 1 < playingPlayers.length) {
        teams.add([playingPlayers[i], playingPlayers[i + 1]]);
      }
    }

    final updatedPlayers = _updatePlayerPairings(teams, allPlayers);
    return TeamGenerationResult(
      teams: teams,
      restingPlayers: restingPlayers,
      updatedPlayers: updatedPlayers,
    );
  }

  bool _hasRepeatedPairings(List<List<Player>> teams) {
    for (final team in teams) {
      if (team.length == 2) {
        final player1 = team[0];
        final player2 = team[1];
        if (player1.pairedWithToday.contains(player2.id)) {
          return true;
        }
      }
    }
    return false;
  }

  List<Player> _updatePlayerPairings(List<List<Player>> teams, List<Player> allPlayers) {
    final pairingsMap = <String, Set<String>>{};

    for (final team in teams) {
      if (team.length == 2) {
        final player1Id = team[0].id;
        final player2Id = team[1].id;

        pairingsMap.putIfAbsent(player1Id, () => {}).add(player2Id);
        pairingsMap.putIfAbsent(player2Id, () => {}).add(player1Id);
      }
    }

    return allPlayers.map((player) {
      if (pairingsMap.containsKey(player.id)) {
        final newPairings = List<String>.from(player.pairedWithToday);
        newPairings.addAll(pairingsMap[player.id]!);
        return player.copyWith(pairedWithToday: newPairings);
      }
      return player;
    }).toList();
  }
}
