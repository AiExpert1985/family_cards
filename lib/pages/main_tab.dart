// ============== pages/main_tab.dart ==============
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'daily_stats_page.dart';
import 'new_game_page.dart';
import 'overall_stats_page.dart';
import 'random_teams_page.dart';
import 'sync_page.dart';

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
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OverallStatsPage(),
                        ),
                      ),
                ),

                const SizedBox(height: 20),

                // Daily Stats button (purple)
                _buildStatsButton(
                  context: context,
                  icon: Icons.today,
                  label: 'الإحصائيات اليومية',
                  gradient: AppTheme.primaryGradient,
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DailyStatsPage(),
                        ),
                      ),
                ),

                const SizedBox(height: 40),

                // Action buttons row: challenge + add result
                _buildActionButtons(context),

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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLabeledButton(
          context: context,
          label: 'قرعة اللاعبين',
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadowColor: Color(0xFFFF5722),
          child: const Text('⚔️', style: TextStyle(fontSize: 28)),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RandomTeamsPage()),
              ),
        ),
        const SizedBox(width: 20),
        _buildLabeledButton(
          context: context,
          label: 'اضافة نتيجة',
          gradient: const LinearGradient(
            colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadowColor: Color(0xFF43A047),
          child: const Icon(Icons.note_add, size: 34, color: Colors.white),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewGamePage()),
              ),
        ),
        const SizedBox(width: 20),
        _buildLabeledButton(
          context: context,
          label: 'مزامنة بيانات',
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadowColor: Color(0xFF1565C0),
          child: const Icon(Icons.cloud_sync, size: 32, color: Colors.white),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SyncPage()),
              ),
        ),
      ],
    );
  }

  Widget _buildLabeledButton({
    required BuildContext context,
    required String label,
    required LinearGradient gradient,
    required Color shadowColor,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircleButton(
          context: context,
          gradient: gradient,
          shadowColor: shadowColor,
          child: child,
          onTap: onTap,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required BuildContext context,
    required LinearGradient gradient,
    required Color shadowColor,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
