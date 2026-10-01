import 'package:flutter/material.dart';
import '../profile.dart';

// The person-icon menu in the AppBar. Kept separate from HomeScreen so the
// profile/logout logic doesn't clutter the main screen's build method.
class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const CircleAvatar(
        radius: 16,
        child: Icon(Icons.person),
      ),
      onSelected: (value) => _handleSelection(context, value),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'profile', child: Text('Profile')),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
    );
  }

  void _handleSelection(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
      case 'logout':
        // TODO(stage2): wire up real logout once auth exists
        break;
    }
  }
}
