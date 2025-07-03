import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../database/database_helper.dart';

enum ViewMode { list, calendar, completed }
enum SortBy { dateCreated, dateUpdated, title, priority }

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  // Filter and search state
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedTag = '';
  bool _showFavoritesOnly = false;
  bool _showCompletedOnly = false;
  ViewMode _viewMode = ViewMode.list;
  SortBy _sortBy = SortBy.dateUpdated;
  int? _selectedPriority;
  DateTime? _selectedDate;

  // Getters
  List<Note> get notes => _filteredNotes;
  List<Note> get allNotes => _notes;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedTag => _selectedTag;
  bool get showFavoritesOnly => _showFavoritesOnly;
  bool get showCompletedOnly => _showCompletedOnly;
  ViewMode get viewMode => _viewMode;
  SortBy get sortBy => _sortBy;
  int? get selectedPriority => _selectedPriority;
  DateTime? get selectedDate => _selectedDate;

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
      rethrow;
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
      rethrow;
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
      rethrow;
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

  // Toggle completion status
  Future<void> toggleCompletion(Note note) async {
    try {
      final updatedNote = note.copyWith(
        isCompleted: !note.isCompleted,
        updatedAt: DateTime.now(),
      );
      await updateNote(updatedNote);
    } catch (e) {
      debugPrint('Error toggling completion: $e');
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

  // Filter by tag
  void filterByTag(String tag) {
    _selectedTag = tag;
    _applyFilters();
    notifyListeners();
  }

  // Filter by priority
  void filterByPriority(int? priority) {
    _selectedPriority = priority;
    _applyFilters();
    notifyListeners();
  }

  // Filter by date
  void filterByDate(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
    notifyListeners();
  }

  // Show only favorites
  void toggleShowFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    _applyFilters();
    notifyListeners();
  }

  // Show only completed
  void toggleShowCompletedOnly() {
    _showCompletedOnly = !_showCompletedOnly;
    _applyFilters();
    notifyListeners();
  }

  // Change view mode
  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    _applyFilters();
    notifyListeners();
  }

  // Change sort order
  void setSortBy(SortBy sortBy) {
    _sortBy = sortBy;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedTag = '';
    _showFavoritesOnly = false;
    _showCompletedOnly = false;
    _selectedPriority = null;
    _selectedDate = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters to notes list
  void _applyFilters() {
    _filteredNotes = _notes.where((note) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!note.title.toLowerCase().contains(query) &&
            !note.content.toLowerCase().contains(query) &&
            !note.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory.isNotEmpty) {
        if (note.category != _selectedCategory) {
          return false;
        }
      }

      // Tag filter
      if (_selectedTag.isNotEmpty) {
        if (!note.tags.contains(_selectedTag)) {
          return false;
        }
      }

      // Priority filter
      if (_selectedPriority != null) {
        if (note.priority != _selectedPriority) {
          return false;
        }
      }

      // Date filter
      if (_selectedDate != null) {
        if (note.scheduledDate == null ||
            !_isSameDay(note.scheduledDate!, _selectedDate!)) {
          return false;
        }
      }

      // Favorites filter
      if (_showFavoritesOnly && !note.isFavorite) {
        return false;
      }

      // Completed filter
      if (_showCompletedOnly && !note.isCompleted) {
        return false;
      }

      // View mode filter
      if (_viewMode == ViewMode.completed && !note.isCompleted) {
        return false;
      }

      return true;
    }).toList();

    // Apply sorting
    _filteredNotes.sort((a, b) {
      switch (_sortBy) {
        case SortBy.title:
          return a.title.compareTo(b.title);
        case SortBy.priority:
          return b.priority.compareTo(a.priority); // High priority first
        case SortBy.dateCreated:
          return b.createdAt.compareTo(a.createdAt);
        case SortBy.dateUpdated:
          return b.updatedAt.compareTo(a.updatedAt);
      }
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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

  // Get all tags
  Future<List<String>> getAllTags() async {
    try {
      return await _databaseHelper.getAllTags();
    } catch (e) {
      debugPrint('Error getting tags: $e');
      return [];
    }
  }

  // Get notes for specific date
  Future<List<Note>> getNotesForDate(DateTime date) async {
    try {
      return await _databaseHelper.getNotesForDate(date);
    } catch (e) {
      debugPrint('Error getting notes for date: $e');
      return [];
    }
  }

  // Get overdue notes
  Future<List<Note>> getOverdueNotes() async {
    try {
      return await _databaseHelper.getOverdueNotes();
    } catch (e) {
      debugPrint('Error getting overdue notes: $e');
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

  // Statistics
  int get notesCount => _notes.length;
  int get filteredNotesCount => _filteredNotes.length;
  int get favoritesCount => _notes.where((note) => note.isFavorite).length;
  int get completedCount => _notes.where((note) => note.isCompleted).length;
  int get overdueCount => _notes.where((note) => note.isOverdue).length;
}
