// ============== services/team_generator_service.dart ==============
import 'dart:math';
import '../models/player.dart';
import '../models/team_generation_result.dart';

class TeamGeneratorService {
  /// Generates random teams with proper rest cycle management
  TeamGenerationResult generateTeams({
    required List<Player> allPlayers,
    required Set<String> selectedPlayerIds,
    required Set<String> restedPlayerIds,
  }) {
    // Validate minimum players
    if (selectedPlayerIds.length < 4) {
      return const TeamGenerationResult(
        teams: [],
        restingPlayers: [],
        errorMessage: 'يجب اختيار 4 لاعبين على الأقل لتكوين فرق',
      );
    }

    final requiredPlayers = selectedPlayerIds.length >= 8 ? 8 : 4;
    final numTeams = requiredPlayers ~/ 2;

    // Check if cycle should reset
    final shouldResetCycle = restedPlayerIds.length >= selectedPlayerIds.length;
    final activeRestedIds = shouldResetCycle ? <String>{} : Set<String>.from(restedPlayerIds);

    // Separate players into pools
    final selectedPlayers = allPlayers.where((p) => selectedPlayerIds.contains(p.id)).toList();

    final eligibleToRest =
        selectedPlayers.where((p) => !activeRestedIds.contains(p.id)).toList()..shuffle();

    final alreadyRested =
        selectedPlayers.where((p) => activeRestedIds.contains(p.id)).toList()..shuffle();

    // Select players for teams (prioritizing those who haven't rested)
    final chosenPlayers = <Player>[];
    final needFromEligible = min(requiredPlayers, eligibleToRest.length);
    chosenPlayers.addAll(eligibleToRest.sublist(0, needFromEligible));

    final remainingNeeded = requiredPlayers - chosenPlayers.length;
    if (remainingNeeded > 0) {
      chosenPlayers.addAll(alreadyRested.sublist(0, min(remainingNeeded, alreadyRested.length)));
    }

    if (chosenPlayers.length < requiredPlayers) {
      return const TeamGenerationResult(
        teams: [],
        restingPlayers: [],
        errorMessage: 'خطأ في عدد اللاعبين المختارين لتكوين الفرق المطلوبة',
      );
    }

    chosenPlayers.shuffle();

    // Create teams
    final teams = List.generate(numTeams, (_) => <Player>[]);
    for (int i = 0; i < chosenPlayers.length; i++) {
      teams[i % numTeams].add(chosenPlayers[i]);
    }

    // Determine resting players
    final chosenIds = chosenPlayers.map((p) => p.id).toSet();
    final restingPlayers = selectedPlayers.where((p) => !chosenIds.contains(p.id)).toList();

    return TeamGenerationResult(teams: teams, restingPlayers: restingPlayers);
  }
}
