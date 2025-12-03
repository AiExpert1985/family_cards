// ============== services/statistics_service.dart ==============
import '../models/player.dart';
import '../models/game.dart';
import '../models/player_stats.dart';

class StatisticsService {
  List<PlayerStats> calculateStats({required List<Player> players, required List<Game> games}) {
    return _calculateStats(players: players, games: games);
  }

  List<PlayerStats> calculateDailyStats({
    required DateTime date,
    required List<Player> players,
    required List<Game> games,
  }) {
    final filteredGames = games.where((game) => _isSameDay(game.date, date)).toList();
    return _calculateStats(
      players: players,
      games: filteredGames,
      sort: (a, b) {
        final winsComparison = b.won.compareTo(a.won);
        if (winsComparison != 0) return winsComparison;
        return b.winRate.compareTo(a.winRate);
      },
    );
  }

  List<FirstPlaceStats> calculateFirstPlaceStats({
    required List<Player> players,
    required List<Game> games,
  }) {
    if (players.isEmpty || games.isEmpty) return [];

    final cupCount = <String, int>{};
    final cupDates = <String, List<DateTime>>{};
    final sharedCupDates = <String, Set<String>>{}; // Track which dates had shared cups

    for (var player in players) {
      cupCount[player.id] = 0;
      cupDates[player.id] = [];
      sharedCupDates[player.id] = {};
    }

    final sortedGames = List<Game>.from(games)..sort((a, b) => a.date.compareTo(b.date));

    final uniqueDatesSet = <String>{};
    for (var game in sortedGames) {
      uniqueDatesSet.add(_getDateKey(game.date));
    }
    final uniqueDates = uniqueDatesSet.toList()..sort();

    for (var dateKey in uniqueDates) {
      final gamesUpToDate = <Game>[];
      DateTime? cupDate;
      for (var game in sortedGames) {
        if (_getDateKey(game.date).compareTo(dateKey) <= 0) {
          gamesUpToDate.add(game);
          if (_getDateKey(game.date) == dateKey && cupDate == null) {
            cupDate = game.date;
          }
        }
      }

      if (gamesUpToDate.isEmpty || cupDate == null) continue;

      final stats = _calculateStats(players: players, games: gamesUpToDate);
      if (stats.isEmpty) continue;

      final maxWinRateRounded = stats.first.winRate.round();
      final winners = <String>[];
      for (var stat in stats) {
        if (stat.winRate.round() == maxWinRateRounded && stat.played > 0) {
          winners.add(stat.playerId);
          cupCount[stat.playerId] = (cupCount[stat.playerId] ?? 0) + 1;
          cupDates[stat.playerId]!.add(cupDate);
        } else {
          break;
        }
      }

      // Mark as shared if multiple winners
      if (winners.length > 1) {
        for (var playerId in winners) {
          sharedCupDates[playerId]!.add(dateKey);
        }
      }
    }

    return players
        .map((p) => FirstPlaceStats(
              playerId: p.id,
              name: p.name,
              firstPlaceCount: cupCount[p.id] ?? 0,
              cupDates: cupDates[p.id] ?? [],
              sharedCupDates: sharedCupDates[p.id] ?? {},
            ))
        .where((s) => s.firstPlaceCount > 0)
        .toList()
      ..sort((a, b) => b.firstPlaceCount.compareTo(a.firstPlaceCount));
  }

  List<HeadToHeadStat> calculateHeadToHeadStats({
    required String playerId,
    required List<Player> players,
    required List<Game> games,
  }) {
    if (players.isEmpty || playerId.isEmpty) return const <HeadToHeadStat>[];

    final playerIds = players.map((p) => p.id).toSet();
    if (!playerIds.contains(playerId)) {
      return const <HeadToHeadStat>[];
    }

    final accumulator = <String, _HeadToHeadAccumulator>{};

    for (final player in players) {
      if (player.id == playerId) continue;
      accumulator[player.id] = _HeadToHeadAccumulator(
        opponentId: player.id,
        opponentName: player.name,
      );
    }

    for (final game in games) {
      final isTeam1 =
          game.team1Player1 == playerId || game.team1Player2 == playerId;
      final isTeam2 =
          game.team2Player1 == playerId || game.team2Player2 == playerId;

      if (!isTeam1 && !isTeam2) continue;

      final didWin = (isTeam1 && game.winningTeam == 1) ||
          (isTeam2 && game.winningTeam == 2);
      final opponents = isTeam1
          ? [game.team2Player1, game.team2Player2]
          : [game.team1Player1, game.team1Player2];

      for (final opponentId in opponents) {
        if (opponentId == playerId) continue;
        final stats = accumulator[opponentId];
        if (stats == null) continue;
        stats.played++;
        if (didWin) stats.won++;
      }
    }

    final stats =
        accumulator.values
            .map(
              (value) => HeadToHeadStat(
                opponentId: value.opponentId,
                opponentName: value.opponentName,
                played: value.played,
                won: value.won,
              ),
            )
            .toList()
          ..sort(
            (a, b) {
              final rateCompare = b.winRate.compareTo(a.winRate);
              if (rateCompare != 0) return rateCompare;
              final playedCompare = b.played.compareTo(a.played);
              if (playedCompare != 0) return playedCompare;
              return a.opponentName.compareTo(b.opponentName);
            },
          );

    return stats;
  }

  List<TeammateStats> calculateTeammateStats({
    required String playerId,
    required List<Player> players,
    required List<Game> games,
  }) {
    if (players.isEmpty || playerId.isEmpty) return const <TeammateStats>[];

    final playerIds = players.map((p) => p.id).toSet();
    if (!playerIds.contains(playerId)) {
      return const <TeammateStats>[];
    }

    final accumulator = <String, _TeammateAccumulator>{};

    for (final player in players) {
      if (player.id == playerId) continue;
      accumulator[player.id] = _TeammateAccumulator(
        teammateId: player.id,
        teammateName: player.name,
      );
    }

    for (final game in games) {
      final isTeam1 =
          game.team1Player1 == playerId || game.team1Player2 == playerId;
      final isTeam2 =
          game.team2Player1 == playerId || game.team2Player2 == playerId;

      if (!isTeam1 && !isTeam2) continue;

      final didWin = (isTeam1 && game.winningTeam == 1) ||
          (isTeam2 && game.winningTeam == 2);
      final teammate = isTeam1
          ? (game.team1Player1 == playerId ? game.team1Player2 : game.team1Player1)
          : (game.team2Player1 == playerId ? game.team2Player2 : game.team2Player1);

      final stats = accumulator[teammate];
      if (stats == null) continue;
      stats.played++;
      if (didWin) stats.won++;
    }

    final stats =
        accumulator.values
            .map(
              (value) => TeammateStats(
                teammateId: value.teammateId,
                teammateName: value.teammateName,
                played: value.played,
                won: value.won,
              ),
            )
            .toList()
          ..sort(
            (a, b) {
              final rateCompare = b.winRate.compareTo(a.winRate);
              if (rateCompare != 0) return rateCompare;
              final playedCompare = b.played.compareTo(a.played);
              if (playedCompare != 0) return playedCompare;
              return a.teammateName.compareTo(b.teammateName);
            },
          );

    return stats;
  }

  List<Game> getPlayerGames({
    required String playerId,
    required List<Game> games,
  }) {
    return games
        .where(
          (game) =>
              game.team1Player1 == playerId ||
              game.team1Player2 == playerId ||
              game.team2Player1 == playerId ||
              game.team2Player2 == playerId,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<PlayerStats> _calculateStats({
    required List<Player> players,
    required List<Game> games,
    int Function(PlayerStats a, PlayerStats b)? sort,
  }) {
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
    final stats = statsMap.values
        .map(
          (acc) => PlayerStats(
            playerId: acc.playerId,
            name: acc.name,
            played: acc.played,
            won: acc.won,
          ),
        )
        .toList()
      ..sort(sort ?? (a, b) => b.winRate.compareTo(a.winRate));

    return stats;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year && localA.month == localB.month && localA.day == localB.day;
  }

  String _getDateKey(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
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

class _HeadToHeadAccumulator {
  final String opponentId;
  final String opponentName;
  int played = 0;
  int won = 0;

  _HeadToHeadAccumulator({
    required this.opponentId,
    required this.opponentName,
  });
}

class _TeammateAccumulator {
  final String teammateId;
  final String teammateName;
  int played = 0;
  int won = 0;

  _TeammateAccumulator({
    required this.teammateId,
    required this.teammateName,
  });
}
