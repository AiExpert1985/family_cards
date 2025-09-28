// ============== widgets/teams/match_display.dart ==============
import 'package:flutter/material.dart';
import '../../models/player.dart';
import 'team_display_card.dart';

class MatchDisplay extends StatelessWidget {
  final List<Player> team1;
  final List<Player> team2;
  final String? title;

  const MatchDisplay({super.key, required this.team1, required this.team2, this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(child: TeamDisplayCard(team: team1, color: Colors.blue.shade700)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.red),
                ),
              ),
            ),
            Expanded(child: TeamDisplayCard(team: team2, color: Colors.red.shade700)),
          ],
        ),
      ],
    );
  }
}
