// ============== pages/statistics_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player_stats.dart';
import '../providers/providers.dart';
import '../widgets/common/empty_state.dart';
import 'package:intl/intl.dart' as intl;

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallStatsAsync = ref.watch(statisticsProvider);
    final dailyStatsAsync = ref.watch(dailyStatisticsProvider);
    final selectedDate = ref.watch(selectedStatisticsDateProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإحصائيات'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.amber,
            tabs: [Tab(text: 'عام'), Tab(text: 'يومي'), Tab(text: 'لاعبين'), Tab(text: 'المركز الأول')],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStatsTab(
              statsAsync: overallStatsAsync,
              emptyMessage: 'لا توجد إحصائيات\nقم بإضافة مباريات أولاً',
            ),
            _buildStatsTab(
              statsAsync: dailyStatsAsync,
              emptyMessage: 'لا توجد مباريات في هذا اليوم',
              header: _buildDateSelector(context, ref, selectedDate),
            ),
            _buildHeadToHeadTab(context, ref),
            _buildFirstPlaceTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab({
    required AsyncValue<List<PlayerStats>> statsAsync,
    required String emptyMessage,
    Widget? header,
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

              final ranks = _calculateRanks(stats);

              return ListView.builder(
                itemCount: stats.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  final rank = ranks[index];
                  return _buildStatCard(stat, rank);
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

  Widget _buildHeadToHeadTab(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersProvider);
    final gamesAsync = ref.watch(gamesProvider);
    final selectedPlayerId = ref.watch(selectedHeadToHeadPlayerProvider);

    return playersAsync.when(
      data: (players) {
        if (players.isEmpty) {
          return Center(
            child: EmptyState(
              icon: Icons.people_outline,
              message: 'لا يوجد لاعبون لحساب المواجهات.',
            ),
          );
        }

        final effectivePlayerId = selectedPlayerId ?? players.first.id;
        if (selectedPlayerId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedHeadToHeadPlayerProvider.notifier).state =
                effectivePlayerId;
          });
        }

        return gamesAsync.when(
          data: (games) {
            final statsService = ref.watch(statisticsServiceProvider);
            final headToHeadStats = statsService.calculateHeadToHeadStats(
              playerId: effectivePlayerId,
              players: players,
              games: games,
            );

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: effectivePlayerId,
                      decoration: InputDecoration(
                        labelText: 'اختر اللاعب',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items:
                          players
                              .map(
                                (player) => DropdownMenuItem(
                                  value: player.id,
                                  child: Text(player.name),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) =>
                              ref
                                  .read(
                                    selectedHeadToHeadPlayerProvider.notifier,
                                  )
                                  .state = value,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          headToHeadStats.isEmpty
                              ? EmptyState(
                                icon: Icons.sports_kabaddi,
                                message: 'لا توجد مواجهات مسجلة لهذا اللاعب.',
                              )
                              : ListView.separated(
                                itemCount: headToHeadStats.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final stat = headToHeadStats[index];
                                  return Card(
                                    elevation: 2,
                                    child: ListTile(
                                      title: Text(
                                        stat.opponentName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'فوز: ${stat.won} • خسارة: ${stat.lost}',
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getWinRateColor(stat.winRate),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, _) => Center(
                child: Text('حدث خطأ أثناء جلب المواجهات: ${error.toString()}'),
              ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
            child: Text('حدث خطأ أثناء جلب اللاعبين: ${error.toString()}'),
          ),
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
              (error, _) => Center(
                child: Text('حدث خطأ: ${error.toString()}'),
              ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
            child: Text('حدث خطأ: ${error.toString()}'),
          ),
    );
  }

  Card _buildFirstPlaceCard(FirstPlaceStats stat) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                spacing: 4,
                runSpacing: 4,
                children: List.generate(
                  stat.firstPlaceCount,
                  (index) => const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
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

  Card _buildStatCard(PlayerStats stat, int rank) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          stat.name,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'انتصارات: ${stat.won} • خسائر: ${stat.lost}',
          textAlign: TextAlign.right,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getWinRateColor(stat.winRate),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            stat.winRateText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  Color _getWinRateColor(double winRate) {
    if (winRate >= 70) return Colors.green;
    if (winRate >= 50) return Colors.orange;
    return Colors.red;
  }

  List<int> _calculateRanks(List<PlayerStats> stats) {
    final ranks = <int>[];
    int? previousPercentage;
    var uniqueRank = 0;

    for (var i = 0; i < stats.length; i++) {
      final currentPercentage = stats[i].winRate.round();
      final rank =
          previousPercentage != null && currentPercentage == previousPercentage
              ? uniqueRank
              : ++uniqueRank;

      ranks.add(rank);
      previousPercentage = currentPercentage;
    }

    return ranks;
  }
}
