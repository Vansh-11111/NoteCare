import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/item.dart';

// A single shared database connection for the whole app. Screens call
// methods on this service instead of touching SQLite directly.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'project_1.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items(
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            tags TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            archived INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<void> insertItem(Item item) async {
    final db = await database;
    await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setArchived(String id, bool archived) async {
    final db = await database;
    await db.update(
      'items',
      {
        'archived': archived ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fetches items, optionally filtered by archived state ("Bin"), a search
  // string (matched against title or content), and/or a specific tag.
  Future<List<Item>> getItems({
    bool? archived,
    String? searchQuery,
    String? tag,
  }) async {
    final db = await database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (archived != null) {
      whereClauses.add('archived = ?');
      whereArgs.add(archived ? 1 : 0);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(title LIKE ? OR content LIKE ?)');
      final likeQuery = '%${searchQuery.trim()}%';
      whereArgs.add(likeQuery);
      whereArgs.add(likeQuery);
    }
    if (tag != null && tag.trim().isNotEmpty) {
      whereClauses.add('tags LIKE ?');
      whereArgs.add('%$tag%');
    }

    final maps = await db.query(
      'items',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereClauses.isEmpty ? null : whereArgs,
      orderBy: 'updatedAt DESC',
    );

    return maps.map((m) => Item.fromMap(m)).toList();
  }

  // Fetches a single item by id — useful for a detail screen that needs to
  // refresh itself after returning from editing.
  Future<Item?> getItemById(String id) async {
    final db = await database;
    final maps = await db.query('items', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Item.fromMap(maps.first);
  }

  Future<List<String>> getAllTags() async {
    final items = await getItems();
    final tagSet = <String>{};
    for (final item in items) {
      tagSet.addAll(item.tags.where((t) => t.trim().isNotEmpty));
    }
    return tagSet.toList()..sort();
  }
}
