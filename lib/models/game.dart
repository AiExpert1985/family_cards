// ============== models/game.dart ==============
class Game {
  final String id;
  final DateTime date;
  final String team1Player1;
  final String team1Player2;
  final String team2Player1;
  final String team2Player2;
  final int winningTeam;
  final bool isKonkan; // Add this field

  const Game({
    required this.id,
    required this.date,
    required this.team1Player1,
    required this.team1Player2,
    required this.team2Player1,
    required this.team2Player2,
    required this.winningTeam,
    this.isKonkan = false, // Add this
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'team1Player1': team1Player1,
        'team1Player2': team1Player2,
        'team2Player1': team2Player1,
        'team2Player2': team2Player2,
        'winningTeam': winningTeam,
        'isKonkan': isKonkan, // Add this
      };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] ?? '',
        date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
        team1Player1: json['team1Player1'] ?? '',
        team1Player2: json['team1Player2'] ?? '',
        team2Player1: json['team2Player1'] ?? '',
        team2Player2: json['team2Player2'] ?? '',
        winningTeam: json['winningTeam'] ?? 1,
        isKonkan: json['isKonkan'] ?? false, // Add this
      );
}