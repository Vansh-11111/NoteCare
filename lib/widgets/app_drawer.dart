import 'package:flutter/material.dart';
import '../profile.dart';

// The hamburger-menu drawer. Separated out so adding Bin/Theme/Exit later
// only touches this one file, not the whole HomeScreen.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
          // TODO: add "Bin" (archived items) ListTile here
          // TODO: add Theme (light/dark) toggle ListTile here
          // TODO: add "Exit app" ListTile here
        ],
      ),
    );
  }
}
