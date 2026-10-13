import 'package:flutter/material.dart';

class AppTheme {
  static const _accent = Color(0xFF14B8A6); 
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.light,     
      surfaceContainerLow: const Color(0xFFEFEFEF), 
    ).copyWith(
      surface: const Color(0xFFF5F5F5),
      surfaceContainer: const Color(0xFFEDEDED),
      surfaceContainerHighest: const Color(0xFFE3E3E3),
      onSurface: const Color(0xFF1A1A1A),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Color(0xFF14B8A6)),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.dark,  // light
      surfaceContainerLow: const Color(0xFF1A1A1A),   // dark
    ).copyWith(
      surface: const Color(0xFF121212),
      surfaceContainer: const Color(0xFF1C1C1C),
      surfaceContainerHighest: const Color(0xFF262626),
      onSurface: const Color(0xFFECECEC),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Color(0xFF14B8A6)),
    ),
  );
}