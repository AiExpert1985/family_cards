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

  Future<void> _deleteGame(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
            content: const Text(
              'هل تريد حذف هذه المباراة؟',
              textAlign: TextAlign.right,
            ),
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
          const SnackBar(
            content: Text('تم حذف المباراة بنجاح'),
            backgroundColor: Colors.orange,
          ),
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
                    final score = game.winningTeam == 1 ? '1-0' : '0-1';

                    return Card(
                      elevation: game.isKonkan ? 4 : 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      color: game.isKonkan ? Colors.amber.shade50 : null,
                      shape:
                          game.isKonkan
                              ? RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.amber.shade600,
                                  width: 2,
                                ),
                              )
                              : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Konkan badge if applicable
                            if (game.isKonkan) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber.shade700,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'كونكان',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Main row: Team 1 - Score - Team 2
                            Row(
                              children: [
                                // Delete button on the left
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => _deleteGame(context, ref, game.id),
                                ),

                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Team 1 players (should be on the RIGHT in RTL)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _getPlayerName(
                                              players,
                                              game.team1Player1,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            _getPlayerName(
                                              players,
                                              game.team1Player2,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(width: 12),

                                      // Score
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          score,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      // Team 2 players (should be on the LEFT in RTL)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _getPlayerName(
                                              players,
                                              game.team2Player1,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            _getPlayerName(
                                              players,
                                              game.team2Player2,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Date below
                            Text(
                              DateFormat('yyyy/MM/dd').format(game.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) =>
                    Center(child: Text('خطأ: ${error.toString()}')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(child: Text('خطأ: ${error.toString()}')),
      ),
    );
  }
}
