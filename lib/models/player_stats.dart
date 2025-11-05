// ============== models/player_stats.dart ==============
class PlayerStats {
  final String playerId;
  final String name;
  final int played;
  final int won;

  const PlayerStats({
    required this.playerId,
    required this.name,
    required this.played,
    required this.won,
  });

  double get winRate => played > 0 ? (won / played * 100) : 0;
  String get winRateText => '${winRate.toStringAsFixed(0)}%';
  int get lost => played - won;
}

class HeadToHeadStat {
  final String opponentId;
  final String opponentName;
  final int played;
  final int won;

  const HeadToHeadStat({
    required this.opponentId,
    required this.opponentName,
    required this.played,
    required this.won,
  });

  int get lost => played - won;
  double get winRate => played > 0 ? (won / played * 100) : 0;
  String get winRateText => '${winRate.toStringAsFixed(0)}%';
}

class FirstPlaceStats {
  final String playerId;
  final String name;
  final int firstPlaceCount;

  const FirstPlaceStats({
    required this.playerId,
    required this.name,
    required this.firstPlaceCount,
  });
}
