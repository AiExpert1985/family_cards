// ============== pages/statistics_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/player_stats.dart';
import '../providers/providers.dart';
import '../widgets/common/empty_state.dart';

enum _StatisticsView { overall, daily }

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  var _selectedView = _StatisticsView.overall;

  @override
  Widget build(BuildContext context) {
    final overallStatsAsync = ref.watch(statisticsProvider);
    final dailyStatsAsync = ref.watch(dailyStatisticsProvider);
    final selectedDate = ref.watch(selectedStatisticsDateProvider);

    final isDailyView = _selectedView == _StatisticsView.daily;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإحصائيات'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'الإحصائيات العامة'),
              Tab(text: 'الإحصائيات اليومية'),
            ],
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
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildViewButton(
                    label: 'الإحصائيات العامة',
                    isSelected: _selectedView == _StatisticsView.overall,
                    onPressed: () {
                      if (_selectedView != _StatisticsView.overall) {
                        setState(() => _selectedView = _StatisticsView.overall);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildViewButton(
                    label: 'الإحصائيات اليومية',
                    isSelected: isDailyView,
                    onPressed: () {
                      if (_selectedView != _StatisticsView.daily) {
                        setState(() => _selectedView = _StatisticsView.daily);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isDailyView)
            _buildDateSelector(context, ref, selectedDate),
          Expanded(
            child: _buildStatsContent(
              statsAsync: isDailyView ? dailyStatsAsync : overallStatsAsync,
              emptyMessage: isDailyView
                  ? 'لا توجد مباريات في هذا اليوم'
                  : 'لا توجد إحصائيات\nقم بإضافة مباريات أولاً',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent({
    required AsyncValue<List<PlayerStats>> statsAsync,
    required String emptyMessage,
  }) {
    return statsAsync.when(
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
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('حدث خطأ: ${error.toString()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildViewButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.purple : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.purple,
        side: const BorderSide(color: Colors.purple, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildDateSelector(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    final formattedDate = DateFormat('yyyy/MM/dd').format(selectedDate);
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

  Future<void> _selectDate(BuildContext context, WidgetRef ref, DateTime initialDate) async {
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
    return ref.read(gamesProvider).maybeWhen(
          data: (games) {
            if (games.isEmpty) {
              return null;
            }
            return games
                .map((game) => game.date.toLocal())
                .reduce((value, element) => value.isBefore(element) ? value : element);
          },
          orElse: () => null,
        )?.toLocal();
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
    var previousRank = 0;

    for (var i = 0; i < stats.length; i++) {
      final currentPercentage = stats[i].winRate.round();
      final rank =
          previousPercentage != null && currentPercentage == previousPercentage
              ? previousRank
              : i + 1;

      ranks.add(rank);
      previousPercentage = currentPercentage;
      previousRank = rank;
    }

    return ranks;
  }
}
