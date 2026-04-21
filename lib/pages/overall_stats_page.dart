// ============== pages/overall_stats_page.dart ==============
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../models/game.dart';
import '../models/player.dart';
import '../models/player_stats.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/animated_card.dart';
import '../widgets/animations/animated_counter.dart';
import '../widgets/animations/animated_trophy.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/modern_tab_indicator.dart';
import '../widgets/games_list_body.dart';

class OverallStatsPage extends ConsumerWidget {
  const OverallStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الإحصائيات العامة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentTeal, Color(0xFF26C6DA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 15),
            indicator: ModernTabIndicator(color: Colors.white, height: 3, radius: 2),
            tabs: const [
              Tab(text: 'الترتيب'),
              Tab(text: 'الأبطال'),
              Tab(text: 'المباريات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverallRankingTab(),
            _OverallCupsTab(),
            const GamesListBody(),
          ],
        ),
      ),
    );
  }
}

// ── Tab 1: Overall Ranking ────────────────────────────────────────────────────

class _OverallRankingTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats.isEmpty) {
          return const Center(
            child: EmptyState(
              icon: Icons.bar_chart,
              message: 'لا توجد إحصائيات\nقم بإضافة مباريات أولاً',
            ),
          );
        }
        return _buildOverallList(context, ref, stats);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('حدث خطأ: $e')),
    );
  }

  Widget _buildOverallList(BuildContext context, WidgetRef ref, List<PlayerStats> stats) {
    final totalPlayed = stats.fold(0, (sum, s) => sum + s.played);
    final threshold = stats.isNotEmpty ? (totalPlayed / stats.length / 2).floor() : 0;

    final qualified = stats.where((s) => s.played >= threshold).toList();
    final belowThreshold = stats.where((s) => s.played < threshold).toList()
      ..sort((a, b) => b.played.compareTo(a.played));

    final ranks = _calculateRanks(qualified);
    final hasBelowSection = belowThreshold.isNotEmpty;
    final totalItems = qualified.length + (hasBelowSection ? 1 + belowThreshold.length : 0);

    return ListView.builder(
      itemCount: totalItems,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        if (index < qualified.length) {
          return _StatCard(
            stat: qualified[index],
            rank: ranks[index],
            onTap: () => _showPlayerDetails(context, ref, qualified[index].playerId),
          );
        }
        if (index == qualified.length) return _BelowThresholdHeader();
        final s = belowThreshold[index - qualified.length - 1];
        return _BelowThresholdCard(
          stat: s,
          threshold: threshold,
          onTap: () => _showPlayerDetails(context, ref, s.playerId),
        );
      },
    );
  }

  List<int> _calculateRanks(List<PlayerStats> stats) {
    final ranks = <int>[];
    int? prevDiff;
    var uniqueRank = 0;
    for (var s in stats) {
      final same = prevDiff != null && s.diff == prevDiff;
      ranks.add(same ? uniqueRank : ++uniqueRank);
      prevDiff = s.diff;
    }
    return ranks;
  }

  void _showPlayerDetails(BuildContext context, WidgetRef ref, String playerId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => _PlayerDetailsSheet(
            playerId: playerId,
            scrollController: scrollController,
          ),
        ),
      ),
    );
  }
}

// ── Tab 2: Overall Cups ───────────────────────────────────────────────────────

class _OverallCupsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersProvider);
    final gamesAsync = ref.watch(gamesProvider);

    return playersAsync.when(
      data: (players) {
        if (players.isEmpty) {
          return const Center(
            child: EmptyState(icon: Icons.emoji_events, message: 'لا يوجد لاعبون.'),
          );
        }
        return gamesAsync.when(
          data: (games) {
            final service = ref.watch(statisticsServiceProvider);
            final cups = service.calculateFirstPlaceStats(players: players, games: games);
            if (cups.isEmpty) {
              return const Center(
                child: EmptyState(icon: Icons.emoji_events, message: 'لا توجد إحصائيات.'),
              );
            }
            return ListView.builder(
              itemCount: cups.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) =>
                  _CupCard(stat: cups[index], onCupTap: (date) {
                    _showOverallSnapshot(context, ref, players, games, date);
                  }),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('حدث خطأ: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('حدث خطأ: $e')),
    );
  }

  void _showOverallSnapshot(
    BuildContext context,
    WidgetRef ref,
    List<Player> players,
    List<Game> games,
    DateTime date,
  ) {
    final service = ref.read(statisticsServiceProvider);
    final stats = service.calculateStatsUpToDate(players: players, games: games, date: date);
    final label = intl.DateFormat('yyyy/MM/dd').format(date);
    _showStandingSheet(context, 'الترتيب حتى $label', stats);
  }
}

// ── Standing snapshot bottom sheet ───────────────────────────────────────────

void _showStandingSheet(BuildContext context, String title, List<PlayerStats> stats) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: stats.length,
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  final rank = index + 1;
                  return _StatCard(stat: stat, rank: rank, onTap: null);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final PlayerStats stat;
  final int rank;
  final VoidCallback? onTap;

  const _StatCard({required this.stat, required this.rank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.getRankColor(rank),
            radius: 20,
            child: Text(
              '$rank',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stat.name,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(stat.winRateText, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    Text(' • خسائر: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    AnimatedCounter(value: stat.lost, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    Text(' • انتصارات: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    AnimatedCounter(value: stat.won, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.getDiffColor(stat.diff),
                  AppTheme.getDiffColor(stat.diff).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getDiffColor(stat.diff).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              stat.diffText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: child,
      );
    }
    return AnimatedCard(onTap: onTap!, child: child);
  }
}

class _BelowThresholdHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.warningOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningOrange.withValues(alpha: 0.4)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: AppTheme.warningOrange, size: 18),
          SizedBox(width: 8),
          Text(
            'لاعبون بمباريات غير كافية',
            style: TextStyle(color: AppTheme.warningOrange, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _BelowThresholdCard extends StatelessWidget {
  final PlayerStats stat;
  final int threshold;
  final VoidCallback onTap;

  const _BelowThresholdCard({required this.stat, required this.threshold, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.65,
      child: AnimatedCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[400],
                radius: 20,
                child: const Icon(Icons.hourglass_bottom, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(stat.name, textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      'لعب ${stat.played} فقط من أصل $threshold مباراة',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: AppTheme.warningOrange, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CupCard extends StatelessWidget {
  final FirstPlaceStats stat;
  final void Function(DateTime date) onCupTap;

  const _CupCard({required this.stat, required this.onCupTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  stat.name,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                flex: 3,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(stat.firstPlaceCount, (index) {
                    final date = stat.cupDates[index];
                    final dateKey =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    final isShared = stat.sharedCupDates.contains(dateKey);
                    return GestureDetector(
                      onTap: () => onCupTap(date),
                      child: AnimatedTrophy(index: index, isShared: isShared, date: date),
                    );
                  }),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stat.firstPlaceCount}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Player details bottom sheet ───────────────────────────────────────────────

class _PlayerDetailsSheet extends ConsumerWidget {
  final String playerId;
  final ScrollController scrollController;

  const _PlayerDetailsSheet({required this.playerId, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersProvider);
    final gamesAsync = ref.watch(gamesProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: playersAsync.when(
        data: (players) {
          final player = players.firstWhere(
            (p) => p.id == playerId,
            orElse: () => players.first,
          );
          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    player.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                TabBar(
                  labelColor: AppTheme.primaryPurple,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 14),
                  indicator: ModernTabIndicator(color: AppTheme.accentTeal, height: 3, radius: 2),
                  tabs: const [Tab(text: 'خصوم'), Tab(text: 'شركاء'), Tab(text: 'لعبات')],
                ),
                Expanded(
                  child: gamesAsync.when(
                    data: (games) => TabBarView(
                      children: [
                        _buildAgainstTab(ref, players, games),
                        _buildWithTab(ref, players, games),
                        _buildGamesTab(ref, players, games),
                      ],
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('خطأ: $e')),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Widget _buildAgainstTab(WidgetRef ref, List<Player> players, List<Game> games) {
    final service = ref.watch(statisticsServiceProvider);
    final stats = service.calculateHeadToHeadStats(playerId: playerId, players: players, games: games);
    if (stats.isEmpty) {
      return const Center(
        child: EmptyState(icon: Icons.sports_kabaddi, message: 'لا توجد مواجهات مسجلة'),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final s = stats[index];
          return Card(
            elevation: 2,
            child: ListTile(
              title: Text(s.opponentName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('فوز: ${s.won} • خسارة: ${s.lost} • ${s.winRateText}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.getDiffColor(s.diff),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(s.diffText,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWithTab(WidgetRef ref, List<Player> players, List<Game> games) {
    final service = ref.watch(statisticsServiceProvider);
    final stats = service.calculateTeammateStats(playerId: playerId, players: players, games: games);
    if (stats.isEmpty) {
      return const Center(
        child: EmptyState(icon: Icons.handshake, message: 'لا توجد احصائيات شركاء'),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final s = stats[index];
          return Card(
            elevation: 2,
            child: ListTile(
              title: Text(s.teammateName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('فوز: ${s.won} • خسارة: ${s.lost} • ${s.winRateText}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.getDiffColor(s.diff),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(s.diffText,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGamesTab(WidgetRef ref, List<Player> players, List<Game> games) {
    final service = ref.watch(statisticsServiceProvider);
    final playerGames = service.getPlayerGames(playerId: playerId, games: games);
    if (playerGames.isEmpty) {
      return const Center(
        child: EmptyState(icon: Icons.sports_esports, message: 'لا توجد لعبات مسجلة'),
      );
    }
    final playerMap = {for (var p in players) p.id: p.name};
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: playerGames.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final game = playerGames[index];
          final formatted = intl.DateFormat('yyyy/MM/dd').format(game.date);
          final isInTeam1 = game.team1Player1 == playerId || game.team1Player2 == playerId;
          final team1Won = game.winningTeam == 1;
          final team2Won = game.winningTeam == 2;
          final playerWon = isInTeam1 ? team1Won : team2Won;
          return Card(
            elevation: 2,
            color: playerWon ? Colors.green.shade50 : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatted,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _teamBox(
                        [playerMap[game.team1Player1] ?? '', playerMap[game.team1Player2] ?? ''],
                        isWinner: team1Won,
                        isPlayerTeam: isInTeam1,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      _teamBox(
                        [playerMap[game.team2Player1] ?? '', playerMap[game.team2Player2] ?? ''],
                        isWinner: team2Won,
                        isPlayerTeam: !isInTeam1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _teamBox(List<String> names, {required bool isWinner, required bool isPlayerTeam}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isWinner ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isWinner ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: names
              .map((n) => Text(n, style: const TextStyle(fontSize: 12)))
              .toList(),
        ),
      ),
    );
  }
}
