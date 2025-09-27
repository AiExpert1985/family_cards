// ============== pages/games_history_page.dart ==============
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../services/storage_service.dart';

class GamesHistoryPage extends StatefulWidget {
  const GamesHistoryPage({super.key});

  @override
  State<GamesHistoryPage> createState() => _GamesHistoryPageState();
}

class _GamesHistoryPageState extends State<GamesHistoryPage> {
  final storage = StorageService();
  List<Game> games = [];
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    games = await storage.getGames();
    players = await storage.getPlayers();
    games.sort((a, b) => b.date.compareTo(a.date));
    setState(() {});
  }

  String _getPlayerName(String id) =>
      players.firstWhere((p) => p.id == id, orElse: () => Player(id: '', name: 'غير معروف')).name;

  Future<void> _deleteGame(String id) async {
    games.removeWhere((g) => g.id == id);
    await storage.saveGames(games);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المباريات'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body:
          games.isEmpty
              ? const Center(
                child: Text('لا توجد مباريات', style: TextStyle(fontSize: 18, color: Colors.grey)),
              )
              : ListView.builder(
                itemCount: games.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final game = games[index];
                  final team1 =
                      '${_getPlayerName(game.team1Player1)} و ${_getPlayerName(game.team1Player2)}';
                  final team2 =
                      '${_getPlayerName(game.team2Player1)} و ${_getPlayerName(game.team2Player2)}';
                  final score = game.winningTeam == 1 ? '1-0' : '0-1';

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$team1  $score  $team2',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('yyyy/MM/dd - HH:mm').format(game.date),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteGame(game.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
