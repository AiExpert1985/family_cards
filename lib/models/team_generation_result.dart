// ============== models/team_generation_result.dart ==============
import 'package:family_cards/models/player.dart';

class TeamGenerationResult {
  final List<List<Player>> teams;
  final List<Player> restingPlayers;
  final String? errorMessage;

  const TeamGenerationResult({
    required this.teams,
    required this.restingPlayers,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null;
  bool get isSuccess => !hasError && teams.isNotEmpty;
}
