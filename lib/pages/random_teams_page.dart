// ============== pages/random_teams_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/team_generation_result.dart';
import '../providers/providers.dart';
import '../widgets/common/app_button.dart';
import '../widgets/teams/match_display.dart';
import '../widgets/teams/resting_players_card.dart';

class RandomTeamsPage extends ConsumerStatefulWidget {
  const RandomTeamsPage({super.key});

  @override
  ConsumerState<RandomTeamsPage> createState() => _RandomTeamsPageState();
}

class _RandomTeamsPageState extends ConsumerState<RandomTeamsPage> {
  TeamGenerationResult? _result;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedPlayersProvider.notifier).loadSelectedPlayers();
      ref.read(restedPlayersProvider.notifier).loadRestedPlayers();
    });
  }

  Future<void> _generateTeams() async {
    setState(() => _isGenerating = true);

    final players = ref.read(playersProvider).value ?? [];
    final selectedIds = ref.read(selectedPlayersProvider).value ?? {};
    final restedIds = ref.read(restedPlayersProvider).value ?? {};
    final teamGenerator = ref.read(teamGeneratorServiceProvider);

    // Check if selection changed and reset cycle if needed
    final storage = ref.read(storageServiceProvider);
    final lastSelected = await storage.getLastSelectedPlayerIdsCheck();

    if (!_setsEqual(lastSelected, selectedIds)) {
      await storage.saveRestedPlayerIds({});
      await storage.saveLastSelectedPlayerIdsCheck(selectedIds);
      await ref.read(restedPlayersProvider.notifier).loadRestedPlayers();
    }

    final result = teamGenerator.generateTeams(
      allPlayers: players,
      selectedPlayerIds: selectedIds,
      restedPlayerIds: ref.read(restedPlayersProvider).value ?? {},
    );

    if (result.isSuccess) {
      // Update rested players
      final newRestedIds = Set<String>.from(restedIds)
        ..addAll(result.restingPlayers.map((p) => p.id));
      await ref.read(restedPlayersProvider.notifier).updateRested(newRestedIds);
    }

    setState(() {
      _result = result;
      _isGenerating = false;
    });
  }

  bool _setsEqual(Set<String> a, Set<String> b) {
    return a.length == b.length && a.containsAll(b);
  }

  Future<void> _showPlayerSelectionDialog() async {
    final players = ref.read(playersProvider).value ?? [];
    final currentSelection = ref.read(selectedPlayersProvider).value ?? {};
    final restedIds = ref.read(restedPlayersProvider).value ?? {};

    final result = await showDialog<Set<String>>(
      context: context,
      builder:
          (context) => _PlayerSelectionDialog(
            players: players,
            initialSelection: currentSelection,
            restedIds: restedIds,
          ),
    );

    if (result != null) {
      await ref.read(selectedPlayersProvider.notifier).updateSelection(result);
      setState(() {
        _result = null; // Clear previous results when selection changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedAsync = ref.watch(selectedPlayersProvider);
    final selectedCount = selectedAsync.value?.length ?? 0;
    final canGenerate = selectedCount >= 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تكوين فرق عشوائية'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppButton(
              icon: Icons.check_box,
              label: 'اختيار اللاعبين المشاركين ($selectedCount مختار)',
              color: Colors.indigo,
              onPressed: _showPlayerSelectionDialog,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AppButton(
              icon: Icons.shuffle,
              label:
                  selectedCount >= 8
                      ? 'تكوين 4 فرق عشوائية (8 لاعبين)'
                      : 'تكوين 2 فريق عشوائي (4 لاعبين)',
              color: Colors.teal,
              onPressed: canGenerate && !_isGenerating ? _generateTeams : null,
              isLoading: _isGenerating,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildResultsView()),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    if (_result == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'قم باختيار اللاعبين وتكوين الفرق',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_result!.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                _result!.errorMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // First match
          MatchDisplay(
            team1: _result!.teams[0],
            team2: _result!.teams[1],
            title: _result!.teams.length == 4 ? 'المباراة الأولى' : null,
          ),

          // Second match if exists
          if (_result!.teams.length == 4) ...[
            const SizedBox(height: 24),
            MatchDisplay(
              team1: _result!.teams[2],
              team2: _result!.teams[3],
              title: 'المباراة الثانية',
            ),
          ],

          // Resting players
          if (_result!.restingPlayers.isNotEmpty) ...[
            const SizedBox(height: 30),
            RestingPlayersCard(players: _result!.restingPlayers),
          ],
        ],
      ),
    );
  }
}

// ============== Player Selection Dialog ==============
class _PlayerSelectionDialog extends StatefulWidget {
  final List<Player> players;
  final Set<String> initialSelection;
  final Set<String> restedIds;

  const _PlayerSelectionDialog({
    required this.players,
    required this.initialSelection,
    required this.restedIds,
  });

  @override
  State<_PlayerSelectionDialog> createState() => _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState extends State<_PlayerSelectionDialog> {
  late Set<String> _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = Set.from(widget.initialSelection);
  }

  void _togglePlayer(String playerId) {
    setState(() {
      if (_currentSelection.contains(playerId)) {
        _currentSelection.remove(playerId);
      } else {
        _currentSelection.add(playerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختيار اللاعبين', textAlign: TextAlign.right),
      contentPadding: const EdgeInsets.only(top: 20),
      content: SizedBox(
        width: double.maxFinite,
        child:
            widget.players.isEmpty
                ? const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'لا يوجد لاعبين\nقم بإضافة لاعبين أولاً',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.players.length,
                  itemBuilder: (context, index) {
                    final player = widget.players[index];
                    final isSelected = _currentSelection.contains(player.id);
                    final hasRested = widget.restedIds.contains(player.id) && isSelected;

                    return ListTile(
                      title: Text(player.name, textAlign: TextAlign.right),
                      trailing:
                          hasRested
                              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                              : null,
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _togglePlayer(player.id),
                      ),
                      onTap: () => _togglePlayer(player.id),
                    );
                  },
                ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _currentSelection),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: const Text('حفظ الاختيار'),
        ),
      ],
    );
  }
}
