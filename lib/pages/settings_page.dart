// ============== pages/settings_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'players_page.dart';
import 'sync_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _resetApp(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'تأكيد إعادة التعيين',
              textAlign: TextAlign.right,
            ),
            content: const Text(
              'هل أنت متأكد من حذف جميع البيانات؟\n\nسيتم حذف:\n• جميع اللاعبين\n• جميع المباريات\n• جميع الإحصائيات\n\nلا يمكن التراجع عن هذا الإجراء!',
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('حذف الكل'),
              ),
            ],
          ),
    );

    if (confirm == true && context.mounted) {
      final storage = ref.read(storageServiceProvider);
      final success = await storage.clearAllData();

      if (success && context.mounted) {
        // Reload providers to reflect empty state
        await ref.read(playersProvider.notifier).loadPlayers();
        await ref.read(gamesProvider.notifier).loadGames();
        await ref.read(selectedPlayersProvider.notifier).loadSelectedPlayers();
        await ref.read(restedPlayersProvider.notifier).loadRestedPlayers();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف جميع البيانات بنجاح'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.people, color: Colors.blue, size: 32),
            title: const Text(
              'إدارة اللاعبين',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_back_ios, size: 16),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlayersPage()),
                ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sync, color: Colors.teal, size: 32),
            title: const Text(
              'مزامنة البيانات',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_back_ios, size: 16),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SyncPage()),
                ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.red.shade50,
          child: ListTile(
            leading: const Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: 32,
            ),
            title: const Text(
              'تصفير البرنامج',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            trailing: const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Colors.red,
            ),
            onTap: () => _resetApp(context, ref),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          color: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'حول التطبيق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.info_outline, color: Colors.grey.shade600),
                  ],
                ),
                const Divider(height: 24),
                const Text(
                  'المطور: محمد النوفل',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'الهاتف: 07701791983',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'الإصدار: v1.0.0',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
