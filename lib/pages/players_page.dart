// ============== pages/players_page.dart ==============
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/storage_service.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final storage = StorageService();
  List<Player> players = [];
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    players = await storage.getPlayers();
    setState(() {});
  }

  Future<void> _addPlayer() async {
    if (controller.text.trim().isEmpty) return;
    players.add(Player(id: DateTime.now().toString(), name: controller.text.trim()));
    await storage.savePlayers(players);
    controller.clear();
    setState(() {});
  }

  Future<void> _deletePlayer(String id) async {
    players.removeWhere((p) => p.id == id);
    await storage.savePlayers(players);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة اللاعبين'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: 'اسم اللاعب',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addPlayer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('إضافة'),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                players.isEmpty
                    ? const Center(
                      child: Text(
                        'لا يوجد لاعبين',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: players.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final player = players[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            title: Text(
                              player.name,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePlayer(player.id),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
