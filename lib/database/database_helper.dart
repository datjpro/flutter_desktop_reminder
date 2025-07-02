import 'dart:io';
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
    // Initialize sqflite for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'notes.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    print('Creating database tables...');
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        category TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
    print('Database tables created successfully');
  }

  // Insert a new note
  Future<int> insertNote(Note note) async {
    try {
      final db = await database;
      print('Inserting note: ${note.title}');
      final id = await db.insert('notes', note.toMap());
      print('Note inserted with id: $id');
      return id;
    } catch (e) {
      print('Error inserting note: $e');
      rethrow;
    }
  }

  // Get all notes
  Future<List<Note>> getAllNotes() async {
    try {
      final db = await database;
      print('Getting all notes from database...');
      final List<Map<String, dynamic>> maps = await db.query(
        'notes',
        orderBy: 'updatedAt DESC',
      );

      print('Found ${maps.length} notes in database');
      return List.generate(maps.length, (i) {
        return Note.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting notes: $e');
      rethrow;
    }
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
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
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

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
