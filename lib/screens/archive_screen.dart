import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';
import '../services/supabase_service.dart';
 
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});
 
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}
 
class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Item> _items = [];
  bool isLoading = true;
  String? errorMessage;
 
  @override
  void initState() {
    super.initState();
    _loadItems();
  }
 
  Future<void> _loadItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final items = await SupabaseService.instance.getItems(archived: true);
      setState(() {
        _items = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Could not load the archive. Check your connection and try again.';
        isLoading = false;
      });
    }
  }
 
  Future<void> _restore(Item item) async {
    await SupabaseService.instance.setArchived(item.id, false);
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
      await SupabaseService.instance.deleteItem(item.id);
      _loadItems();
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage!),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _loadItems, child: const Text('Retry')),
                ],
              ),
            ) 
              : _items.isEmpty
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
 
