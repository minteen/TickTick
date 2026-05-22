import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF4772E6);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static const priorityColors = {
    0: null, // No color
    1: Color(0xFF4A90D9), // Low - blue
    2: Color(0xFFF5A623), // Medium - orange
    3: Color(0xFFE74C3C), // High - red
  };

  static const listColors = [
    Color(0xFF4772E6),
    Color(0xFF50B86C),
    Color(0xFFF5A623),
    Color(0xFFE74C3C),
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
    Color(0xFFE67E22),
    Color(0xFF3498DB),
  ];
}
