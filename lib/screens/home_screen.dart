import 'package:flutter/material.dart';
import 'package:project_1/services/supabase_service.dart';
import 'archive_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/profile_menu.dart';
import '../models/item.dart';
import 'edit_screen.dart';
import '../widgets/item_card.dart';


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
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> confirmDelete(Item item) async {
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
      await SupabaseService.instance.deleteItem(item.id);
      loadItems();
    }
  }

  Future<void> archive(Item item) async {
    await SupabaseService.instance.setArchived(item.id, true);
    loadItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archived "${item.title}"')),
      );
    }
  }

  Future<void> openArchive() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ArchiveScreen()),
    );
    loadItems(); 
  }

  Future<void> loadItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final items = await SupabaseService.instance.getItems(
        archived: false,
        searchQuery: _searchQuery,
        tag: selectedTag,
      );
      final tags = await SupabaseService.instance.getAllTags();
      setState(() {
        _items = items;
        allTags = tags;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Could not load your items. Check your connection and try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: AppDrawer(       
        onArchiveTap: openArchive,
        themeMode: widget.themeMode,
        onToggleTheme: widget.onToggleTheme,
      ),
      appBar: buildAppBar(context),
      body: _buildBody(context),
    );
  }

  // AppBar

  AppBar buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      centerTitle: true,
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      backgroundColor: colorScheme.primary,
      title: Text(
        'NoteCare',
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 22,
          ),
      ),
      actions: const [ProfileMenu()],
    );
  }
  // Body

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
                loadItems();
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
                  loadItems();
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
          const SizedBox(height: 15),
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
        loadItems();
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 12),
            FilledButton(onPressed: loadItems, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const AnimatedSwitcher(
        duration: Duration(milliseconds: 250),
        child: Center(
          key: ValueKey('empty'),
          child: Text('Nothing saved yet'),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: ListView.builder(
        key: ValueKey('${_searchQuery}_${selectedTag ?? 'all'}_${_items.length}'),
        itemCount: _items.length,
        padding: const EdgeInsets.only(top: 2),
        itemBuilder: (context, index) {
          final item = _items[index];
          return TweenAnimationBuilder<double>(
            key: ValueKey(item.id),
            duration: Duration(milliseconds: 260 + (index * 45).clamp(0, 220).toInt()),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: ItemCard(
              item: item,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 280),
                    reverseTransitionDuration: const Duration(milliseconds: 220),
                    pageBuilder: (_, animation, secondaryAnimation) =>
                        EditScreen(existingItem: item),
                    transitionsBuilder: (_, animation, secondaryAnimation, child) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      return FadeTransition(
                        opacity: curved,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(curved),
                          child: child,
                        ),
                      );
                    },
                  ),
                );
                if (result == true) loadItems();
              },
              onArchive: () => archive(item),
              onDelete: () => confirmDelete(item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        tween: Tween(begin: 0.82, end: 1),
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: FloatingActionButton(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 280),
                reverseTransitionDuration: const Duration(milliseconds: 220),
                pageBuilder: (_, animation, secondaryAnimation) =>
                    const EditScreen(),
                transitionsBuilder: (_, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
                      child: child,
                    ),
                  );
                },
              ),
            );
            if (result == true) loadItems();
          },
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}
