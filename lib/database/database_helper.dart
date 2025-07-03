import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'notes_enhanced.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        category TEXT,
        tags TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        scheduledDate INTEGER,
        priority INTEGER NOT NULL DEFAULT 2,
        reminderType TEXT
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Add new columns for enhanced features
      await db.execute('ALTER TABLE notes ADD COLUMN tags TEXT');
      await db.execute(
        'ALTER TABLE notes ADD COLUMN isCompleted INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute('ALTER TABLE notes ADD COLUMN scheduledDate INTEGER');
      await db.execute(
        'ALTER TABLE notes ADD COLUMN priority INTEGER NOT NULL DEFAULT 2',
      );
      await db.execute('ALTER TABLE notes ADD COLUMN reminderType TEXT');
    }
  }

  // Insert a new note
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  // Get all notes
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'updatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Get note by id
  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // Update note
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete note
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Search notes
  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Get notes by category
  Future<List<Note>> getNotesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'updatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Get favorite notes
  Future<List<Note>> getFavoriteNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'updatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Get all categories
  Future<List<String>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM notes WHERE category IS NOT NULL AND category != ""',
    );

    return maps.map((map) => map['category'] as String).toList();
  }

  // Get completed notes
  Future<List<Note>> getCompletedNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'isCompleted = ?',
      whereArgs: [1],
      orderBy: 'updatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Get notes by date range
  Future<List<Note>> getNotesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'scheduledDate >= ? AND scheduledDate <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'scheduledDate ASC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Get notes for specific date
  Future<List<Note>> getNotesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await getNotesByDateRange(startOfDay, endOfDay);
  }

  // Get overdue notes
  Future<List<Note>> getOverdueNotes() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where:
          'scheduledDate < ? AND isCompleted = 0 AND scheduledDate IS NOT NULL',
      whereArgs: [now],
      orderBy: 'scheduledDate ASC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Get all tags
  Future<List<String>> getAllTags() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT tags FROM notes WHERE tags IS NOT NULL AND tags != ""',
    );

    final Set<String> allTags = {};
    for (final map in maps) {
      final tags = map['tags'] as String;
      allTags.addAll(tags.split(',').where((tag) => tag.isNotEmpty));
    }

    return allTags.toList()..sort();
  }

  // Get notes by tag
  Future<List<Note>> getNotesByTag(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
      orderBy: 'updatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      final note = Note.fromMap(maps[i]);
      // Verify the tag actually exists in the note's tags
      if (note.tags.contains(tag)) {
        return note;
      }
      return null;
    }).where((note) => note != null).cast<Note>().toList();
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
