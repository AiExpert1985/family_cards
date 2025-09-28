// ============== widgets/teams/team_display_card.dart ==============
import 'package:flutter/material.dart';
import '../../models/player.dart';

class TeamDisplayCard extends StatelessWidget {
  final List<Player> team;
  final Color color;
  final String? teamLabel;

  const TeamDisplayCard({super.key, required this.team, required this.color, this.teamLabel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (teamLabel != null) ...[
              Text(
                teamLabel!,
                style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
            ],
            ...team.map(
              (player) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  player.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
