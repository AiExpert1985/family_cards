// ============== pages/main_tab.dart ==============
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'games_history_page.dart';
import 'new_game_page.dart';
import 'random_teams_page.dart';
import 'statistics_page.dart';

class MainTab extends StatelessWidget {
  const MainTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App title/logo area
                const Icon(
                  Icons.style,
                  size: 80,
                  color: AppTheme.primaryPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'لعبة الورق',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 48),

                // Random Teams Button
                _buildMainButton(
                  context: context,
                  icon: Icons.shuffle,
                  label: 'قرعة اللاعبين',
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentTeal, Color(0xFF26C6DA)],
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RandomTeamsPage()),
                  ),
                ),

                const SizedBox(height: 20),

                // Statistics Button
                _buildMainButton(
                  context: context,
                  icon: Icons.bar_chart,
                  label: 'الإحصائيات',
                  gradient: AppTheme.primaryGradient,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatisticsPage()),
                  ),
                ),

                const Spacer(),

                // History button (small)
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GamesHistoryPage()),
                  ),
                  icon: const Icon(Icons.history, size: 20),
                  label: const Text('سجل المباريات'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.warningOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewGamePage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text(
          'تسجيل نتيجة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.accentTeal,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMainButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
