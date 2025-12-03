// ============== pages/statistics_page.dart ==============
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

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallStatsAsync = ref.watch(statisticsProvider);
    final dailyStatsAsync = ref.watch(dailyStatisticsProvider);
    final selectedDate = ref.watch(selectedStatisticsDateProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الإحصائيات',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          ),
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
            indicator: ModernTabIndicator(
              color: AppTheme.accentTeal,
              height: 3,
              radius: 2,
            ),
            tabs: const [
              Tab(text: 'عام'),
              Tab(text: 'يومي'),
              Tab(text: 'الابطال'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStatsTab(
              context: context,
              ref: ref,
              statsAsync: overallStatsAsync,
              emptyMessage: 'لا توجد إحصائيات\nقم بإضافة مباريات أولاً',
            ),
            _buildStatsTab(
              context: context,
              ref: ref,
              statsAsync: dailyStatsAsync,
              emptyMessage: 'لا توجد مباريات في هذا اليوم',
              header: _buildDateSelector(context, ref, selectedDate),
              rankByWins: true,
              filterBottomSheetBySelectedDate: true,
            ),
            _buildFirstPlaceTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab({
    required BuildContext context,
    required WidgetRef ref,
    required AsyncValue<List<PlayerStats>> statsAsync,
    required String emptyMessage,
    Widget? header,
    bool rankByWins = false,
    bool filterBottomSheetBySelectedDate = false,
  }) {
    return Column(
      children: [
        if (header != null) header,
        Expanded(
          child: statsAsync.when(
            data: (stats) {
              if (stats.isEmpty) {
                return Center(
                  child: EmptyState(
                    icon: Icons.bar_chart,
                    message: emptyMessage,
                  ),
                );
              }

              final ranks = _calculateRanks(stats, rankByWins: rankByWins);

              return ListView.builder(
                itemCount: stats.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  final rank = ranks[index];
                  return _buildStatCard(
                    context,
                    ref,
                    stat,
                    rank,
                    filterBottomSheetBySelectedDate,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('حدث خطأ: ${error.toString()}'),
                    ],
                  ),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFirstPlaceTab(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersProvider);
    final gamesAsync = ref.watch(gamesProvider);

    return playersAsync.when(
      data: (players) {
        if (players.isEmpty) {
          return Center(
            child: EmptyState(
              icon: Icons.emoji_events,
              message: 'لا يوجد لاعبون.',
            ),
          );
        }

        return gamesAsync.when(
            data: (games) {
              final statsService = ref.watch(statisticsServiceProvider);
              final firstPlaceStats = statsService.calculateFirstPlaceStats(
                players: players,
                games: games,
              );

              if (firstPlaceStats.isEmpty) {
                return Center(
                  child: EmptyState(
                    icon: Icons.emoji_events,
                    message: 'لا توجد إحصائيات.',
                  ),
                );
              }

              return ListView.builder(
                itemCount: firstPlaceStats.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final stat = firstPlaceStats[index];
                  return _buildFirstPlaceCard(stat);
                },
              );
            },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, _) => Center(child: Text('حدث خطأ: ${error.toString()}')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('حدث خطأ: ${error.toString()}')),
    );
  }

  Card _buildFirstPlaceCard(FirstPlaceStats stat) {
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                    return AnimatedTrophy(
                      index: index,
                      isShared: isShared,
                      date: date,
                    );
                  }),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stat.firstPlaceCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    WidgetRef ref,
    PlayerStats stat,
    int rank,
    bool filterBottomSheetBySelectedDate,
  ) {
    return AnimatedCard(
      onTap: () => _showPlayerDetailsBottomSheet(
        context,
        ref,
        stat.playerId,
        filterBottomSheetBySelectedDate,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rank badge
            CircleAvatar(
              backgroundColor: AppTheme.getRankColor(rank),
              radius: 20,
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stat.name,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'خسائر: ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      AnimatedCounter(
                        value: stat.lost,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      Text(
                        ' • انتصارات: ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      AnimatedCounter(
                        value: stat.won,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Win rate badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.getWinRateColor(stat.winRate),
                    AppTheme.getWinRateColor(
                      stat.winRate,
                    ).withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getWinRateColor(
                      stat.winRate,
                    ).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedPercentage(
                value: stat.winRate,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    final formattedDate = intl.DateFormat('yyyy/MM/dd').format(selectedDate);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'التاريخ المحدد: $formattedDate',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () => _selectDate(context, ref, selectedDate),
            icon: const Icon(Icons.calendar_today),
            label: const Text('اختر تاريخ'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    WidgetRef ref,
    DateTime initialDate,
  ) async {
    final firstDate = _resolveEarliestGameDate(ref) ?? DateTime(2000);
    final lastDate = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate.isAfter(lastDate) ? lastDate : firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      ref.read(selectedStatisticsDateProvider.notifier).state = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
    }
  }

  DateTime? _resolveEarliestGameDate(WidgetRef ref) {
    return ref
        .read(gamesProvider)
        .maybeWhen(
          data: (games) {
            if (games.isEmpty) {
              return null;
            }
            return games
                .map((game) => game.date.toLocal())
                .reduce(
                  (value, element) => value.isBefore(element) ? value : element,
                );
          },
          orElse: () => null,
        )
        ?.toLocal();
  }

  List<int> _calculateRanks(List<PlayerStats> stats, {bool rankByWins = false}) {
    final ranks = <int>[];
    int? previousWins;
    int? previousPercentage;
    var uniqueRank = 0;

    for (var i = 0; i < stats.length; i++) {
      final currentPercentage = stats[i].winRate.round();
      final currentWins = stats[i].won;
      final isSameRank = rankByWins
          ? previousWins != null &&
              currentWins == previousWins &&
              currentPercentage == previousPercentage
          : previousPercentage != null && currentPercentage == previousPercentage;
      final rank = isSameRank ? uniqueRank : ++uniqueRank;

      ranks.add(rank);
      previousWins = currentWins;
      previousPercentage = currentPercentage;
    }

    return ranks;
  }

  void _showPlayerDetailsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String playerId,
    bool filterBySelectedDate,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder:
                  (context, scrollController) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.95),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: _PlayerDetailsBottomSheet(
                      playerId: playerId,
                      filterBySelectedDate: filterBySelectedDate,
                      scrollController: scrollController,
                    ),
                  ),
            ),
          ),
    );
  }
}

class _PlayerDetailsBottomSheet extends ConsumerWidget {
  final String playerId;
  final bool filterBySelectedDate;
  final ScrollController scrollController;

  const _PlayerDetailsBottomSheet({
    required this.playerId,
    required this.filterBySelectedDate,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersProvider);
    final gamesAsync = ref.watch(gamesProvider);
    final selectedDate = filterBySelectedDate
        ? ref.watch(selectedStatisticsDateProvider)
        : null;

    return playersAsync.when(
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TabBar(
                labelColor: AppTheme.primaryPurple,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                indicator: ModernTabIndicator(
                  color: AppTheme.accentTeal,
                  height: 3,
                  radius: 2,
                ),
                tabs: const [
                  Tab(text: 'خصوم'),
                  Tab(text: 'شركاء'),
                  Tab(text: 'لعبات'),
                ],
              ),
              Expanded(
                child: gamesAsync.when(
                  data:
                      (games) {
                        final relevantGames =
                            filterBySelectedDate && selectedDate != null
                                ? games
                                    .where(
                                      (game) => DateUtils.isSameDay(
                                        game.date.toLocal(),
                                        selectedDate.toLocal(),
                                      ),
                                    )
                                    .toList()
                                : games;

                        return TabBarView(
                          children: [
                            _buildAgainstTab(ref, players, relevantGames),
                            _buildWithTab(ref, players, relevantGames),
                            _buildGamesTab(ref, players, relevantGames),
                          ],
                        );
                      },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('خطأ: $error')),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('خطأ: $error')),
    );
  }

  Widget _buildAgainstTab(
    WidgetRef ref,
    List<Player> players,
    List<Game> games,
  ) {
    final statsService = ref.watch(statisticsServiceProvider);
    final headToHeadStats = statsService.calculateHeadToHeadStats(
      playerId: playerId,
      players: players,
      games: games,
    );

    if (headToHeadStats.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.sports_kabaddi,
          message: 'لا توجد مواجهات مسجلة',
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: headToHeadStats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final stat = headToHeadStats[index];
          return Card(
            elevation: 2,
            child: ListTile(
              title: Text(
                stat.opponentName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('فوز: ${stat.won} • خسارة: ${stat.lost}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getWinRateColor(stat.winRate),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stat.winRateText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWithTab(WidgetRef ref, List<Player> players, List<Game> games) {
    final statsService = ref.watch(statisticsServiceProvider);
    final teammateStats = statsService.calculateTeammateStats(
      playerId: playerId,
      players: players,
      games: games,
    );

    if (teammateStats.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.handshake,
          message: 'لا توجد احصائيات شركاء',
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: teammateStats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final stat = teammateStats[index];
          return Card(
            elevation: 2,
            child: ListTile(
              title: Text(
                stat.teammateName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('فوز: ${stat.won} • خسارة: ${stat.lost}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getWinRateColor(stat.winRate),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stat.winRateText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGamesTab(WidgetRef ref, List<Player> players, List<Game> games) {
    final statsService = ref.watch(statisticsServiceProvider);
    final playerGames = statsService.getPlayerGames(
      playerId: playerId,
      games: games,
    );

    if (playerGames.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.sports_esports,
          message: 'لا توجد لعبات مسجلة',
        ),
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
          final team1Player1Name = playerMap[game.team1Player1] ?? '';
          final team1Player2Name = playerMap[game.team1Player2] ?? '';
          final team2Player1Name = playerMap[game.team2Player1] ?? '';
          final team2Player2Name = playerMap[game.team2Player2] ?? '';

          final isPlayerInTeam1 =
              game.team1Player1 == playerId || game.team1Player2 == playerId;
          final didWin =
              (isPlayerInTeam1 && game.winningTeam == 1) ||
              (!isPlayerInTeam1 && game.winningTeam == 2);

          final formattedDate = intl.DateFormat('yyyy/MM/dd').format(game.date);

          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        didWin ? Icons.check_circle : Icons.cancel,
                        color: didWin ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                game.winningTeam == 1
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isPlayerInTeam1
                                      ? Colors.purple
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                team1Player1Name,
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                team1Player2Name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'VS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                game.winningTeam == 2
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  !isPlayerInTeam1
                                      ? Colors.purple
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                team2Player1Name,
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                team2Player2Name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
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
}
