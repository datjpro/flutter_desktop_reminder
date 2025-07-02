class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? category;
  final bool isFavorite;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.isFavorite = false,
  });

  // Convert Note to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'category': category,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  // Convert Map from database to Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      category: map['category'],
      isFavorite: map['isFavorite'] == 1,
    );
  }

  // Create a copy of Note with updated fields
  Note copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    bool? isFavorite,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, category: $category, isFavorite: $isFavorite}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          category == other.category &&
          isFavorite == other.isFavorite;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      category.hashCode ^
      isFavorite.hashCode;
}
