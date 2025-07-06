import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card_enhanced.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_chips.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/luxury_components.dart';
import '../widgets/luxury_clock_widget.dart';
import '../utils/modern_theme.dart';
import 'add_edit_note_screen_luxury.dart';
import 'calendar_screen_enhanced.dart';

enum ViewMode { grid, list, calendar }

class HomeScreenLuxury extends StatefulWidget {
  const HomeScreenLuxury({super.key});

  @override
  State<HomeScreenLuxury> createState() => _HomeScreenLuxuryState();
}

class _HomeScreenLuxuryState extends State<HomeScreenLuxury>
    with TickerProviderStateMixin {
  ViewMode _currentViewMode = ViewMode.grid;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // Load notes when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes();
    });
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutBack,
    ));

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));

    _fabAnimationController.forward();
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernAppTheme.backgroundGray,
      body: Container(
        decoration: const BoxDecoration(
          gradient: ModernAppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header with Clock
              _buildModernHeader(),
              
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppThemeEnhanced.backgroundLight,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search and Filter Bar
                      _buildSearchAndFilterBar(),
                      
                      // View Mode Selector
                      _buildViewModeSelector(),
                      
                      // Notes Content
                      Expanded(
                        child: _buildNotesContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildLuxuryFAB(),
    );
  }

  Widget _buildLuxuryHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Welcome Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Let\'s organize your thoughts',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Quick Stats
                        Consumer<NotesProvider>(
                          builder: (context, provider, _) {
                            return Row(
                              children: [
                                _buildStatItem('Total', provider.allNotes.length.toString()),
                                const SizedBox(width: 16),
                                _buildStatItem('Pending', provider.pendingNotes.length.toString()),
                                const SizedBox(width: 16),
                                _buildStatItem('Completed', provider.completedNotes.length.toString()),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Luxury Clock
                  const LuxuryClockWidget(
                    size: 120,
                    showDigital: true,
                    showDate: true,
                    primaryColor: Colors.white,
                    secondaryColor: AppThemeEnhanced.accentGold,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [AppThemeEnhanced.softShadow],
              ),
              child: SearchBarWidget(
                onChanged: (query) {
                  context.read<NotesProvider>().filterNotes(searchQuery: query);
                },
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Filter Button
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppThemeEnhanced.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [AppThemeEnhanced.softShadow],
              ),
              child: const Icon(
                Icons.tune,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildViewModeItem(ViewMode.grid, Icons.grid_view, 'Grid'),
          _buildViewModeItem(ViewMode.list, Icons.list, 'List'),
          _buildViewModeItem(ViewMode.calendar, Icons.calendar_today, 'Calendar'),
        ],
      ),
    );
  }

  Widget _buildViewModeItem(ViewMode mode, IconData icon, String label) {
    final isSelected = _currentViewMode == mode;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (mode == ViewMode.calendar) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CalendarScreenEnhanced(),
              ),
            );
          } else {
            setState(() {
              _currentViewMode = mode;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppThemeEnhanced.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesContent() {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        if (notesProvider.isLoading) {
          return const Center(
            child: LuxuryLoadingIndicator(
              message: 'Loading your notes...',
            ),
          );
        }

        final notes = notesProvider.filteredNotes;

        if (notes.isEmpty) {
          return _buildEmptyState();
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: _currentViewMode == ViewMode.grid
              ? _buildGridView(notes)
              : _buildListView(notes),
        );
      },
    );
  }

  Widget _buildGridView(List notes) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Hero(
          tag: 'note_${note.id}',
          child: LuxuryCard(
            onTap: () => _navigateToEditNote(note.id!),
            child: NoteCardEnhanced(
              note: note,
              onTap: () => _navigateToEditNote(note.id!),
              onFavoriteToggle: () => context.read<NotesProvider>().toggleFavorite(note),
              onCompletionToggle: () => context.read<NotesProvider>().toggleCompletion(note),
              onDelete: () => _showDeleteConfirmation(note.id!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(List notes) {
    return ListView.separated(
      itemCount: notes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = notes[index];
        return Hero(
          tag: 'note_${note.id}',
          child: LuxuryCard(
            onTap: () => _navigateToEditNote(note.id!),
            child: NoteCardEnhanced(
              note: note,
              onTap: () => _navigateToEditNote(note.id!),
              onFavoriteToggle: () => context.read<NotesProvider>().toggleFavorite(note),
              onCompletionToggle: () => context.read<NotesProvider>().toggleCompletion(note),
              onDelete: () => _showDeleteConfirmation(note.id!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppThemeEnhanced.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.note_add,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notes yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppThemeEnhanced.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start creating your first note',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppThemeEnhanced.textMuted,
            ),
          ),
          const SizedBox(height: 32),
          LuxuryButton(
            text: 'Create First Note',
            icon: Icons.add,
            onPressed: _navigateToAddNote,
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryFAB() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppThemeEnhanced.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppThemeEnhanced.mediumShadow],
            ),
            child: FloatingActionButton(
              onPressed: _navigateToAddNote,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToAddNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditNoteScreenLuxury(),
      ),
    );
  }

  void _navigateToEditNote(int noteId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreenLuxury(noteId: noteId),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        onFilterApplied: (filters) {
          // Apply filters to the notes provider
          context.read<NotesProvider>().applyFilters(filters);
        },
      ),
    );
  }

  void _showDeleteConfirmation(int noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppThemeEnhanced.largeRadius,
        ),
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          LuxuryButton(
            text: 'Delete',
            color: AppThemeEnhanced.errorColor,
            onPressed: () {
              context.read<NotesProvider>().deleteNote(noteId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note deleted successfully'),
                  backgroundColor: AppThemeEnhanced.successColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
