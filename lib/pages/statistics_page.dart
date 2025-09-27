// ============== pages/statistics_page.dart ==============
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final storage = StorageService();
  List<_PlayerStats> stats = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final players = await storage.getPlayers();
    final games = await storage.getGames();

    Map<String, _PlayerStats> statsMap = {};

    for (var player in players) {
      statsMap[player.id] = _PlayerStats(name: player.name, played: 0, won: 0);
    }

    for (var game in games) {
      statsMap[game.team1Player1]!.played++;
      statsMap[game.team1Player2]!.played++;
      statsMap[game.team2Player1]!.played++;
      statsMap[game.team2Player2]!.played++;

      if (game.winningTeam == 1) {
        statsMap[game.team1Player1]!.won++;
        statsMap[game.team1Player2]!.won++;
      } else {
        statsMap[game.team2Player1]!.won++;
        statsMap[game.team2Player2]!.won++;
      }
    }

    stats = statsMap.values.toList();
    stats.sort((a, b) => b.winRate.compareTo(a.winRate));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body:
          stats.isEmpty
              ? const Center(
                child: Text('لا توجد إحصائيات', style: TextStyle(fontSize: 18, color: Colors.grey)),
              )
              : ListView.builder(
                itemCount: stats.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: ListTile(
                      title: Text(
                        stat.name,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      trailing: Text(
                        '${stat.won}/${stat.played}  (${stat.winRateText})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class _PlayerStats {
  final String name;
  int played;
  int won;

  _PlayerStats({required this.name, required this.played, required this.won});

  double get winRate => played > 0 ? (won / played * 100) : 0;
  String get winRateText => '${winRate.toStringAsFixed(0)}%';
}
