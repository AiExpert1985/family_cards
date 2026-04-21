// ============== widgets/games_list_body.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/player.dart';
import '../providers/providers.dart';
import '../pages/new_game_page.dart';

class GamesListBody extends ConsumerStatefulWidget {
  final DateTime? filterDate;

  const GamesListBody({super.key, this.filterDate});

  @override
  ConsumerState<GamesListBody> createState() => _GamesListBodyState();
}

class _GamesListBodyState extends ConsumerState<GamesListBody> {
  String? _selectedPlayerId;

  bool get _isFiltered => widget.filterDate != null;

  String _getPlayerName(List<Player> players, String id) {
    try {
      return players.firstWhere((p) => p.id == id).name;
    } catch (_) {
      return 'غير معروف';
    }
  }

  Future<void> _deleteGame(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
        content: const Text('هل تريد حذف هذه المباراة؟', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(gamesProvider.notifier).deleteGame(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(gamesProvider);
    final playersAsync = ref.watch(playersProvider);

    return Column(
      children: [
        if (!_isFiltered)
          _buildHeader(context, playersAsync),
        Expanded(
          child: gamesAsync.when(
            data: (allGames) {
              var games = allGames;

              if (_isFiltered) {
                final fd = widget.filterDate!.toLocal();
                games = allGames.where((g) {
                  final gd = g.date.toLocal();
                  return gd.year == fd.year && gd.month == fd.month && gd.day == fd.day;
                }).toList();
              } else if (_selectedPlayerId != null) {
                games = allGames.where((g) =>
                  g.team1Player1 == _selectedPlayerId ||
                  g.team1Player2 == _selectedPlayerId ||
                  g.team2Player1 == _selectedPlayerId ||
                  g.team2Player2 == _selectedPlayerId,
                ).toList();
              }

              if (games.isEmpty) {
                return Center(
                  child: Text(
                    _isFiltered
                        ? 'لا توجد مباريات في هذا اليوم'
                        : _selectedPlayerId != null
                            ? 'لا توجد مباريات لهذا اللاعب'
                            : 'لا توجد مباريات\nقم بإضافة مباراة جديدة',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return playersAsync.when(
                data: (players) => ListView.builder(
                  itemCount: games.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) =>
                      _buildGameCard(context, games[index], players),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('خطأ: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue playersAsync) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.orange, size: 28),
                tooltip: 'إضافة مباراة جديدة',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewGamePage()),
                ),
              ),
              const Spacer(),
              const Text(
                'سجل المباريات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        playersAsync.maybeWhen(
          data: (players) {
            if ((players as List).isEmpty) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  if (_selectedPlayerId != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _selectedPlayerId = null),
                      tooltip: 'إلغاء التصفية',
                    ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'تصفية حسب اللاعب',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      initialValue: _selectedPlayerId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('الكل')),
                        ...(players as List<Player>).map(
                          (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                        ),
                      ],
                      onChanged: (value) => setState(() => _selectedPlayerId = value),
                    ),
                  ),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, dynamic game, List<Player> players) {
    return Card(
      elevation: game.isKonkan ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: game.isKonkan ? Colors.amber.shade50 : null,
      shape: game.isKonkan
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.amber.shade600, width: 2),
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
                  Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 18),
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
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NewGamePage(gameToEdit: game)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteGame(game.id),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildTeamBox(
                        names: [
                          _getPlayerName(players, game.team2Player1),
                          _getPlayerName(players, game.team2Player2),
                        ],
                        isWinner: game.winningTeam == 2,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      _buildTeamBox(
                        names: [
                          _getPlayerName(players, game.team1Player1),
                          _getPlayerName(players, game.team1Player2),
                        ],
                        isWinner: game.winningTeam == 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('yyyy/MM/dd').format(game.date),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamBox({required List<String> names, required bool isWinner}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isWinner
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isWinner ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: names
              .map((n) => Text(n, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))
              .toList(),
        ),
      ),
    );
  }
}
