// ============== pages/games_history_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/player.dart';
import '../providers/providers.dart';
import 'new_game_page.dart';

class GamesHistoryPage extends ConsumerStatefulWidget {
  const GamesHistoryPage({super.key});

  @override
  ConsumerState<GamesHistoryPage> createState() => _GamesHistoryPageState();
}

class _GamesHistoryPageState extends ConsumerState<GamesHistoryPage> {
  String? _selectedPlayerId; // Add filter state

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
  Widget build(BuildContext context) {
    // FIXED: Removed 'WidgetRef ref'
    final gamesAsync = ref.watch(gamesProvider);
    final playersAsync = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المباريات'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter dropdown
          playersAsync.when(
            data: (players) {
              if (players.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange.shade50,
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'تصفية حسب اللاعب',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        initialValue: _selectedPlayerId,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('الكل'),
                          ),
                          ...players.map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPlayerId = value;
                          });
                        },
                      ),
                    ),
                    if (_selectedPlayerId != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedPlayerId = null;
                          });
                        },
                        tooltip: 'إلغاء التصفية',
                      ),
                    ],
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Games list
          Expanded(
            child: gamesAsync.when(
              data: (allGames) {
                // Apply filter
                final games =
                    _selectedPlayerId == null
                        ? allGames
                        : allGames.where((game) {
                          return game.team1Player1 == _selectedPlayerId ||
                              game.team1Player2 == _selectedPlayerId ||
                              game.team2Player1 == _selectedPlayerId ||
                              game.team2Player2 == _selectedPlayerId;
                        }).toList();

                if (games.isEmpty) {
                  return Center(
                    child: Text(
                      _selectedPlayerId == null
                          ? 'لا توجد مباريات\nقم بإضافة مباراة جديدة'
                          : 'لا توجد مباريات لهذا اللاعب',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return playersAsync.when(
                  data:
                      (players) => ListView.builder(
                        itemCount: games.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final game = games[index];

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
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => NewGamePage(
                                                    gameToEdit: game,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => _deleteGame(
                                              context,
                                              ref,
                                              game.id,
                                            ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // Team 2
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      game.winningTeam == 2
                                                          ? Colors.green
                                                              .withValues(
                                                                alpha: 0.1,
                                                              )
                                                          : Colors.grey
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color:
                                                        game.winningTeam == 2
                                                            ? Colors.green
                                                            : Colors
                                                                .transparent,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      _getPlayerName(
                                                        players,
                                                        game.team2Player1,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      _getPlayerName(
                                                        players,
                                                        game.team2Player2,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                              child: Text(
                                                'VS',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            // Team 1
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      game.winningTeam == 1
                                                          ? Colors.green
                                                              .withValues(
                                                                alpha: 0.1,
                                                              )
                                                          : Colors.grey
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color:
                                                        game.winningTeam == 1
                                                            ? Colors.green
                                                            : Colors
                                                                .transparent,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      _getPlayerName(
                                                        players,
                                                        game.team1Player1,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      _getPlayerName(
                                                        players,
                                                        game.team1Player2,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
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
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stack) =>
                          Center(child: Text('خطأ: ${error.toString()}')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) =>
                      Center(child: Text('خطأ: ${error.toString()}')),
            ),
          ),
        ],
      ),
    );
  }
}
