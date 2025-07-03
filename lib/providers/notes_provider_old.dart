import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../database/database_helper.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _showFavoritesOnly = false;

  List<Note> get notes => _filteredNotes;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get showFavoritesOnly => _showFavoritesOnly;

  // Load all notes from database
  Future<void> loadNotes() async {
    try {
      _notes = await _databaseHelper.getAllNotes();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    try {
      final id = await _databaseHelper.insertNote(note);
      final newNote = note.copyWith(id: id);
      _notes.insert(0, newNote);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding note: $e');
    }
  }

  // Update an existing note
  Future<void> updateNote(Note note) async {
    try {
      await _databaseHelper.updateNote(note);
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
    }
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
    try {
      await _databaseHelper.deleteNote(id);
      _notes.removeWhere((note) => note.id == id);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Note note) async {
    try {
      final updatedNote = note.copyWith(
        isFavorite: !note.isFavorite,
        updatedAt: DateTime.now(),
      );
      await updateNote(updatedNote);
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  // Search notes
  void searchNotes(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Show only favorites
  void toggleShowFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _showFavoritesOnly = false;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters to notes list
  void _applyFilters() {
    _filteredNotes =
        _notes.where((note) {
          // Search filter
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            if (!note.title.toLowerCase().contains(query) &&
                !note.content.toLowerCase().contains(query)) {
              return false;
            }
          }

          // Category filter
          if (_selectedCategory.isNotEmpty) {
            if (note.category != _selectedCategory) {
              return false;
            }
          }

          // Favorites filter
          if (_showFavoritesOnly && !note.isFavorite) {
            return false;
          }

          return true;
        }).toList();
  }

  // Get all categories
  Future<List<String>> getAllCategories() async {
    try {
      return await _databaseHelper.getAllCategories();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  // Get note by id
  Note? getNoteById(int id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get notes count
  int get notesCount => _notes.length;
  int get filteredNotesCount => _filteredNotes.length;
  int get favoritesCount => _notes.where((note) => note.isFavorite).length;
}
