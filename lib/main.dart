import 'package:flutter/material.dart';
import 'package:project_1/screens/auth_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://byxvgnhamcrkeqninzdz.supabase.co',
    publishableKey: 'sb_publishable_jzWcQYuQJ70Ox7g71ew_rw_Zzd1J-wH',
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState(); 
}

  class _MainAppState extends State<MainApp> {
    ThemeMode _themeMode = ThemeMode.dark;
  
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
      home:StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context,snapshot) {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null){
            return HomeScreen(
              themeMode: _themeMode,
              onToggleTheme: _toggleTheme,
            );
          }
          return const AuthScreen();
        }
        )
    );
  }
}
