// ============== main.dart ==============
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const ProviderScope(child: CardGameApp()));
}

class CardGameApp extends StatelessWidget {
  const CardGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'هلا بالشريج',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
cardTheme: CardThemeData(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
),
      ),
      home: const HomePage(),
    );
  }
}
