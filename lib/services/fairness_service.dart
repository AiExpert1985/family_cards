import '../models/game.dart';
import '../models/player.dart';

/// Service for evaluating team fairness based on historical partnership data
class FairnessService {
  /// Builds a partnership matrix from all historical games
  /// Returns a map where partnershipMatrix[playerId1][playerId2] = number of times they've partnered
  Map<String, Map<String, int>> buildPartnershipMatrix(List<Game> allGames) {
    final matrix = <String, Map<String, int>>{};

    for (final game in allGames) {
      // Team 1 partnerships
      _recordPartnership(matrix, game.team1Player1, game.team1Player2);

      // Team 2 partnerships
      _recordPartnership(matrix, game.team2Player1, game.team2Player2);
    }

    return matrix;
  }

  void _recordPartnership(
    Map<String, Map<String, int>> matrix,
    String player1Id,
    String player2Id,
  ) {
    // Initialize maps if they don't exist
    matrix.putIfAbsent(player1Id, () => {});
    matrix.putIfAbsent(player2Id, () => {});

    // Increment count in both directions
    matrix[player1Id]![player2Id] = (matrix[player1Id]![player2Id] ?? 0) + 1;
    matrix[player2Id]![player1Id] = (matrix[player2Id]![player1Id] ?? 0) + 1;
  }

  /// Scores a team configuration based on fairness
  /// Lower score = fairer (partners who have played together less)
  /// Returns total partnership count across all teams
  int scoreTeamConfiguration(
    List<List<Player>> teams,
    Map<String, Map<String, int>> partnershipMatrix,
  ) {
    int totalScore = 0;

    for (final team in teams) {
      if (team.length == 2) {
        final player1Id = team[0].id;
        final player2Id = team[1].id;

        // Get how many times this pair has played together
        final count = partnershipMatrix[player1Id]?[player2Id] ?? 0;
        totalScore += count;
      }
    }

    return totalScore;
  }

  /// Gets the partnership count between two players
  int getPartnershipCount(
    String player1Id,
    String player2Id,
    Map<String, Map<String, int>> partnershipMatrix,
  ) {
    return partnershipMatrix[player1Id]?[player2Id] ?? 0;
  }
}
