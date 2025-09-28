// ============== widgets/teams/resting_players_card.dart ==============
import 'package:flutter/material.dart';
import '../../models/player.dart';

class RestingPlayersCard extends StatelessWidget {
  final List<Player> players;

  const RestingPlayersCard({super.key, required this.players});

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
            // Centered title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'دكة الاحتياط',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.bed, color: Colors.orange),
              ],
            ),
            const SizedBox(height: 12),
            // Centered player chips
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  players
                      .map(
                        (p) => Chip(
                          label: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          backgroundColor: Colors.orange.shade50,
                          avatar: const Icon(Icons.person, color: Colors.orange, size: 18),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
