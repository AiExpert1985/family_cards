// ============== pages/settings_page.dart ==============
import 'package:flutter/material.dart';
import 'players_page.dart';
import 'sync_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayersPage())),
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
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncPage())),
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
                  'الإصدار: v2.0.0',
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
