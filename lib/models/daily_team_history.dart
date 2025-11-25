// ============== models/daily_team_history.dart ==============
import 'player.dart';

class DailyTeamHistory {
  final DateTime date;
  final Map<String, Set<String>> teammates;

  DailyTeamHistory({
    required this.date,
    Map<String, Set<String>>? teammates,
  }) : teammates = teammates ?? {};

  factory DailyTeamHistory.forDate(DateTime date) =>
      DailyTeamHistory(date: date, teammates: {});

  factory DailyTeamHistory.fromJson(Map<String, dynamic> json) {
    final dateString = json['date'] as String?;
    final rawTeammates = json['teammates'] as Map<String, dynamic>?;

    final parsedDate = dateString != null ? DateTime.tryParse(dateString) : null;

    final mappedTeammates = <String, Set<String>>{};
    if (rawTeammates != null) {
      rawTeammates.forEach((key, value) {
        mappedTeammates[key] = (value as List<dynamic>).map((e) => e as String).toSet();
      });
    }

    return DailyTeamHistory(
      date: parsedDate ?? DateTime.now(),
      teammates: mappedTeammates,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'teammates': teammates.map((key, value) => MapEntry(key, value.toList())),
      };

  bool isSameDay(DateTime other) {
    return date.year == other.year && date.month == other.month && date.day == other.day;
  }

  DailyTeamHistory recordTeam(List<Player> team) {
    if (team.length < 2) return this;
    final updatedTeammates = <String, Set<String>>{};
    updatedTeammates.addAll(teammates.map((k, v) => MapEntry(k, {...v})));

    for (var i = 0; i < team.length; i++) {
      for (var j = i + 1; j < team.length; j++) {
        final playerA = team[i].id;
        final playerB = team[j].id;

        updatedTeammates.putIfAbsent(playerA, () => <String>{}).add(playerB);
        updatedTeammates.putIfAbsent(playerB, () => <String>{}).add(playerA);
      }
    }

    return DailyTeamHistory(date: date, teammates: updatedTeammates);
  }
}
