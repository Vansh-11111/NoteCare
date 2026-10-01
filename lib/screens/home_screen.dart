import 'package:flutter/material.dart';
import '../data.dart';
import '../widgets/app_drawer.dart';
import '../widgets/profile_menu.dart';
import '../widgets/nav_button.dart';
import '../models/item.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> _items = [];

  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await DatabaseService.instance.getItems(archived: false);
    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: const AppDrawer(),
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
        'Project 1',
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

  Widget _buildBody(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchField(context),
          const SizedBox(height: 10),
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
      // TODO: onChanged -> filter _buildItemList's data by title/content
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
          subtitle: Text(item.type),
        // TODO: tapping this should eventually open your Data View screen
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
        onPressed: ()async{
          final now = DateTime.now();
          final testItem = Item(
            id: const Uuid().v4(),
            type: 'note',
            title: 'Test item ${_items.length + 1}',
            content: 'Hello from the FAB',
            tags: [],
            createdAt: now,
            updatedAt: now,
          );
          await DatabaseService.instance.insertItem(testItem);
          _loadItems();
        },
        child: const Icon(Icons.navigation),
      ),
    );
  }
}
