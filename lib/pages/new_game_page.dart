// ============== pages/new_game_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../providers/providers.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/app_card.dart';

class NewGamePage extends ConsumerStatefulWidget {
  final String? prefilledTeam1Player1;
  final String? prefilledTeam1Player2;
  final String? prefilledTeam2Player1;
  final String? prefilledTeam2Player2;
  final Game? gameToEdit;

  const NewGamePage({
    super.key,
    this.prefilledTeam1Player1,
    this.prefilledTeam1Player2,
    this.prefilledTeam2Player1,
    this.prefilledTeam2Player2,
    this.gameToEdit,
  });

  @override
  ConsumerState<NewGamePage> createState() => _NewGamePageState();
}

class _NewGamePageState extends ConsumerState<NewGamePage> {
  String? t1p1, t1p2, t2p1, t2p2;
  bool isKonkan = false;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();
  int? _winningTeam;

  @override
  void initState() {
    super.initState();
    if (widget.gameToEdit != null) {
      final game = widget.gameToEdit!;
      t1p1 = game.team1Player1;
      t1p2 = game.team1Player2;
      t2p1 = game.team2Player1;
      t2p2 = game.team2Player2;
      isKonkan = game.isKonkan;
      _selectedDate = game.date;
      _winningTeam = game.winningTeam;
    } else {
      t1p1 = widget.prefilledTeam1Player1;
      t1p2 = widget.prefilledTeam1Player2;
      t2p1 = widget.prefilledTeam2Player1;
      t2p2 = widget.prefilledTeam2Player2;
    }
  }

  Future<void> _autoSave() async {
    if (widget.gameToEdit == null) return;
    if (t1p1 == null || t1p2 == null || t2p1 == null || t2p2 == null || _winningTeam == null) return;

    final game = Game(
      id: widget.gameToEdit!.id,
      date: _selectedDate,
      team1Player1: t1p1!,
      team1Player2: t1p2!,
      team2Player1: t2p1!,
      team2Player2: t2p2!,
      winningTeam: _winningTeam!,
      isKonkan: isKonkan,
    );

    await ref.read(gamesProvider.notifier).updateGame(game);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate.isAfter(now) ? now : _selectedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    final currentTime = DateTime.now();

    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentTime.hour,
        currentTime.minute,
        currentTime.second,
        currentTime.millisecond,
        currentTime.microsecond,
      );
    });
    _autoSave();
  }

  Future<void> _saveGame(int winningTeam) async {
    if (t1p1 == null || t1p2 == null || t2p1 == null || t2p2 == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء اختيار جميع اللاعبين'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
      _winningTeam = winningTeam;
    });

    final game = Game(
      id: widget.gameToEdit?.id ?? '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}',
      date: _selectedDate,
      team1Player1: t1p1!,
      team1Player2: t1p2!,
      team2Player1: t2p1!,
      team2Player2: t2p2!,
      winningTeam: winningTeam,
      isKonkan: isKonkan,
    );

    final isEdit = widget.gameToEdit != null;
    final success = isEdit
        ? await ref.read(gamesProvider.notifier).updateGame(game)
        : await ref.read(gamesProvider.notifier).addGame(game);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      if (!isEdit) {
        final wasPreFilled = widget.prefilledTeam1Player1 != null;
        if (wasPreFilled) {
          final storage = ref.read(storageServiceProvider);
          await storage.removePlayedMatch(
            team1Player1: t1p1!,
            team1Player2: t1p2!,
            team2Player1: t2p1!,
            team2Player2: t2p2!,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'تم تحديث المباراة بنجاح' : 'تم حفظ اللعبة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameToEdit != null ? 'تعديل المباراة' : 'اضافة نتيجة مباراة'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: playersAsync.when(
        data: (players) {
          if (players.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              message: 'قم بإضافة اللاعبين أولاً',
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _TeamCard(
                      title: 'الفريق الأول',
                      color: Colors.blue,
                      players: players,
                      player1: t1p1,
                      player2: t1p2,
                      onPlayer1Changed: (v) {
                        setState(() => t1p1 = v);
                        _autoSave();
                      },
                      onPlayer2Changed: (v) {
                        setState(() => t1p2 = v);
                        _autoSave();
                      },
                    ),
                    const SizedBox(height: 20),
                    _TeamCard(
                      title: 'الفريق الثاني',
                      color: Colors.red,
                      players: players,
                      player1: t2p1,
                      player2: t2p2,
                      onPlayer1Changed: (v) {
                        setState(() => t2p1 = v);
                        _autoSave();
                      },
                      onPlayer2Changed: (v) {
                        setState(() => t2p2 = v);
                        _autoSave();
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 12,
                            ),
                            child: ListTile(
                              title: Text(
                                DateFormat('yyyy/MM/dd').format(_selectedDate),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: _isSaving ? null : _pickDate,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 12,
                            ),
                            child: SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'كونكان',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              value: isKonkan,
                              onChanged: _isSaving
                                  ? null
                                  : (value) {
                                      setState(() => isKonkan = value);
                                      _autoSave();
                                    },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Winner selection buttons - save directly
                    AppCard(
                      child: Column(
                        children: [
                          const Text(
                            'الفريق الفائز',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () {
                                          if (widget.gameToEdit != null) {
                                            setState(() => _winningTeam = 2);
                                            _autoSave();
                                          } else {
                                            _saveGame(2);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child:
                                      _isSaving
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Text('الفريق الثاني'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () {
                                          if (widget.gameToEdit != null) {
                                            setState(() => _winningTeam = 1);
                                            _autoSave();
                                          } else {
                                            _saveGame(1);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child:
                                      _isSaving
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Text('الفريق الأول'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(child: Text('خطأ: ${error.toString()}')),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<Player> players;
  final String? player1;
  final String? player2;
  final ValueChanged<String?> onPlayer1Changed;
  final ValueChanged<String?> onPlayer2Changed;

  const _TeamCard({
    required this.title,
    required this.color,
    required this.players,
    required this.player1,
    required this.player2,
    required this.onPlayer1Changed,
    required this.onPlayer2Changed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'اللاعب الأول',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: player1,
              items:
                  players
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
              onChanged: onPlayer1Changed,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'اللاعب الثاني',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: player2,
              items:
                  players
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id, child: Text(p.name)),
                      )
                      .toList(),
              onChanged: onPlayer2Changed,
            ),
          ],
        ),
      ),
    );
  }
}
