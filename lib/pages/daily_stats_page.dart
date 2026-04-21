// ============== pages/daily_stats_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:table_calendar/table_calendar.dart';

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

class DailyStatsPage extends ConsumerStatefulWidget {
  const DailyStatsPage({super.key});

  @override
  ConsumerState<DailyStatsPage> createState() => _DailyStatsPageState();
}

class _DailyStatsPageState extends ConsumerState<DailyStatsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initDate());
  }

  void _initDate() {
    final games = ref.read(gamesProvider).value;
    if (games == null || games.isEmpty) return;
    final latest = games.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    final d = latest.date.toLocal();
    ref.read(selectedDailyDateProvider.notifier).state =
        DateTime(d.year, d.month, d.day);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDailyDateProvider);
    final formattedDate = intl.DateFormat('yyyy/MM/dd').format(selectedDate);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const Text('الإحصائيات اليومية',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(formattedDate,
                  style: const TextStyle(fontSize: 13, color: Colors.white70)),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          ),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              tooltip: 'اختر تاريخ',
              onPressed: () => _selectDate(context, ref, selectedDate),
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 15),
            indicator: ModernTabIndicator(color: AppTheme.accentTeal, height: 3, radius: 2),
            tabs: const [
              Tab(text: 'الترتيب'),
              Tab(text: 'الأبطال'),
              Tab(text: 'المباريات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DailyRankingTab(selectedDate: selectedDate),
            _DailyCupsTab(),
            _DailyGamesTab(selectedDate: selectedDate),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref, DateTime current) async {
    final games = ref.read(gamesProvider).value ?? [];
    final daysWithGames = games.map((g) {
      final d = g.date.toLocal();
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    DateTime firstDate = DateTime.now();
    if (games.isNotEmpty) {
      final earliest = games
          .map((g) => g.date.toLocal())
          .reduce((a, b) => a.isBefore(b) ? a : b);
      firstDate = DateTime(earliest.year, earliest.month, earliest.day);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CalendarSheet(
        initialDate: current,
        firstDate: firstDate,
        lastDate: DateTime.now(),
        daysWithGames: daysWithGames,
        onDaySelected: (picked) {
          ref.read(selectedDailyDateProvider.notifier).state =
              DateTime(picked.year, picked.month, picked.day);
        },
      ),
    );
  }
}

// ── Tab 1: Daily Ranking ──────────────────────────────────────────────────────

class _DailyRankingTab extends ConsumerWidget {
  final DateTime selectedDate;

  const _DailyRankingTab({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersProvider);
    final gamesAsync = ref.watch(gamesProvider);
    final service = ref.watch(statisticsServiceProvider);

    return playersAsync.when(
      data: (players) => gamesAsync.when(
        data: (games) {
          final stats = service
              .calculateDailyStats(date: selectedDate, players: players, games: games)
              .where((s) => s.played > 0)
              .toList();

          if (stats.isEmpty) {
            return const Center(
              child: EmptyState(
                icon: Icons.bar_chart,
                message: 'لا توجد مباريات في هذا اليوم',
              ),
            );
          }

          final ranks = _calculateRanks(stats);
          return ListView.builder(
            itemCount: stats.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) => _StatCard(
              stat: stats[index],
              rank: ranks[index],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('حدث خطأ: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('حدث خطأ: $e')),
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
}

// ── Tab 2: Daily Cups ─────────────────────────────────────────────────────────

class _DailyCupsTab extends ConsumerWidget {
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
            final cups = service.calculateDailyCups(players: players, games: games);
            if (cups.isEmpty) {
              return const Center(
                child: EmptyState(icon: Icons.emoji_events, message: 'لا توجد إحصائيات.'),
              );
            }
            return ListView.builder(
              itemCount: cups.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) => _DailyCupCard(
                stat: cups[index],
                onCupTap: (date) => _showDailySnapshot(context, ref, players, games, date),
              ),
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

  void _showDailySnapshot(
    BuildContext context,
    WidgetRef ref,
    List<Player> players,
    List<Game> games,
    DateTime date,
  ) {
    final service = ref.read(statisticsServiceProvider);
    final stats = service
        .calculateDailyStats(date: date, players: players, games: games)
        .where((s) => s.played > 0)
        .toList();
    final label = intl.DateFormat('yyyy/MM/dd').format(date);
    _showStandingSheet(context, 'ترتيب يوم $label', stats);
  }
}

// ── Tab 3: Daily Games ────────────────────────────────────────────────────────

class _DailyGamesTab extends ConsumerWidget {
  final DateTime selectedDate;

  const _DailyGamesTab({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GamesListBody(filterDate: selectedDate);
  }
}

// ── Standing snapshot sheet ───────────────────────────────────────────────────

void _showStandingSheet(BuildContext context, String title, List<PlayerStats> stats) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
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
                itemBuilder: (context, index) =>
                    _StatCard(stat: stats[index], rank: index + 1),
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

  const _StatCard({required this.stat, required this.rank});

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: () {},
      child: Padding(
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
                      Text(stat.winRateText,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      Text(' • خسائر: ',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      AnimatedCounter(
                          value: stat.lost,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      Text(' • انتصارات: ',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      AnimatedCounter(
                          value: stat.won,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
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
      ),
    );
  }
}

class _DailyCupCard extends StatelessWidget {
  final FirstPlaceStats stat;
  final void Function(DateTime date) onCupTap;

  const _DailyCupCard({required this.stat, required this.onCupTap});

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
                    return GestureDetector(
                      onTap: () => onCupTap(date),
                      child: AnimatedTrophy(
                        index: index,
                        isShared: false,
                        date: date,
                      ),
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

// ── Calendar picker sheet ─────────────────────────────────────────────────────

class _CalendarSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Set<DateTime> daysWithGames;
  final ValueChanged<DateTime> onDaySelected;

  const _CalendarSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.daysWithGames,
    required this.onDaySelected,
  });

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
  }

  bool _hasGames(DateTime day) {
    return widget.daysWithGames.contains(DateTime(day.year, day.month, day.day));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: widget.firstDate,
            lastDay: widget.lastDate,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => DateUtils.isSameDay(day, _selectedDay),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: ''},
            eventLoader: (day) => _hasGames(day) ? [true] : [],
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDaySelected(selectedDay);
              Navigator.of(context).pop();
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: AppTheme.accentTeal,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryPurple,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ],
      ),
    );
  }
}
