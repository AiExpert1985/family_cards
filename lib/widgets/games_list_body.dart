// ============== widgets/games_list_body.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/player.dart';
import '../providers/providers.dart';
import '../pages/new_game_page.dart';

class GamesListBody extends ConsumerWidget {
  final DateTime? filterDate;

  const GamesListBody({super.key, this.filterDate});

  bool get _isFiltered => filterDate != null;

  String _getPlayerName(List<Player> players, String id) {
    try {
      return players.firstWhere((p) => p.id == id).name;
    } catch (_) {
      return 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);
    final playersAsync = ref.watch(playersProvider);

    return gamesAsync.when(
      data: (allGames) {
        var games = allGames;

        if (_isFiltered) {
          final fd = filterDate!.toLocal();
          games = allGames.where((g) {
            final gd = g.date.toLocal();
            return gd.year == fd.year && gd.month == fd.month && gd.day == fd.day;
          }).toList();
        }

        if (games.isEmpty) {
          return Center(
            child: Text(
              _isFiltered ? 'لا توجد مباريات في هذا اليوم' : 'لا توجد مباريات',
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
                _GameCard(game: games[index], players: players, getPlayerName: _getPlayerName),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }
}

class _GameCard extends ConsumerWidget {
  final dynamic game;
  final List<Player> players;
  final String Function(List<Player>, String) getPlayerName;

  const _GameCard({required this.game, required this.players, required this.getPlayerName});

  Future<void> _deleteGame(BuildContext context, WidgetRef ref) async {
    await ref.read(gamesProvider.notifier).deleteGame(game.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حذف المباراة'),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () async {
              await ref.read(gamesProvider.notifier).addGame(game);
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _editGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewGamePage(gameToEdit: game)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(game.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteGame(context, ref),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onLongPress: () => _editGame(context),
        child: _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
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
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildTeamBox(
                        names: [
                          getPlayerName(players, game.team2Player1),
                          getPlayerName(players, game.team2Player2),
                        ],
                        isWinner: game.winningTeam == 2,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      _buildTeamBox(
                        names: [
                          getPlayerName(players, game.team1Player1),
                          getPlayerName(players, game.team1Player2),
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
