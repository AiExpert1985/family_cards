// ============== pages/random_teams_page.dart ==============
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/player.dart';
import '../services/storage_service.dart';

class RandomTeamsPage extends StatefulWidget {
  const RandomTeamsPage({super.key});

  @override
  State<RandomTeamsPage> createState() => _RandomTeamsPageState();
}

class _RandomTeamsPageState extends State<RandomTeamsPage> {
  final storage = StorageService();
  List<Player> allPlayers = [];
  Set<String> selectedPlayerIds = {};
  List<List<Player>> teams = [];
  List<Player> playersInRest = []; // List for resting players
  String resultMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    allPlayers = await storage.getPlayers();
    selectedPlayerIds = await storage.getSelectedPlayerIds();
    setState(() {});
  }

  void _updateSelectedPlayerIds(Set<String> newSelectedIds) {
    setState(() {
      selectedPlayerIds = newSelectedIds;
      teams = [];
      playersInRest = [];
      resultMessage = '';
    });
    storage.saveSelectedPlayerIds(selectedPlayerIds);
  }

  Future<void> _showPlayerSelectionDialog() async {
    final updatedIds = await showDialog<Set<String>>(
      context: context,
      builder: (context) => _PlayerSelectionDialog(
        allPlayers: allPlayers,
        initialSelectedIds: selectedPlayerIds,
      ),
    );

    if (updatedIds != null) {
      _updateSelectedPlayerIds(updatedIds);
    }
  }

  Future<void> _generateRandomTeams() async {
    final List<Player> selectedPlayers = allPlayers
        .where((p) => selectedPlayerIds.contains(p.id))
        .toList();

    if (selectedPlayers.length < 4) {
      setState(() {
        teams = [];
        playersInRest = [];
        resultMessage = 'يجب اختيار 4 لاعبين على الأقل لتكوين فرق.';
      });
      return;
    }

    final requiredPlayers = selectedPlayers.length >= 8 ? 8 : 4;
    final int numTeams = requiredPlayers ~/ 2; 

    // --- 1. Cycle Check and Reset ---
    // A player MUST play if they have needsToPlay = true.
    final playersWhoNeedToPlay = selectedPlayers.where((p) => p.needsToPlay).toList();
    
    // Check: If the count of players needing to play equals the total selected, 
    // it means everyone has rested once, so we reset the cycle.
    if (playersWhoNeedToPlay.length == selectedPlayers.length) {
      // Full cycle complete! Reset all needsToPlay flags for the selected group.
      allPlayers = allPlayers.map((p) {
        if (selectedPlayerIds.contains(p.id)) {
          return p.copyWith(needsToPlay: false); 
        }
        return p;
      }).toList();
    }
    
    // Refresh player lists based on the potentially reset allPlayers list
    final List<Player> reloadedSelectedPlayers = allPlayers
        .where((p) => selectedPlayerIds.contains(p.id))
        .toList();

    final List<Player> mustPlayPlayers = reloadedSelectedPlayers.where((p) => p.needsToPlay).toList();
    final List<Player> canRestPlayers = reloadedSelectedPlayers.where((p) => !p.needsToPlay).toList();

    // --- 2. Selection Logic ---
    List<Player> chosenPlayers = [];

    // Prioritize players who MUST play first
    chosenPlayers.addAll(mustPlayPlayers);

    // Filter out chosen players from the canRest list for randomization
    final List<Player> availableToRest = canRestPlayers
        .where((p) => !chosenPlayers.contains(p))
        .toList();

    // Fill the rest randomly from players who CAN rest
    final int remainingNeeded = requiredPlayers - chosenPlayers.length;
    if (remainingNeeded > 0) {
      availableToRest.shuffle();
      final playersToAdd = availableToRest.sublist(0, min(remainingNeeded, availableToRest.length));
      chosenPlayers.addAll(playersToAdd);
    }
    
    if (chosenPlayers.length < requiredPlayers) {
      setState(() {
        teams = [];
        playersInRest = [];
        resultMessage = 'عدد اللاعبين المختارين غير كافٍ لتكوين الفرق المطلوبة.';
      });
      return;
    }

    chosenPlayers.shuffle();

    // --- 3. Team Assignment ---
    final List<List<Player>> newTeams = List.generate(numTeams, (_) => []);
    for (int i = 0; i < chosenPlayers.length; i++) {
      newTeams[i % numTeams].add(chosenPlayers[i]);
    }
    teams = newTeams;

    // --- 4. Update 'needsToPlay' Status and Persistence ---
    final chosenIds = chosenPlayers.map((p) => p.id).toSet();
    
    // Identify resting players for display
    playersInRest = reloadedSelectedPlayers.where((p) => !chosenIds.contains(p.id)).toList();

    // Update needsToPlay status for the NEXT round
    allPlayers = allPlayers.map((p) {
      if (selectedPlayerIds.contains(p.id)) {
        if (chosenIds.contains(p.id)) {
          // If playing, reset needsToPlay to false (neutral for next selection)
          return p.copyWith(needsToPlay: false);
        } else {
          // If resting, set needsToPlay to true (must play next)
          return p.copyWith(needsToPlay: true);
        }
      }
      return p;
    }).toList();
    
    // Save updated players list
    await storage.savePlayers(allPlayers);
    
    // --- 5. Final UI Update ---
    setState(() {
      resultMessage = ''; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final available = allPlayers.where((p) => selectedPlayerIds.contains(p.id)).length;
    final canGenerate = available >= 4;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('تكوين فرق عشوائية'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Player Selection Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showPlayerSelectionDialog,
                icon: const Icon(Icons.check_box),
                label: Text(
                  'اختيار اللاعبين المشاركين ($available مختار)',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ),

          // Generate Teams Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canGenerate ? _generateRandomTeams : null,
                icon: const Icon(Icons.shuffle),
                label: Text(
                  available >= 8
                      ? 'تكوين 4 فرق عشوائية (8 لاعبين)'
                      : 'تكوين 2 فريق عشوائي (4 لاعبين)',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ),
          
          // Results Display
          Expanded(
            child: teams.isEmpty && resultMessage.isEmpty
                ? const Center(child: Text('قم باختيار اللاعبين وتكوين الفرق', style: TextStyle(fontSize: 16, color: Colors.grey)))
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (resultMessage.isNotEmpty) 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            resultMessage,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Display Matches (Team 1 vs Team 2, Team 3 vs Team 4)
                      if (teams.isNotEmpty) ..._buildMatches(),
                      
                      const SizedBox(height: 30),
                      
                      // Display Resting Players
                      if (playersInRest.isNotEmpty) 
                        _RestingPlayersList(players: playersInRest),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMatches() {
    List<Widget> matchWidgets = [];
    
    // Match 1: Team 1 vs Team 2
    matchWidgets.add(_MatchRow(
      team1: teams[0], 
      team2: teams[1], 
      matchNumber: 1, 
      totalTeams: teams.length, 
    ));
    
    // Match 2: Team 3 vs Team 4 (if available)
    if (teams.length == 4) {
      matchWidgets.add(const SizedBox(height: 24));
      matchWidgets.add(_MatchRow(
        team1: teams[2], 
        team2: teams[3], 
        matchNumber: 2, 
        totalTeams: teams.length, 
      ));
    }
    
    return matchWidgets;
  }
}

// --- WIDGET: Player Selection Dialog ---

class _PlayerSelectionDialog extends StatefulWidget {
  final List<Player> allPlayers;
  final Set<String> initialSelectedIds;

  const _PlayerSelectionDialog({
    required this.allPlayers,
    required this.initialSelectedIds,
  });

  @override
  State<_PlayerSelectionDialog> createState() => __PlayerSelectionDialogState();
}

class __PlayerSelectionDialogState extends State<_PlayerSelectionDialog> {
  late Set<String> currentSelectedIds;

  @override
  void initState() {
    super.initState();
    currentSelectedIds = Set.from(widget.initialSelectedIds);
  }

  void _togglePlayerSelection(String playerId) {
    setState(() {
      if (currentSelectedIds.contains(playerId)) {
        currentSelectedIds.remove(playerId);
      } else {
        currentSelectedIds.add(playerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختيار اللاعبين', textAlign: TextAlign.right),
      contentPadding: const EdgeInsets.only(top: 10),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.allPlayers.length,
          itemBuilder: (context, index) {
            final player = widget.allPlayers[index];
            final isSelected = currentSelectedIds.contains(player.id);
            return ListTile(
              title: Text(player.name, textAlign: TextAlign.right),
              trailing: player.needsToPlay
                  ? const Icon(Icons.star, color: Colors.amber, size: 20)
                  : null,
              leading: Checkbox(
                value: isSelected,
                onChanged: (_) => _togglePlayerSelection(player.id),
              ),
              onTap: () => _togglePlayerSelection(player.id),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, currentSelectedIds),
          child: const Text('حفظ الاختيار'),
        ),
      ],
    );
  }
}

// --- WIDGET: Team Display ---

class _TeamDisplay extends StatelessWidget {
  final List<Player> team;
  final Color color;

  const _TeamDisplay({required this.team, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          team.first.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          team.last.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// --- WIDGET: Match Row ---

class _MatchRow extends StatelessWidget {
  final List<Player> team1;
  final List<Player> team2;
  final int matchNumber;
  final int totalTeams;

  const _MatchRow({
    required this.team1, 
    required this.team2, 
    required this.matchNumber,
    required this.totalTeams,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (matchNumber == 1 && totalTeams == 4)
          const Text('المباراة الأولى', style: TextStyle(fontSize: 16, color: Colors.grey)),
        if (matchNumber == 2) 
          const Text('المباراة الثانية', style: TextStyle(fontSize: 16, color: Colors.grey)),
        if (matchNumber > 1)
          const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _TeamDisplay(team: team1, color: Colors.blue.shade700),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'X',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.red),
              ),
            ),
            Expanded(
              child: _TeamDisplay(team: team2, color: Colors.red.shade700),
            ),
          ],
        ),
      ],
    );
  }
}

// --- WIDGET: Resting Players List ---

class _RestingPlayersList extends StatelessWidget {
  final List<Player> players;

  const _RestingPlayersList({required this.players});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink(); 
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'اللاعبون تحت الراحة:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8.0,
            runSpacing: 4.0,
            children: players.map((p) => Chip(
              label: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              backgroundColor: Colors.white,
              avatar: const Icon(Icons.bed, color: Colors.orange),
            )).toList(),
          ),
        ),
      ],
    );
  }
}