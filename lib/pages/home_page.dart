// ============== pages/home_page.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'games_history_page.dart';
import 'main_tab.dart';
import 'settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final _tabs = [
    const MainTab(),
    const GamesHistoryPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(gamesProvider);
    final gameCount = gamesAsync.maybeWhen(
      data: (games) => games.length,
      orElse: () => 0,
    );

    String getTitle() {
      switch (_currentIndex) {
        case 0:
          return 'لعبة الورق';
        case 1:
          return 'سجل المباريات';
        case 2:
          return 'الإعدادات';
        default:
          return 'لعبة الورق';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.accentTeal,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$gameCount'),
              backgroundColor: AppTheme.warningOrange,
              child: const Icon(Icons.history),
            ),
            label: 'السجل',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
