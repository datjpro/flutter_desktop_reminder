import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_chips.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load notes when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          Consumer<NotesProvider>(
            builder: (context, notesProvider, child) {
              return IconButton(
                icon: Icon(
                  notesProvider.showFavoritesOnly
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: notesProvider.showFavoritesOnly ? Colors.red : null,
                ),
                onPressed: () {
                  notesProvider.toggleShowFavoritesOnly();
                },
                tooltip: 'Toggle Favorites',
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear_filters':
                  context.read<NotesProvider>().clearFilters();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear_filters',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear Filters'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SearchBarWidget(),
          ),

          // Category Chips
          const CategoryChips(),

          // Notes Grid
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                if (notesProvider.notes.isEmpty) {
                  return _buildEmptyState(context);
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MasonryGridView.builder(
                    gridDelegate:
                        const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: notesProvider.notes.length,
                    itemBuilder: (context, index) {
                      final note = notesProvider.notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () => _navigateToEditNote(context, note.id!),
                        onFavoriteToggle:
                            () => notesProvider.toggleFavorite(note),
                        onDelete: () => _showDeleteDialog(context, note.id!),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddNote(context),
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${notesProvider.filteredNotesCount} of ${notesProvider.notesCount} notes',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first note',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToAddNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
    );
  }

  void _navigateToEditNote(BuildContext context, int noteId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(noteId: noteId),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int noteId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<NotesProvider>().deleteNote(noteId);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
