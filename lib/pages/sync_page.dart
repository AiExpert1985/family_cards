// ============== pages/sync_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({super.key});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  bool _isProcessing = false;

  Future<void> _exportData() async {
    setState(() => _isProcessing = true);

    // Wait for data to load if not already loaded
    final playersAsync = ref.read(playersProvider);
    final gamesAsync = ref.read(gamesProvider);

    // Reload if not loaded
    if (!playersAsync.hasValue) {
      await ref.read(playersProvider.notifier).loadPlayers();
    }
    if (!gamesAsync.hasValue) {
      await ref.read(gamesProvider.notifier).loadGames();
    }

    // Get the loaded data
    final players = ref.read(playersProvider).value ?? [];
    final games = ref.read(gamesProvider).value ?? [];

    if (players.isEmpty && games.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد بيانات للتصدير'), backgroundColor: Colors.orange),
        );
      }
      setState(() => _isProcessing = false);
      return;
    }

    final syncService = ref.read(syncServiceProvider);
    final filePath = await syncService.exportData(players: players, games: games);

    if (filePath != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تصدير ${players.length} لاعب و ${games.length} مباراة'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('فشل التصدير'), backgroundColor: Colors.red));
      }
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _importData() async {
    setState(() => _isProcessing = true);

    final currentPlayers = ref.read(playersProvider).value ?? [];
    final currentGames = ref.read(gamesProvider).value ?? [];
    final syncService = ref.read(syncServiceProvider);

    final result = await syncService.importAndMerge(
      currentPlayers: currentPlayers,
      currentGames: currentGames,
    );

    if (result != null) {
      await ref.read(playersProvider.notifier).updatePlayers(result['players']);
      await ref.read(gamesProvider.notifier).updateGames(result['games']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم الاستيراد: ${result['addedPlayers']} لاعب، ${result['addedGames']} مباراة',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('فشل الاستيراد'), backgroundColor: Colors.red));
      }
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مزامنة البيانات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sync, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'تصدير واستيراد البيانات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'شارك بياناتك مع الآخرين أو قم بدمج بيانات من جهاز آخر',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _exportData,
                  icon: const Icon(Icons.upload),
                  label: const Text('تصدير البيانات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _importData,
                  icon: const Icon(Icons.download),
                  label: const Text('استيراد ودمج البيانات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
