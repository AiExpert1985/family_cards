// ============== widgets/teams/manual_rest_manager_sheet.dart ==============
import 'package:flutter/material.dart';

import '../../models/player.dart';

class ManualRestManagerSheet extends StatefulWidget {
  const ManualRestManagerSheet({
    super.key,
    required this.players,
    required this.initialRestingIds,
  });

  final List<Player> players;
  final Set<String> initialRestingIds;

  @override
  State<ManualRestManagerSheet> createState() => _ManualRestManagerSheetState();
}

class _ManualRestManagerSheetState extends State<ManualRestManagerSheet> {
  late Set<String> _currentRestingIds;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentRestingIds = {...widget.initialRestingIds};
  }

  void _togglePlayer(String playerId) {
    setState(() {
      if (_currentRestingIds.contains(playerId)) {
        _currentRestingIds.remove(playerId);
      } else {
        _currentRestingIds.add(playerId);
      }
    });
  }

  List<Player> get _filteredPlayers {
    if (_searchQuery.trim().isEmpty) {
      return widget.players;
    }

    final query = _searchQuery.toLowerCase();
    return widget.players
        .where((player) => player.name.toLowerCase().contains(query))
        .toList();
  }

  void _clearSelection() {
    setState(() {
      _currentRestingIds.clear();
    });
  }

  void _selectAll() {
    setState(() {
      _currentRestingIds = widget.players.map((player) => player.id).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.players.isEmpty) {
      return FractionallySizedBox(
        heightFactor: 0.5,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'لا يوجد لاعبين لإدارتهم',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(<String>{}),
                    child: const Text('إغلاق'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredPlayers = _filteredPlayers;

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: 42,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'إدارة اللاعبين المستريحين',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'ابحث عن لاعب',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearSelection,
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('إزالة الكل'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectAll,
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
                  const SizedBox(height: 8),
                  Text(
                    'عدد المستريحين: ${_currentRestingIds.length}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  filteredPlayers.isEmpty
                      ? const Center(
                        child: Text(
                          'لا يوجد نتائج مطابقة',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemBuilder: (context, index) {
                          final player = filteredPlayers[index];
                          final isResting = _currentRestingIds.contains(
                            player.id,
                          );
                          return ListTile(
                            onTap: () => _togglePlayer(player.id),
                            leading: Checkbox(
                              value: isResting,
                              onChanged: (_) => _togglePlayer(player.id),
                            ),
                            title: Text(
                              player.name,
                              textAlign: TextAlign.right,
                            ),
                            trailing:
                                isResting
                                    ? const Icon(
                                      Icons.pause_circle_filled,
                                      color: Colors.teal,
                                    )
                                    : null,
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemCount: filteredPlayers.length,
                      ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                    child: ElevatedButton(
                      onPressed:
                          () => Navigator.of(context).pop(_currentRestingIds),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'حفظ التعديلات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
