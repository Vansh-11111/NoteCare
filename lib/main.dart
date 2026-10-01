import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Follows the device's setting until you wire up a manual toggle.
      // TODO: make MainApp a StatefulWidget again once you add a manual
      // light/dark switch in the drawer — you'll need to hold a ThemeMode
      // variable here and pass a way to change it down to AppDrawer.
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
