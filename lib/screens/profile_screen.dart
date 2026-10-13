import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
 
  Future<void> _changeEmail(BuildContext context) async {
    final controller = TextEditingController();
    final newEmail = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change email'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New email'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
 
    if (newEmail == null || newEmail.isEmpty) return;
 
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: newEmail),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your new email to confirm the change.'),
          ),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
 
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Profile')
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.person, size: 36, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(user?.email ?? 'Unknown'),
          ),
          if (user?.createdAt != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Member since'),
              subtitle: Text(
                DateFormat('MMM d, yyyy').format(DateTime.parse(user!.createdAt)),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _changeEmail(context),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Change email'),
          ),
          OutlinedButton.icon(
            onPressed: () async{ 
              await Supabase.instance.client.auth.signOut();
              if(context.mounted){
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            icon: const Icon(Icons.logout_outlined),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "You'll need to confirm the change from a link sent to your new email before it takes effect.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings Page'),
      ),
    );
  }
}

