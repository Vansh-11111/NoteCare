import 'package:flutter/material.dart';
import 'archive_screen.dart';
import '../data.dart';
import '../widgets/app_drawer.dart';
import '../widgets/profile_menu.dart';
import '../widgets/nav_button.dart';
import '../models/item.dart';
import '../services/database_service.dart';
import 'edit_screen.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme; 
  
  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> _items = [];
  List<String> allTags = [];
  String _searchQuery = '';
  String? selectedTag;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _confirmDelete(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('"${item.title}" will be permanently deleted.'),
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

  Future<void> _archive(Item item) async {
    await DatabaseService.instance.setArchived(item.id, true);
    _loadItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archived "${item.title}"')),
      );
    }
  }

  Future<void> _openArchive() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ArchiveScreen()),
    );
    _loadItems(); 
  }

  Future<void> _loadItems() async {
    final items = await DatabaseService.instance.getItems(
      archived: false,
      searchQuery: _searchQuery,
      tag: selectedTag,
    );
    final tags = await DatabaseService.instance.getAllTags();
    setState(() {
      _items = items;
      allTags = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      drawer: AppDrawer(
        onArchiveTap: _openArchive,
        themeMode: widget.themeMode,
        onToggleTheme: widget.onToggleTheme,
        ),
      body: _buildBody(context),
    );
  }

  // ---------------------------------------------------------------------
  // AppBar
  // ---------------------------------------------------------------------

  AppBar _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      centerTitle: true,
      backgroundColor: colorScheme.primary,
      title: Text(
        'Project 1', // App Name
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontStyle: FontStyle.italic,
          fontSize: 22,
          decoration: TextDecoration.underline,
          decorationColor: colorScheme.onPrimary,
        ),
      ),
      actions: const [ProfileMenu()],
    );
  }

  // ---------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------

  Widget _buildTagFilter(BuildContext context) {
    if (allTags.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedTag == null,
              onSelected: (_) {
                setState(() => selectedTag = null);
                _loadItems();
              },
            ),
          ),
          ...allTags.map((tag) {
            final selected = selectedTag == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(tag),
                selected: selected,
                onSelected: (_) {
                  setState(() => selectedTag = selected ? null : tag);
                  _loadItems();
                },
              ),
            );
          }),
        ],
      ),
    );
  }


  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchField(context),
          const SizedBox(height: 15),
          _buildTagFilter(context),
          const SizedBox(height: 15,),
          _buildSectionLabel(context),
          Expanded(child: _buildItemList(context)),
          const SizedBox(height: 12),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(color: colorScheme.primary),
        prefixIcon: Icon(Icons.search, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (value) {
        _searchQuery = value;
        _loadItems();
      },
    );
  }

  Widget _buildSectionLabel(BuildContext context) {
    return Text(
      'Data Saved:',
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontStyle: FontStyle.italic,
        fontSize: 18,
      ),
    );
  }

  Widget _buildItemList(BuildContext context) {
    if (_items.isEmpty) {
      return const Center(child: Text('Nothing saved yet'));
    }
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(
            '${item.type} • Created ${DateFormat('MMM d, yyyy').format(item.createdAt)}',
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '• Updated ${DateFormat('MMM d').format(item.updatedAt)}',
                
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _archive(item),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.archive,size: 20),
                    )
                  ),
                  InkWell(
                    onTap: () => _confirmDelete(item),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.delete, size: 20),
                    ),
                  ), 
                ],
              )
            ],
          ),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditScreen(existingItem: item)),
            );
            if (result == true) _loadItems();
          },
        );
    },
  );
  }

  Widget _buildAddButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditScreen()),
          );
          if (result == true) _loadItems();
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
