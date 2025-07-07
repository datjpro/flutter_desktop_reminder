import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import '../providers/notes_provider.dart';
import '../models/note.dart';
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
  String _searchQuery = '';
  String? _selectedTag;

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
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

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

              // Content Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ModernAppTheme.surfaceWhite,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(ModernAppTheme.space24),
                      topRight: Radius.circular(ModernAppTheme.space24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search and Filter Section
                      _buildSearchAndFilter(),

                      // View Mode Selector
                      _buildViewModeSelector(),

                      // Notes Content
                      Expanded(child: _buildNotesContent()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditNoteScreenLuxury(),
                  ),
                );
              },
              backgroundColor: ModernAppTheme.primaryPurple,
              icon: const Icon(Icons.add, color: ModernAppTheme.textDark),
              label: const Text(
                'New Note',
                style: TextStyle(
                  color: ModernAppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _headerAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _headerAnimation.value)),
            child: Container(
              padding: const EdgeInsets.all(ModernAppTheme.space24),
              child: Column(
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Welcome Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: ModernAppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: ModernAppTheme.space8),
                            Text(
                              'Manage your notes with style',
                              style: TextStyle(
                                fontSize: 16,
                                color: ModernAppTheme.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Clock Widget
                      const LuxuryClockWidget(),
                    ],
                  ),

                  const SizedBox(height: ModernAppTheme.space24),

                  // Quick Stats
                  _buildQuickStats(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer<NotesProvider>(
      builder: (context, provider, child) {
        final totalNotes = provider.notes.length;
        final todayNotes =
            provider.notes.where((note) {
              final today = DateTime.now();
              return note.createdAt.day == today.day &&
                  note.createdAt.month == today.month &&
                  note.createdAt.year == today.year;
            }).length;

        return Container(
          padding: const EdgeInsets.all(ModernAppTheme.space20),
          decoration: BoxDecoration(
            color: ModernAppTheme.textDark.withOpacity(0.1),
            borderRadius: ModernAppTheme.radiusLarge,
            border: Border.all(color: ModernAppTheme.textDark.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Notes', totalNotes.toString()),
              _buildStatItem('Today', todayNotes.toString()),
              _buildStatItem(
                'Tags',
                _getAllTags(provider.notes).length.toString(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ModernAppTheme.textDark,
          ),
        ),
        const SizedBox(height: ModernAppTheme.space4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ModernAppTheme.textDark.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(ModernAppTheme.space16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: ModernAppTheme.surfaceGray,
              borderRadius: ModernAppTheme.radiusMedium,
              boxShadow: const [ModernAppTheme.lightShadow],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                hintStyle: TextStyle(color: ModernAppTheme.textLight),
                prefixIcon: Icon(Icons.search, color: ModernAppTheme.textLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ModernAppTheme.space16,
                  vertical: ModernAppTheme.space16,
                ),
              ),
            ),
          ),

          const SizedBox(height: ModernAppTheme.space16),

          // Tags Filter
          _buildTagsFilter(),
        ],
      ),
    );
  }

  Widget _buildTagsFilter() {
    return Consumer<NotesProvider>(
      builder: (context, provider, child) {
        final allTags = _getAllTags(provider.notes);

        if (allTags.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allTags.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: ModernAppTheme.space8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedTag == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTag = selected ? null : _selectedTag;
                      });
                    },
                    backgroundColor: ModernAppTheme.surfaceGray,
                    selectedColor: ModernAppTheme.primaryPurple,
                    labelStyle: TextStyle(
                      color:
                          _selectedTag == null
                              ? ModernAppTheme.textDark
                              : ModernAppTheme.textDark,
                    ),
                  ),
                );
              }

              final tag = allTags[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: ModernAppTheme.space8),
                child: FilterChip(
                  label: Text(tag),
                  selected: _selectedTag == tag,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTag = selected ? tag : null;
                    });
                  },
                  backgroundColor: ModernAppTheme.surfaceGray,
                  selectedColor: ModernAppTheme.primaryPurple,
                  labelStyle: TextStyle(
                    color:
                        _selectedTag == tag
                            ? ModernAppTheme.textDark
                            : ModernAppTheme.textDark,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildViewModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ModernAppTheme.space16),
      padding: const EdgeInsets.all(ModernAppTheme.space4),
      decoration: BoxDecoration(
        color: ModernAppTheme.surfaceGray,
        borderRadius: ModernAppTheme.radiusMedium,
      ),
      child: Row(
        children: [
          _buildViewModeButton(ViewMode.grid, Icons.grid_view, 'Grid'),
          _buildViewModeButton(ViewMode.list, Icons.list, 'List'),
          _buildViewModeButton(
            ViewMode.calendar,
            Icons.calendar_month,
            'Calendar',
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(ViewMode mode, IconData icon, String label) {
    final isSelected = _currentViewMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentViewMode = mode;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: ModernAppTheme.space12,
            vertical: ModernAppTheme.space8,
          ),
          decoration: BoxDecoration(
            color:
                isSelected ? ModernAppTheme.primaryPurple : Colors.transparent,
            borderRadius: ModernAppTheme.radiusSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? ModernAppTheme.textDark
                        : ModernAppTheme.textGray,
                size: 20,
              ),
              const SizedBox(width: ModernAppTheme.space8),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? ModernAppTheme.textDark
                          : ModernAppTheme.textGray,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
      builder: (context, provider, child) {
        final filteredNotes = _getFilteredNotes(provider.notes);

        if (filteredNotes.isEmpty) {
          return _buildEmptyState();
        }

        switch (_currentViewMode) {
          case ViewMode.grid:
            return _buildGridView(filteredNotes);
          case ViewMode.list:
            return _buildListView(filteredNotes);
          case ViewMode.calendar:
            return _buildCalendarView();
        }
      },
    );
  }

  Widget _buildGridView(List<Note> notes) {
    return Padding(
      padding: const EdgeInsets.all(ModernAppTheme.space16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: ModernAppTheme.space12,
        crossAxisSpacing: ModernAppTheme.space12,
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return _buildNoteCard(notes[index]);
        },
      ),
    );
  }

  Widget _buildListView(List<Note> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(ModernAppTheme.space16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: ModernAppTheme.space12),
          child: _buildNoteCard(notes[index]),
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return const CalendarScreenEnhanced();
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: ModernAppTheme.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: ModernAppTheme.surfaceWhite,
          borderRadius: ModernAppTheme.radiusMedium,
          boxShadow: const [ModernAppTheme.lightShadow],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditNoteScreenLuxury(note: note),
              ),
            );
          },
          borderRadius: ModernAppTheme.radiusMedium,
          child: Padding(
            padding: const EdgeInsets.all(ModernAppTheme.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ModernAppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: ModernAppTheme.space8),

                // Content
                Text(
                  note.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ModernAppTheme.textGray,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: ModernAppTheme.space12),

                // Tags
                if (note.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: ModernAppTheme.space4,
                    children:
                        note.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ModernAppTheme.space8,
                              vertical: ModernAppTheme.space4,
                            ),
                            decoration: BoxDecoration(
                              color: ModernAppTheme.primaryPurple.withOpacity(
                                0.1,
                              ),
                              borderRadius: ModernAppTheme.radiusSmall,
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 12,
                                color: ModernAppTheme.primaryPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: ModernAppTheme.space8),
                ],

                // Date
                Text(
                  DateFormat('MMM dd, yyyy').format(note.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: ModernAppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(ModernAppTheme.space24),
              decoration: BoxDecoration(
                color: ModernAppTheme.surfaceGray,
                borderRadius: ModernAppTheme.radiusXL,
              ),
              child: const Icon(
                Icons.note_alt_outlined,
                size: 64,
                color: ModernAppTheme.textLight,
              ),
            ),

            const SizedBox(height: ModernAppTheme.space24),

            const Text(
              'No notes yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: ModernAppTheme.textDark,
              ),
            ),

            const SizedBox(height: ModernAppTheme.space8),

            const Text(
              'Create your first note to get started',
              style: TextStyle(fontSize: 16, color: ModernAppTheme.textGray),
            ),
          ],
        ),
      ),
    );
  }

  List<Note> _getFilteredNotes(List<Note> notes) {
    List<Note> filteredNotes = notes;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredNotes =
          filteredNotes.where((note) {
            return note.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                note.content.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
    }

    // Filter by selected tag
    if (_selectedTag != null) {
      filteredNotes =
          filteredNotes.where((note) {
            return note.tags.contains(_selectedTag);
          }).toList();
    }

    return filteredNotes;
  }

  List<String> _getAllTags(List<Note> notes) {
    final Set<String> allTags = {};
    for (final note in notes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList()..sort();
  }
}
