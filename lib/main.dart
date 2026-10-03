import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp( MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
  
}

  class _MainAppState extends State<MainApp> {
    ThemeMode _themeMode = ThemeMode.light;
  
    void _toggleTheme() {
      setState(() {
        _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: HomeScreen(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
