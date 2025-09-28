// ============== services/statistics_service.dart ==============
import '../models/player.dart';
import '../models/game.dart';
import '../models/player_stats.dart';

class StatisticsService {
  List<PlayerStats> calculateStats({required List<Player> players, required List<Game> games}) {
    final statsMap = <String, _StatsAccumulator>{};

    // Initialize stats for all players
    for (var player in players) {
      statsMap[player.id] = _StatsAccumulator(playerId: player.id, name: player.name);
    }

    // Calculate from games
    for (var game in games) {
      _incrementPlayed(statsMap, game.team1Player1);
      _incrementPlayed(statsMap, game.team1Player2);
      _incrementPlayed(statsMap, game.team2Player1);
      _incrementPlayed(statsMap, game.team2Player2);

      if (game.winningTeam == 1) {
        _incrementWon(statsMap, game.team1Player1);
        _incrementWon(statsMap, game.team1Player2);
      } else {
        _incrementWon(statsMap, game.team2Player1);
        _incrementWon(statsMap, game.team2Player2);
      }
    }

    // Convert to PlayerStats and sort
    final stats =
        statsMap.values
            .map(
              (acc) => PlayerStats(
                playerId: acc.playerId,
                name: acc.name,
                played: acc.played,
                won: acc.won,
              ),
            )
            .toList()
          ..sort((a, b) => b.winRate.compareTo(a.winRate));

    return stats;
  }

  void _incrementPlayed(Map<String, _StatsAccumulator> map, String playerId) {
    map[playerId]?.played++;
  }

  void _incrementWon(Map<String, _StatsAccumulator> map, String playerId) {
    map[playerId]?.won++;
  }
}

class _StatsAccumulator {
  final String playerId;
  final String name;
  int played = 0;
  int won = 0;

  _StatsAccumulator({required this.playerId, required this.name});
}
