class AppConstants {
  // Database
  static const String databaseName = 'notes.db';
  static const int databaseVersion = 1;

  // Table Names
  static const String notesTable = 'notes';

  // Note Fields
  static const String noteId = 'id';
  static const String noteTitle = 'title';
  static const String noteContent = 'content';
  static const String noteCreatedAt = 'createdAt';
  static const String noteUpdatedAt = 'updatedAt';
  static const String noteCategory = 'category';
  static const String noteIsFavorite = 'isFavorite';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardElevation = 2.0;
  static const double borderRadius = 12.0;

  // Default Categories
  static const List<String> defaultCategories = [
    'Personal',
    'Work',
    'Ideas',
    'Shopping',
    'Travel',
    'Health',
    'Study',
  ];
}

class AppStrings {
  // App
  static const String appName = 'My Notes';

  // Home Screen
  static const String myNotes = 'My Notes';
  static const String searchNotes = 'Search notes...';
  static const String noNotesYet = 'No notes yet';
  static const String tapToCreateFirstNote =
      'Tap the + button to create your first note';
  static const String notesCount = 'notes';

  // Add/Edit Screen
  static const String newNote = 'New Note';
  static const String editNote = 'Edit Note';
  static const String title = 'Title';
  static const String content = 'Content';
  static const String category = 'Category (Optional)';
  static const String save = 'Save';
  static const String saveNote = 'Save Note';
  static const String updateNote = 'Update Note';
  static const String startWriting = 'Start writing your note...';
  static const String categoryHint = 'e.g., Work, Personal, Ideas';

  // Validation
  static const String pleaseEnterTitle = 'Please enter a title';
  static const String pleaseEnterContent = 'Please enter some content';

  // Actions
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';
  static const String deleteNote = 'Delete Note';
  static const String deleteConfirmation =
      'Are you sure you want to delete this note?';
  static const String toggleFavorites = 'Toggle Favorites';
  static const String clearFilters = 'Clear Filters';
  static const String all = 'All';

  // Messages
  static const String noteSavedSuccessfully = 'Note saved successfully';
  static const String noteUpdatedSuccessfully = 'Note updated successfully';
  static const String errorSavingNote = 'Error saving note';
}
