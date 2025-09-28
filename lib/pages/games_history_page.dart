// ============== pages/games_history_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/player.dart';
import '../widgets/common/empty_state.dart';

class GamesHistoryPage extends ConsumerWidget {
  const GamesHistoryPage({super.key});

  String _getPlayerName(List<Player> players, String id) {
    try {
      return players.firstWhere((p) => p.id == id).name;
    } catch (e) {
      return 'غير معروف';
    }
  }

  Future<void> _deleteGame(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
            content: const Text('هل تريد حذف هذه المباراة؟', textAlign: TextAlign.right),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
    );

    if (confirm == true && context.mounted) {
      final success = await ref.read(gamesProvider.notifier).deleteGame(id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المباراة بنجاح'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);
    final playersAsync = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المباريات'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: gamesAsync.when(
        data: (games) {
          if (games.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              message: 'لا توجد مباريات\nقم بإضافة مباراة جديدة',
            );
          }

          return playersAsync.when(
            data:
                (players) => ListView.builder(
                  itemCount: games.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final game = games[index];
                    final team1 =
                        '${_getPlayerName(players, game.team1Player1)} و ${_getPlayerName(players, game.team1Player2)}';
                    final team2 =
                        '${_getPlayerName(players, game.team2Player1)} و ${_getPlayerName(players, game.team2Player2)}';
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
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                              onPressed: () => _deleteGame(context, ref, game.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('خطأ: ${error.toString()}')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('خطأ: ${error.toString()}')),
      ),
    );
  }
}
