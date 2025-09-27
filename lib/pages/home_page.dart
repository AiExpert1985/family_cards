// ============== pages/home_page.dart ==============
import 'package:flutter/material.dart';
import 'players_page.dart';
import 'new_game_page.dart';
import 'games_history_page.dart';
import 'statistics_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('متتبع ألعاب الورق'),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MenuButton(
                  icon: Icons.people,
                  label: 'إدارة اللاعبين',
                  color: Colors.blue,
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlayersPage()),
                      ),
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  icon: Icons.add_circle,
                  label: 'لعبة جديدة',
                  color: Colors.green,
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NewGamePage()),
                      ),
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  icon: Icons.history,
                  label: 'سجل المباريات',
                  color: Colors.orange,
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GamesHistoryPage()),
                      ),
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  icon: Icons.bar_chart,
                  label: 'الإحصائيات',
                  color: Colors.purple,
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StatisticsPage()),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
