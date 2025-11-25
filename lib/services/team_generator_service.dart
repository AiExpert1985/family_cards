import 'dart:math';

// ============== services/team_generator_service.dart ==============
import '../models/player.dart';
import '../models/team_generation_result.dart';

class TeamGeneratorService {
  static const int _maxRandomRetries = 50;

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
    // Try random shuffles first
    for (int attempt = 0; attempt < _maxRandomRetries; attempt++) {
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

    // Use least-used pairings algorithm with randomization
    final teams = _generateLeastUsedPairings(playingPlayers, random);
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
        if (player1.pairedWithToday.containsKey(player2.id) ||
            player2.pairedWithToday.containsKey(player1.id)) {
          return true;
        }
      }
    }
    return false;
  }

  List<List<Player>> _generateLeastUsedPairings(List<Player> players, Random random) {
    final remaining = List<Player>.from(players);
    final teams = <List<Player>>[];

    while (remaining.length >= 2) {
      int minCount = 1000000;
      final candidates = <List<Player>>[];

      // Find all pairings with minimum count
      for (int i = 0; i < remaining.length; i++) {
        for (int j = i + 1; j < remaining.length; j++) {
          final p1 = remaining[i];
          final p2 = remaining[j];
          final count = (p1.pairedWithToday[p2.id] ?? 0) + (p2.pairedWithToday[p1.id] ?? 0);

          if (count < minCount) {
            minCount = count;
            candidates.clear();
            candidates.add([p1, p2]);
          } else if (count == minCount) {
            candidates.add([p1, p2]);
          }
        }
      }

      if (candidates.isNotEmpty) {
        // Randomly pick from candidates with minimum count
        final selectedPair = candidates[random.nextInt(candidates.length)];
        teams.add(selectedPair);
        remaining.remove(selectedPair[0]);
        remaining.remove(selectedPair[1]);
      } else {
        break;
      }
    }

    return teams;
  }

  List<Player> _updatePlayerPairings(List<List<Player>> teams, List<Player> allPlayers) {
    final pairingsMap = <String, Map<String, int>>{};

    for (final team in teams) {
      if (team.length == 2) {
        final player1Id = team[0].id;
        final player2Id = team[1].id;

        pairingsMap.putIfAbsent(player1Id, () => {});
        pairingsMap.putIfAbsent(player2Id, () => {});

        pairingsMap[player1Id]![player2Id] =
            (pairingsMap[player1Id]![player2Id] ?? 0) + 1;
        pairingsMap[player2Id]![player1Id] =
            (pairingsMap[player2Id]![player1Id] ?? 0) + 1;
      }
    }

    return allPlayers.map((player) {
      if (pairingsMap.containsKey(player.id)) {
        final newPairings = Map<String, int>.from(player.pairedWithToday);
        pairingsMap[player.id]!.forEach((partnerId, count) {
          newPairings[partnerId] = (newPairings[partnerId] ?? 0) + count;
        });
        return player.copyWith(pairedWithToday: newPairings);
      }
      return player;
    }).toList();
  }
}
