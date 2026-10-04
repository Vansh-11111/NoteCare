
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';
 
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();
 
  SupabaseQueryBuilder get _items =>
      Supabase.instance.client.from('items');
 
  String get _uid {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('No logged-in user — cannot perform this operation.');
    }
    return user.id;
  }
 
  Map<String, dynamic> _toRow(Item item) {
    return {
      'id': item.id,
      'owner_id': _uid,
      'type': item.type,
      'title': item.title,
      'content': item.content,
      'tags': item.tags,
      'archived': item.archived,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
    };
  }
 
  Item _fromRow(Map<String, dynamic> row) {
    return Item(
      id: row['id'] as String,
      type: row['type'] as String,
      title: row['title'] as String,
      content: row['content'] as String? ?? '',
      tags: List<String>.from(row['tags'] as List? ?? []),
      archived: row['archived'] as bool,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
 
  Future<void> insertItem(Item item) async {
    await _items.insert(_toRow(item));
  }
 
  Future<void> updateItem(Item item) async {
    await _items
        .update(_toRow(item))
        .eq('id', item.id)
        .eq('owner_id', _uid);
  }
 
  Future<void> deleteItem(String id) async {
    await _items.delete().eq('id', id).eq('owner_id', _uid);
  }
 
  Future<void> setArchived(String id, bool archived) async {
    await _items
        .update({
          'archived': archived,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('owner_id', _uid);
  }
 
  Future<Item?> getItemById(String id) async {
    final row = await _items
        .select()
        .eq('id', id)
        .eq('owner_id', _uid)
        .maybeSingle();
    if (row == null) return null;
    return _fromRow(row);
  }
 
  Future<List<Item>> getItems({
    bool? archived,
    String? searchQuery,
    String? tag,
  }) async {
    var query = _items.select().eq('owner_id', _uid);
 
    if (archived != null) {
      query = query.eq('archived', archived);
    }
    if (tag != null && tag.isNotEmpty) {
      query = query.contains('tags', [tag]);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
        'title.ilike.%$searchQuery%,content.ilike.%$searchQuery%',
      );
    }
 
    final rows = await query.order('updated_at', ascending: false);
    return rows.map(_fromRow).toList();
  }
 
  Future<List<String>> getAllTags() async {
    final rows = await _items.select('tags').eq('owner_id', _uid);
    final allTags = <String>{};
    for (final row in rows) {
      final tags = row['tags'] as List?;
      if (tags != null) {
        allTags.addAll(tags.map((t) => t.toString()));
      }
    }
    return allTags.toList()..sort();
  }
}
 
