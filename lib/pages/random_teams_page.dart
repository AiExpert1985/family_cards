// ============== pages/random_teams_page.dart ==============
import 'package:family_cards/pages/new_game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/team_generation_result.dart';
import '../providers/providers.dart';
import '../widgets/teams/team_display_card.dart';
import '../widgets/teams/resting_players_card.dart';
import '../widgets/teams/manual_rest_manager_sheet.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(playersProvider.notifier).loadPlayers();
      await _checkAndResetPairings();
      await ref.read(selectedPlayersProvider.notifier).loadSelectedPlayers();
      await ref.read(restedPlayersProvider.notifier).loadRestedPlayers();
      await _loadLastResult();
    });
  }

  Future<void> _checkAndResetPairings() async {
    final storage = ref.read(storageServiceProvider);
    final shouldReset = await storage.shouldResetPairings();

    if (shouldReset) {
      final players = ref.read(playersProvider).value ?? [];
      final resetPlayers = players.map((p) => p.copyWith(pairedWithToday: [])).toList();
      await ref.read(playersProvider.notifier).updatePlayers(resetPlayers);

      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      await storage.saveLastPairingResetDate(todayString);
    }
  }

  Future<void> _loadLastResult() async {
    final storage = ref.read(storageServiceProvider);
    final lastResult = await storage.getLastTeamResult();

    if (lastResult == null) {
      setState(() {
        _result = null;
      });
      return;
    }

    final players = ref.read(playersProvider).value ?? [];

    if (players.isEmpty) {
      setState(() {
        _result = null;
      });
      return;
    }

    try {
      final teams =
          (lastResult['teams'] as List)
              .map(
                (teamList) =>
                    (teamList as List)
                        .map(
                          (playerId) => players.firstWhere(
                            (p) => p.id == playerId,
                            orElse:
                                () => Player(id: playerId, name: 'غير معروف'),
                          ),
                        )
                        .toList(),
              )
              .toList();

      final restingPlayers =
          (lastResult['restingPlayers'] as List)
              .map(
                (playerId) => players.firstWhere(
                  (p) => p.id == playerId,
                  orElse: () => Player(id: playerId, name: 'غير معروف'),
                ),
              )
              .toList();

      setState(() {
        _result = TeamGenerationResult(
          teams: teams,
          restingPlayers: restingPlayers,
        );
      });
    } catch (e) {
      setState(() {
        _result = null;
      });
    }
  }

  Future<void> _saveResult(TeamGenerationResult result) async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveLastTeamResult({
      'teams':
          result.teams.map((team) => team.map((p) => p.id).toList()).toList(),
      'restingPlayers': result.restingPlayers.map((p) => p.id).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _generateTeams() async {
    setState(() => _isGenerating = true);

    final players = ref.read(playersProvider).value ?? [];
    final selectedIds = ref.read(selectedPlayersProvider).value ?? {};
    final currentRestedIds = ref.read(restedPlayersProvider).value ?? {};
    final teamGenerator = ref.read(teamGeneratorServiceProvider);
    final storage = ref.read(storageServiceProvider);

    final lastSelected = await storage.getLastSelectedPlayerIdsCheck();
    Set<String> activeRestedIds = currentRestedIds;

    if (!_setsEqual(lastSelected, selectedIds)) {
      activeRestedIds = {};
      await ref
          .read(restedPlayersProvider.notifier)
          .updateRested(activeRestedIds);
      await storage.saveLastSelectedPlayerIdsCheck(selectedIds);
    }

    final result = teamGenerator.generateTeams(
      allPlayers: players,
      selectedPlayerIds: selectedIds,
      restedPlayerIds: activeRestedIds,
    );

    if (result.isSuccess) {
      final notRestedYet =
          selectedIds.where((id) => !activeRestedIds.contains(id)).toSet();

      Set<String> newRestedIds;
      if (notRestedYet.length < result.restingPlayers.length) {
        final newCyclePlayers = result.restingPlayers.skip(notRestedYet.length);
        newRestedIds = newCyclePlayers.map((p) => p.id).toSet();
      } else {
        newRestedIds = Set<String>.from(activeRestedIds)
          ..addAll(result.restingPlayers.map((p) => p.id));
      }

      await ref.read(restedPlayersProvider.notifier).updateRested(newRestedIds);

      if (result.updatedPlayers.isNotEmpty) {
        await ref.read(playersProvider.notifier).updatePlayers(result.updatedPlayers);
      }
    }

    setState(() {
      _result = result;
      _isGenerating = false;
    });

    // Save result after setting state
    if (result.isSuccess) {
      await _saveResult(result);
    }
  }

  bool _setsEqual(Set<String> a, Set<String> b) {
    return a.length == b.length && a.containsAll(b);
  }

  Future<void> _showPlayerSelectionDialog() async {
    await ref.read(playersProvider.notifier).loadPlayers();

    final players = ref.read(playersProvider).value ?? [];
    final currentSelection = ref.read(selectedPlayersProvider).value ?? {};

    if (!mounted) return;

    final result = await showDialog<Set<String>?>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _PlayerSelectionDialog(
            players: players,
            initialSelection: currentSelection,
          ),
    );

    if (result != null) {
      await ref.read(selectedPlayersProvider.notifier).updateSelection(result);
      final storage = ref.read(storageServiceProvider);
      await storage.clearLastTeamResult(); // Add this
      setState(() {
        _result = null;
      });
    }
  }

  Future<void> _showManualRestManager() async {
    await ref.read(playersProvider.notifier).loadPlayers();
    await ref.read(restedPlayersProvider.notifier).loadRestedPlayers();

    final players = ref.read(playersProvider).value ?? [];
    final restingIds = ref.read(restedPlayersProvider).value ?? {};

    if (!mounted) return;

    final updatedRestingIds = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ManualRestManagerSheet(
          players: players,
          initialRestingIds: restingIds,
        );
      },
    );

    if (updatedRestingIds != null) {
      await ref
          .read(restedPlayersProvider.notifier)
          .updateRested(updatedRestingIds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث قائمة المستريحين'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    }
  }

  Future<void> _resetAllPairings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الفرق'),
        content: const Text('هل تريد مسح سجل الفرق لهذا اليوم؟\nسيتمكن جميع اللاعبين من اللعب معاً مرة أخرى.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final players = ref.read(playersProvider).value ?? [];
      final resetPlayers = players.map((p) => p.copyWith(pairedWithToday: [])).toList();
      await ref.read(playersProvider.notifier).updatePlayers(resetPlayers);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إعادة تعيين سجل الفرق'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة تعيين سجل الفرق',
            onPressed: _resetAllPairings,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_box),
                    label: Text(
                      'اختيار اللاعبين ',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _showPlayerSelectionDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.pause_circle_outline),
                    label: const Text(
                      'ادارة الاستراحات',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _showManualRestManager,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon:
                    _isGenerating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.shuffle),
                label: Text("القرعة", style: const TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canGenerate ? Colors.grey.shade800 : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    canGenerate && !_isGenerating ? _generateTeams : null,
              ),
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

    if (_result!.teams.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'لم يتم تكوين فرق',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._buildAllMatches(),
          if (_result!.restingPlayers.isNotEmpty) ...[
            const SizedBox(height: 30),
            RestingPlayersCard(players: _result!.restingPlayers),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildAllMatches() {
    final matches = <Widget>[];
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.purple.shade700,
      Colors.orange.shade700,
      Colors.teal.shade700,
      Colors.pink.shade700,
    ];

    for (int i = 0; i < _result!.teams.length; i += 2) {
      if (i + 1 < _result!.teams.length) {
        final matchNumber = (i ~/ 2) + 1;
        final color = colors[i ~/ 2 % colors.length];

        if (i > 0) {
          matches.add(const SizedBox(height: 24));
        }

        if (_result!.teams.length > 2) {
          matches.add(
            Text(
              'المباراة ${_getArabicNumber(matchNumber)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
          matches.add(const SizedBox(height: 12));
        }

        matches.add(
          Row(
            children: [
              Expanded(
                child: TeamDisplayCard(
                  team: _result!.teams[i],
                  color: color,
                  onTap:
                      () => _navigateToNewGame(
                        _result!.teams[i],
                        _result!.teams[i + 1],
                      ), // Add this
                ),
              ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TeamDisplayCard(
                  team: _result!.teams[i + 1],
                  color: color,
                  onTap:
                      () => _navigateToNewGame(
                        _result!.teams[i],
                        _result!.teams[i + 1],
                      ), // Add this
                ),
              ),
            ],
          ),
        );
      }
    }

    return matches;
  }

  String _getArabicNumber(int number) {
    const arabicNumbers = [
      'الأولى',
      'الثانية',
      'الثالثة',
      'الرابعة',
      'الخامسة',
      'السادسة',
      'السابعة',
      'الثامنة',
    ];
    return number <= arabicNumbers.length
        ? arabicNumbers[number - 1]
        : '$number';
  }

  void _navigateToNewGame(List<Player> team1, List<Player> team2) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => NewGamePage(
              prefilledTeam1Player1: team1[0].id,
              prefilledTeam1Player2: team1[1].id,
              prefilledTeam2Player1: team2[0].id,
              prefilledTeam2Player2: team2[1].id,
            ),
      ),
    );

    // Reload result after returning from new game page
    await _loadLastResult();
  }
}

class _PlayerSelectionDialog extends StatefulWidget {
  final List<Player> players;
  final Set<String> initialSelection;

  const _PlayerSelectionDialog({
    required this.players,
    required this.initialSelection,
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
                    return ListTile(
                      title: Text(player.name, textAlign: TextAlign.right),
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
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentSelection.clear();
                        });
                      },
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('إلغاء الكل'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentSelection.addAll(
                            widget.players.map((p) => p.id),
                          );
                        });
                      },
                      icon: const Icon(Icons.select_all, size: 18),
                      label: const Text('تحديد الكل'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed:
                          () => Navigator.pop(context, _currentSelection),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'حفظ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
