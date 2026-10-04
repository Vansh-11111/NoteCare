import 'package:flutter/material.dart';
import '../profile.dart';
import 'package:flutter/services.dart';

// The hamburger-menu drawer. Separated out so adding Bin/Theme/Exit later
// only touches this one file, not the whole HomeScreen.
class AppDrawer extends StatelessWidget {
  final VoidCallback onArchiveTap;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const AppDrawer({
    super.key,
    required this.onArchiveTap,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Text(
              'Menu',
              style: TextStyle(color: colorScheme.onPrimary, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archive'),
            onTap: (){
              Navigator.pop(context);
              onArchiveTap();
            },
          ),
          SwitchListTile(
            secondary: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode), 
            title: Text(themeMode == ThemeMode.dark ? 'Dark mode' : 'Light mode'),
            value: themeMode == ThemeMode.dark,
            onChanged: (_) => onToggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Exit App'),
            onTap: () async {
              Navigator.pop(context);
              /*final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Exit app?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Exit')),
                  ],
                ),
              );
              if (confirmed == true)*/ 
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
