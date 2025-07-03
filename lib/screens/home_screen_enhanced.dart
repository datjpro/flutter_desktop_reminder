import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card_enhanced.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_chips.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'add_edit_note_screen.dart';
import 'calendar_screen_enhanced.dart';

class HomeScreenEnhanced extends StatefulWidget {
  const HomeScreenEnhanced({super.key});

  @override
  State<HomeScreenEnhanced> createState() => _HomeScreenEnhancedState();
}

class _HomeScreenEnhancedState extends State<HomeScreenEnhanced> {
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
        title: Consumer<NotesProvider>(
          builder: (context, notesProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Notes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (notesProvider.filteredNotesCount !=
                    notesProvider.notesCount)
                  Text(
                    '${notesProvider.filteredNotesCount} of ${notesProvider.notesCount}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          // View mode toggle
          Consumer<NotesProvider>(
            builder: (context, notesProvider, child) {
              return PopupMenuButton<ViewMode>(
                icon: Icon(_getViewModeIcon(notesProvider.viewMode)),
                onSelected: (mode) {
                  if (mode == ViewMode.calendar) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalendarScreenEnhanced(),
                      ),
                    );
                  } else {
                    notesProvider.setViewMode(mode);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: ViewMode.list,
                        child: Row(
                          children: [
                            Icon(Icons.view_list),
                            SizedBox(width: 8),
                            Text('List View'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: ViewMode.calendar,
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month),
                            SizedBox(width: 8),
                            Text('Calendar View'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: ViewMode.completed,
                        child: Row(
                          children: [
                            Icon(Icons.check_circle),
                            SizedBox(width: 8),
                            Text('Completed'),
                          ],
                        ),
                      ),
                    ],
              );
            },
          ),

          // Favorites toggle
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

          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const FilterBottomSheet(),
              );
            },
            tooltip: 'Filters',
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

          // Statistics Row
          Consumer<NotesProvider>(
            builder: (context, notesProvider, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Total',
                      notesProvider.notesCount.toString(),
                      Icons.note,
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'Favorites',
                      notesProvider.favoritesCount.toString(),
                      Icons.favorite,
                      Colors.red,
                    ),
                    _buildStatItem(
                      'Completed',
                      notesProvider.completedCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatItem(
                      'Overdue',
                      notesProvider.overdueCount.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Notes Grid
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                if (notesProvider.notes.isEmpty) {
                  return _buildEmptyState(context, notesProvider);
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
                      return NoteCardEnhanced(
                        note: note,
                        onTap: () => _navigateToEditNote(context, note.id!),
                        onFavoriteToggle:
                            () => notesProvider.toggleFavorite(note),
                        onCompletionToggle:
                            () => notesProvider.toggleCompletion(note),
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
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  IconData _getViewModeIcon(ViewMode mode) {
    switch (mode) {
      case ViewMode.calendar:
        return Icons.calendar_month;
      case ViewMode.completed:
        return Icons.check_circle;
      case ViewMode.list:
        return Icons.view_list;
    }
  }

  Widget _buildEmptyState(BuildContext context, NotesProvider notesProvider) {
    String title;
    String subtitle;
    IconData icon;

    if (notesProvider.searchQuery.isNotEmpty ||
        notesProvider.selectedCategory.isNotEmpty ||
        notesProvider.showFavoritesOnly ||
        notesProvider.viewMode == ViewMode.completed) {
      title = 'No matching notes';
      subtitle = 'Try adjusting your filters or search terms';
      icon = Icons.search_off;
    } else {
      title = 'No notes yet';
      subtitle = 'Tap the + button to create your first note';
      icon = Icons.note_add_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (notesProvider.searchQuery.isNotEmpty ||
              notesProvider.selectedCategory.isNotEmpty ||
              notesProvider.showFavoritesOnly)
            ElevatedButton.icon(
              onPressed: () => notesProvider.clearFilters(),
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
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
