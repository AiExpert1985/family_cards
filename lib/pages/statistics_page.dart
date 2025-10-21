// ============== pages/statistics_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_stats.dart';
import '../providers/providers.dart';
import '../widgets/common/empty_state.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats.isEmpty) {
            return const EmptyState(
              icon: Icons.bar_chart,
              message: 'لا توجد إحصائيات\nقم بإضافة مباريات أولاً',
            );
          }

          final ranks = _calculateRanks(stats);

          return ListView.builder(
            itemCount: stats.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final stat = stats[index];
              final rank = ranks[index];

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
    );
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
