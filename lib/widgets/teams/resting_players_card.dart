// ============== widgets/teams/resting_players_card.dart ==============
import 'package:flutter/material.dart';
import '../../models/player.dart';

class RestingPlayersCard extends StatelessWidget {
  final List<Player> players;
  final VoidCallback? onResetCycle;

  const RestingPlayersCard({super.key, required this.players, this.onResetCycle});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // First row: Title and Reset button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (onResetCycle != null)
                  TextButton.icon(
                    onPressed: onResetCycle,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('إعادة تعيين'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  children: [
                    Text(
                      'دكة الاحتياط',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.bed, color: Colors.grey.shade600),
                  ],
                ),
              ],
            ),
            // Second row: Player names
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8.0,
                runSpacing: 8.0,
                children:
                    players
                        .map(
                          (p) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Text(
                              p.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
