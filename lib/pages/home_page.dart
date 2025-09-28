// ============== pages/home_page.dart ==============
import 'package:flutter/material.dart';
import '../widgets/common/app_button.dart';
import 'players_page.dart';
import 'new_game_page.dart';
import 'games_history_page.dart';
import 'statistics_page.dart';
import 'random_teams_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لا احد يسولف بكيفه'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  icon: Icons.people,
                  label: 'إدارة اللاعبين',
                  color: Colors.blue,
                  onPressed: () => _navigate(context, const PlayersPage()),
                ),
                const SizedBox(height: 20),
                AppButton(
                  icon: Icons.shuffle,
                  label: 'تكوين فرق عشوائية',
                  color: Colors.teal,
                  onPressed: () => _navigate(context, const RandomTeamsPage()),
                ),
                const SizedBox(height: 20),
                AppButton(
                  icon: Icons.add_circle,
                  label: 'لعبة جديدة',
                  color: Colors.green,
                  onPressed: () => _navigate(context, const NewGamePage()),
                ),
                const SizedBox(height: 20),
                AppButton(
                  icon: Icons.history,
                  label: 'سجل المباريات',
                  color: Colors.orange,
                  onPressed: () => _navigate(context, const GamesHistoryPage()),
                ),
                const SizedBox(height: 20),
                AppButton(
                  icon: Icons.bar_chart,
                  label: 'الإحصائيات',
                  color: Colors.purple,
                  onPressed: () => _navigate(context, const StatisticsPage()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
