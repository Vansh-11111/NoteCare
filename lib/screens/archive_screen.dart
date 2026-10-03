import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';
import '../services/database_service.dart';
 
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});
 
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}
 
class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Item> _items = [];
 
  @override
  void initState() {
    super.initState();
    _loadItems();
  }
 
  Future<void> _loadItems() async {
    final items = await DatabaseService.instance.getItems(archived: true);
    setState(() {
      _items = items;
    });
  }
 
  Future<void> _restore(Item item) async {
    await DatabaseService.instance.setArchived(item.id, false);
    _loadItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restored "${item.title}"')),
      );
    }
  }
 
  Future<void> _confirmDelete(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: Text('"${item.title}" will be permanently deleted. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.instance.deleteItem(item.id);
      _loadItems();
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: _items.isEmpty
          ? const Center(child: Text('Archive is empty'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(
                    '${item.type} • Updated ${DateFormat('MMM d').format(item.updatedAt)}',
                  ),
                  // Using InkWell + Padding instead of IconButton here, same
                  // fix as home_screen.dart's trailing row — IconButton's
                  // forced 48x48 minimum tap target overflows this tight space.
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _restore(item),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.unarchive, size: 22),
                        ),
                      ),
                      InkWell(
                        onTap: () => _confirmDelete(item),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.delete, size: 20),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
 
