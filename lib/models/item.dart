// The core data model for everything saved in the app.
//
// type is a plain string ('note' | 'link' | 'image') rather than an enum
// stored directly, because SQLite has no enum type — a string is the
// simplest thing that works and is easy to read when debugging the DB.

class Item {
  final String id;
  final String type; // 'note', 'link', or 'image'
  final String title;
  final String content; // note text, a URL, or an image file path
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived; // "Bin" in your UI

  Item({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.archived = false,
  });

  // Creates a copy of this item with some fields replaced — used for edits,
  // since fields above are final (Dart favors immutable models).
  Item copyWith({
    String? title,
    String? content,
    List<String>? tags,
    DateTime? updatedAt,
    bool? archived,
  }) {
    return Item(
      id: id,
      type: type,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
    );
  }

  // Converts this item into a Map for sqflite to store.
  // Tags are a List<String> in Dart but SQLite has no array column type,
  // so they're joined into a single comma-separated string for storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'content': content,
      'tags': tags.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'archived': archived ? 1 : 0, // SQLite has no bool type, so 0/1
    };
  }

  // Rebuilds an Item from a raw database row (a Map<String, dynamic>).
  factory Item.fromMap(Map<String, dynamic> map) {
    final rawTags = map['tags'] as String? ?? '';
    return Item(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      tags: rawTags.isEmpty ? [] : rawTags.split(','),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      archived: (map['archived'] as int) == 1,
    );
  }
}
