class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? category;
  final List<String> tags;
  final bool isFavorite;
  final bool isCompleted;
  final DateTime? scheduledDate;
  final int priority; // 1: Low, 2: Medium, 3: High
  final String? reminderType; // 'none', 'notification', 'email'

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.tags = const [],
    this.isFavorite = false,
    this.isCompleted = false,
    this.scheduledDate,
    this.priority = 2,
    this.reminderType,
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
      'tags': tags.join(','), // Store tags as comma-separated string
      'isFavorite': isFavorite ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'scheduledDate': scheduledDate?.millisecondsSinceEpoch,
      'priority': priority,
      'reminderType': reminderType,
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
      tags: map['tags'] != null && map['tags'].toString().isNotEmpty
          ? map['tags'].toString().split(',').where((tag) => tag.trim().isNotEmpty).toList()
          : [],
      isFavorite: map['isFavorite'] == 1,
      isCompleted: map['isCompleted'] == 1,
      scheduledDate:
          map['scheduledDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['scheduledDate'])
              : null,
      priority: map['priority'] ?? 2,
      reminderType: map['reminderType'],
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
    List<String>? tags,
    bool? isFavorite,
    bool? isCompleted,
    DateTime? scheduledDate,
    int? priority,
    String? reminderType,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      priority: priority ?? this.priority,
      reminderType: reminderType ?? this.reminderType,
    );
  }

  // Helper getters
  String get priorityText {
    switch (priority) {
      case 1:
        return 'Low';
      case 3:
        return 'High';
      default:
        return 'Medium';
    }
  }

  bool get hasScheduledDate => scheduledDate != null;
  bool get isOverdue =>
      scheduledDate != null &&
      scheduledDate!.isBefore(DateTime.now()) &&
      !isCompleted;

  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, category: $category, tags: $tags, isFavorite: $isFavorite, isCompleted: $isCompleted, scheduledDate: $scheduledDate, priority: $priority, reminderType: $reminderType}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
