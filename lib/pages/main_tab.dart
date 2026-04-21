// ============== pages/main_tab.dart ==============
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'daily_stats_page.dart';
import 'overall_stats_page.dart';
import 'random_teams_page.dart';

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
            colors: [Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Overall Stats button (teal)
                _buildStatsButton(
                  context: context,
                  icon: Icons.bar_chart,
                  label: 'الإحصائيات العامة',
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentTeal, Color(0xFF26C6DA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OverallStatsPage()),
                  ),
                ),

                const SizedBox(height: 20),

                // Daily Stats button (purple)
                _buildStatsButton(
                  context: context,
                  icon: Icons.today,
                  label: 'الإحصائيات اليومية',
                  gradient: AppTheme.primaryGradient,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DailyStatsPage()),
                  ),
                ),

                const SizedBox(height: 40),

                // Random teams icon button
                _buildChallengeButton(context),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 130,
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
                Icon(icon, size: 44, color: Colors.white),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 22,
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

  Widget _buildChallengeButton(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5722).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RandomTeamsPage()),
            ),
            child: const Icon(Icons.sports_kabaddi, size: 36, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
