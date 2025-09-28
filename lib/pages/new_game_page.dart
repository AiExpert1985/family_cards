// ============== pages/new_game_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../providers/providers.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/app_card.dart';

class NewGamePage extends ConsumerStatefulWidget {
  const NewGamePage({super.key});

  @override
  ConsumerState<NewGamePage> createState() => _NewGamePageState();
}

class _NewGamePageState extends ConsumerState<NewGamePage> {
  String? t1p1, t1p2, t2p1, t2p2;
  int? winningTeam;
  bool _isSaving = false;

  Future<void> _saveGame() async {
    if (t1p1 == null || t1p2 == null || t2p1 == null || t2p2 == null || winningTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    final game = Game(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      team1Player1: t1p1!,
      team1Player2: t1p2!,
      team2Player1: t2p1!,
      team2Player2: t2p2!,
      winningTeam: winningTeam!,
    );

    final success = await ref.read(gamesProvider.notifier).addGame(game);

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ اللعبة بنجاح'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لعبة جديدة'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: playersAsync.when(
        data: (players) {
          if (players.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              message: 'قم بإضافة اللاعبين أولاً',
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _TeamCard(
                      title: 'الفريق الأول',
                      color: Colors.blue,
                      players: players,
                      player1: t1p1,
                      player2: t1p2,
                      onPlayer1Changed: (v) => setState(() => t1p1 = v),
                      onPlayer2Changed: (v) => setState(() => t1p2 = v),
                    ),
                    const SizedBox(height: 20),
                    _TeamCard(
                      title: 'الفريق الثاني',
                      color: Colors.red,
                      players: players,
                      player1: t2p1,
                      player2: t2p2,
                      onPlayer1Changed: (v) => setState(() => t2p1 = v),
                      onPlayer2Changed: (v) => setState(() => t2p2 = v),
                    ),
                    const SizedBox(height: 24),
                    AppCard(
                      child: Column(
                        children: [
                          const Text(
                            'الفريق الفائز',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => winningTeam = 1),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        winningTeam == 1 ? Colors.blue : Colors.grey.shade300,
                                    foregroundColor: winningTeam == 1 ? Colors.white : Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('الفريق الأول'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => winningTeam = 2),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        winningTeam == 2 ? Colors.red : Colors.grey.shade300,
                                    foregroundColor: winningTeam == 2 ? Colors.white : Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('الفريق الثاني'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child:
                            _isSaving
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('حفظ اللعبة', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطأ: ${error.toString()}')),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<Player> players;
  final String? player1;
  final String? player2;
  final ValueChanged<String?> onPlayer1Changed;
  final ValueChanged<String?> onPlayer2Changed;

  const _TeamCard({
    required this.title,
    required this.color,
    required this.players,
    required this.player1,
    required this.player2,
    required this.onPlayer1Changed,
    required this.onPlayer2Changed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'اللاعب الأول',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              value: player1,
              items:
                  players.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
              onChanged: onPlayer1Changed,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'اللاعب الثاني',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              value: player2,
              items:
                  players.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
              onChanged: onPlayer2Changed,
            ),
          ],
        ),
      ),
    );
  }
}
