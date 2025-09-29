// ============== pages/records_tab.dart ==============
import 'package:family_cards/pages/games_history_page.dart';
import 'package:family_cards/pages/statistics_page.dart';
import 'package:family_cards/widgets/common/app_button.dart';
import 'package:flutter/material.dart';

class RecordsTab extends StatelessWidget {
  const RecordsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
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
            AppButton(
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
    );
  }
}
