import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../screens/home_screen_luxury.dart';
import '../screens/calendar_screen_enhanced.dart';
import '../screens/add_edit_note_screen_luxury.dart';

class MiniAppBar extends StatefulWidget {
  const MiniAppBar({super.key});

  @override
  State<MiniAppBar> createState() => _MiniAppBarState();
}

class _MiniAppBarState extends State<MiniAppBar> {
  bool _isExpanded = false;
  Offset _position = const Offset(20, 50);
  bool _isDragging = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _position = Offset(
        (_position.dx + details.delta.dx).clamp(
          0,
          MediaQuery.of(context).size.width - (_isExpanded ? 280 : 60),
        ),
        (_position.dy + details.delta.dy).clamp(
          0,
          MediaQuery.of(context).size.height - (_isExpanded ? 200 : 60),
        ),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Material(
          elevation: _isDragging ? 12 : 8,
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).colorScheme.primary,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isExpanded ? 280 : 60,
            height: _isExpanded ? 200 : 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isDragging ? 0.3 : 0.2),
                  blurRadius: _isDragging ? 15 : 10,
                  offset: Offset(0, _isDragging ? 8 : 5),
                ),
              ],
            ),
            child:
                _isExpanded
                    ? _buildExpandedContent()
                    : _buildCollapsedContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return InkWell(
      onTap: _toggleExpansion,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Consumer<NotesProvider>(
          builder: (context, notesProvider, child) {
            final todayNotesCount = notesProvider.getTodayNotes().length;
            return Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.note_alt,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
                if (todayNotesCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        todayNotesCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      children: [
        // Header
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.note_alt,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Notes App',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: _toggleExpansion,
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),

        // Quick stats
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                final todayNotes = notesProvider.getTodayNotes();
                final totalNotes = notesProvider.allNotes.length;
                final favoriteNotes =
                    notesProvider.allNotes
                        .where((note) => note.isFavorite)
                        .length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatItem('Hôm nay', todayNotes.length.toString()),
                    const SizedBox(height: 8),
                    _buildStatItem('Tổng cộng', totalNotes.toString()),
                    const SizedBox(height: 8),
                    _buildStatItem('Yêu thích', favoriteNotes.toString()),
                    const SizedBox(height: 16),

                    // Quick action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickButton(
                            icon: Icons.home,
                            label: 'Trang chủ',
                            onTap:
                                () =>
                                    _navigateToScreen(const HomeScreenLuxury()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuickButton(
                            icon: Icons.calendar_today,
                            label: 'Lịch',
                            onTap:
                                () => _navigateToScreen(
                                  const CalendarScreenEnhanced(),
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: _buildQuickButton(
                        icon: Icons.add,
                        label: 'Thêm ghi chú',
                        onTap:
                            () => _navigateToScreen(
                              const AddEditNoteScreenLuxury(),
                            ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
