// ============== pages/home_page.dart ==============
import 'package:family_cards/pages/play_tab.dart';
import 'package:family_cards/pages/records_tab.dart';
import 'package:flutter/material.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final _tabs = [
    // Remove const since SettingsPage has onTap callbacks
    const PlayTab(),
    const RecordsTab(),
    const SettingsPage(), // Add this third tab
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForTab(_currentIndex)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'اللعب'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'السجلات'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }

  String _getTitleForTab(int index) {
    switch (index) {
      case 0:
        return 'اللعب';
      case 1:
        return 'السجلات';
      case 2:
        return 'الإعدادات';
      default:
        return 'اللعب';
    }
  }
}
