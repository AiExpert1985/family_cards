// ============== theme/app_theme.dart ==============
import 'package:flutter/material.dart';

class AppTheme {
  // Modern color palette
  static const primaryPurple = Color(0xFF5E35B1);
  static const primaryBlue = Color(0xFF3949AB);
  static const accentTeal = Color(0xFF00BCD4);
  static const successGreen = Color(0xFF4CAF50);
  static const warningOrange = Color(0xFFFF9800);
  static const errorRed = Color(0xFFE53935);

  // Light theme colors
  static const lightBackground = Color(0xFFF5F7FA);
  static const lightSurface = Color(0xFFFFFFFF);

  // Dark theme colors
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);

  // Gradient definitions
  static const primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const warningGradient = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryPurple,
      secondary: accentTeal,
      surface: lightSurface,
      error: errorRed,
    ),
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: accentTeal,
      unselectedLabelColor: Colors.grey[600],
      indicatorSize: TabBarIndicatorSize.label,
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryPurple,
      secondary: accentTeal,
      surface: darkSurface,
      error: errorRed,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: accentTeal,
      unselectedLabelColor: Colors.grey[500],
      indicatorSize: TabBarIndicatorSize.label,
    ),
  );

  // Helper method to get win rate color
  static Color getWinRateColor(double winRate) {
    if (winRate >= 70) return successGreen;
    if (winRate >= 50) return warningOrange;
    return errorRed;
  }

  // Helper method to get rank color
  static Color getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return primaryBlue;
    }
  }
}
