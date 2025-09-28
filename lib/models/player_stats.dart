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
