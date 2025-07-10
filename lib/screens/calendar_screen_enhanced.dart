import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import 'add_edit_note_screen_luxury.dart';

class CalendarScreenEnhanced extends StatefulWidget {
  const CalendarScreenEnhanced({super.key});

  @override
  State<CalendarScreenEnhanced> createState() => _CalendarScreenEnhancedState();
}

class _CalendarScreenEnhancedState extends State<CalendarScreenEnhanced> {
  late final ValueNotifier<List<Note>> _selectedNotes;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  Set<DateTime> _multiSelectedDays = <DateTime>{};
  bool _isMultiSelectMode = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedNotes = ValueNotifier(_getNotesForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedNotes.dispose();
    super.dispose();
  }

  List<Note> _getNotesForDay(DateTime day) {
    return context.read<NotesProvider>().notes.where((note) {
      if (note.scheduledDate == null) return false;
      return isSameDay(note.scheduledDate!, day);
    }).toList();
  }

  List<Note> _getNotesForSelectedDays() {
    final provider = context.read<NotesProvider>();
    List<Note> allSelectedNotes = [];

    if (_isMultiSelectMode && _multiSelectedDays.isNotEmpty) {
      for (final day in _multiSelectedDays) {
        allSelectedNotes.addAll(
          provider.allNotes.where((note) {
            if (note.scheduledDate == null) return false;
            return isSameDay(note.scheduledDate!, day);
          }),
        );
      }
    } else if (_selectedDay != null) {
      allSelectedNotes = _getNotesForDay(_selectedDay!);
    }

    return allSelectedNotes;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;

        if (_isMultiSelectMode) {
          if (_multiSelectedDays.contains(selectedDay)) {
            _multiSelectedDays.remove(selectedDay);
          } else {
            _multiSelectedDays.add(selectedDay);
          }
          _selectedNotes.value = _getNotesForSelectedDays();
        } else {
          _multiSelectedDays.clear();
          _selectedNotes.value = _getNotesForDay(selectedDay);
        }
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
      _multiSelectedDays.clear();

      if (start != null && end != null) {
        final daysInRange = _getDaysInRange(start, end);
        List<Note> rangeNotes = [];
        for (final day in daysInRange) {
          rangeNotes.addAll(_getNotesForDay(day));
        }
        _selectedNotes.value = rangeNotes;
      }
    });
  }

  List<DateTime> _getDaysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(start.add(Duration(days: i)));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isCompact = screenSize.width < 600 || screenSize.height < 600;
    final isVeryCompact = screenSize.width < 450 || screenSize.height < 450;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isVeryCompact ? 'Calendar' : 'Calendar View',
          style: TextStyle(fontSize: isVeryCompact ? 14 : 18),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: isVeryCompact ? 40 : (isCompact ? 48 : 56),
        actions: _buildAppBarActions(isCompact, isVeryCompact),
      ),
      body: Column(
        children: [
          // Selection mode indicator - compact version
          if (_isMultiSelectMode ||
              _rangeSelectionMode == RangeSelectionMode.toggledOn)
            _buildSelectionIndicator(isCompact, isVeryCompact),

          // Calendar with better constraints for small screens
          Expanded(
            flex: isVeryCompact ? 2 : 3,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isVeryCompact ? 4 : (isCompact ? 8 : 16),
                vertical: isVeryCompact ? 4 : 8,
              ),
              child: _buildCalendar(isCompact, isVeryCompact),
            ),
          ),

          // Divider
          Divider(height: isVeryCompact ? 0.5 : 1),

          // Action buttons - compact version
          if ((_isMultiSelectMode && _multiSelectedDays.isNotEmpty) ||
              (_rangeStart != null && _rangeEnd != null))
            _buildActionButtons(isCompact, isVeryCompact),

          // Selected day's notes - compact version
          Expanded(
            flex: isVeryCompact ? 1 : 2,
            child: _buildNotesSection(isCompact, isVeryCompact),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(isVeryCompact),
    );
  }

  List<Widget> _buildAppBarActions(bool isCompact, bool isVeryCompact) {
    if (isVeryCompact) {
      return [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: isVeryCompact ? 20 : 24),
          onSelected: _handleMenuAction,
          itemBuilder:
              (context) => [
                PopupMenuItem<String>(
                  value: 'multi_select',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isMultiSelectMode
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: _isMultiSelectMode ? Colors.blue : null,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isMultiSelectMode ? 'Exit Multi' : 'Multi-select',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'range_select',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.date_range,
                        color:
                            _rangeSelectionMode == RangeSelectionMode.toggledOn
                                ? Colors.blue
                                : null,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('Range', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'today',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.today, size: 16),
                      SizedBox(width: 8),
                      Text('Today', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
        ),
      ];
    } else if (isCompact) {
      return [
        IconButton(
          icon: Icon(
            _isMultiSelectMode
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: _isMultiSelectMode ? Colors.blue : null,
            size: 20,
          ),
          onPressed: () => _handleMenuAction('multi_select'),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: _handleMenuAction,
          itemBuilder:
              (context) => [
                PopupMenuItem<String>(
                  value: 'range_select',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.date_range,
                        color:
                            _rangeSelectionMode == RangeSelectionMode.toggledOn
                                ? Colors.blue
                                : null,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text('Range Selection'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'today',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.today, size: 18),
                      SizedBox(width: 8),
                      Text('Today'),
                    ],
                  ),
                ),
              ],
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(
            _isMultiSelectMode
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: _isMultiSelectMode ? Colors.blue : null,
          ),
          onPressed: () => _handleMenuAction('multi_select'),
          tooltip:
              _isMultiSelectMode ? 'Exit Multi-select' : 'Multi-select Mode',
        ),
        IconButton(
          icon: Icon(
            Icons.date_range,
            color:
                _rangeSelectionMode == RangeSelectionMode.toggledOn
                    ? Colors.blue
                    : null,
          ),
          onPressed: () => _handleMenuAction('range_select'),
          tooltip: 'Range Selection',
        ),
        IconButton(
          icon: const Icon(Icons.today),
          onPressed: () => _handleMenuAction('today'),
        ),
      ];
    }
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'multi_select':
        setState(() {
          _isMultiSelectMode = !_isMultiSelectMode;
          if (!_isMultiSelectMode) {
            _multiSelectedDays.clear();
            _selectedNotes.value =
                _selectedDay != null ? _getNotesForDay(_selectedDay!) : [];
          }
        });
        break;
      case 'range_select':
        setState(() {
          _rangeSelectionMode =
              _rangeSelectionMode == RangeSelectionMode.toggledOn
                  ? RangeSelectionMode.toggledOff
                  : RangeSelectionMode.toggledOn;
          _multiSelectedDays.clear();
          _isMultiSelectMode = false;
          if (_rangeSelectionMode == RangeSelectionMode.toggledOff) {
            _rangeStart = null;
            _rangeEnd = null;
            _selectedNotes.value =
                _selectedDay != null ? _getNotesForDay(_selectedDay!) : [];
          }
        });
        break;
      case 'today':
        setState(() {
          _focusedDay = DateTime.now();
          _selectedDay = DateTime.now();
          _rangeStart = null;
          _rangeEnd = null;
          _rangeSelectionMode = RangeSelectionMode.toggledOff;
          _multiSelectedDays.clear();
          _isMultiSelectMode = false;
          _selectedNotes.value = _getNotesForDay(_selectedDay!);
        });
        break;
    }
  }

  Widget _buildSelectionIndicator(bool isCompact, bool isVeryCompact) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isVeryCompact ? 4 : (isCompact ? 6 : 8)),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            _isMultiSelectMode ? Icons.touch_app : Icons.date_range,
            color: Colors.blue,
            size: isVeryCompact ? 14 : (isCompact ? 16 : 18),
          ),
          SizedBox(width: isVeryCompact ? 4 : 6),
          Expanded(
            child: Text(
              _isMultiSelectMode
                  ? '${_multiSelectedDays.length} selected'
                  : 'Range mode',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
                fontSize: isVeryCompact ? 10 : (isCompact ? 11 : 12),
              ),
            ),
          ),
          if (_isMultiSelectMode && _multiSelectedDays.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _multiSelectedDays.clear()),
              style: TextButton.styleFrom(
                minimumSize: Size(
                  isVeryCompact ? 30 : 40,
                  isVeryCompact ? 20 : 24,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isVeryCompact ? 4 : 6,
                ),
              ),
              child: Text(
                'Clear',
                style: TextStyle(fontSize: isVeryCompact ? 10 : 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar(bool isCompact, bool isVeryCompact) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return TableCalendar<Note>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat:
                  isVeryCompact ? CalendarFormat.week : _calendarFormat,
              availableCalendarFormats:
                  isVeryCompact
                      ? const {CalendarFormat.week: 'Week'}
                      : const {
                        CalendarFormat.month: 'Month',
                        CalendarFormat.twoWeeks: '2 weeks',
                        CalendarFormat.week: 'Week',
                      },
              eventLoader: _getNotesForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              rangeSelectionMode: _rangeSelectionMode,
              sixWeekMonthsEnforced: false,
              headerStyle: HeaderStyle(
                formatButtonVisible:
                    !isVeryCompact && constraints.maxWidth > 300,
                titleCentered: true,
                formatButtonShowsNext: false,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  size: isVeryCompact ? 14 : (isCompact ? 16 : 20),
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  size: isVeryCompact ? 14 : (isCompact ? 16 : 20),
                ),
                titleTextStyle: TextStyle(
                  fontSize: isVeryCompact ? 10 : (isCompact ? 12 : 16),
                  fontWeight: FontWeight.bold,
                ),
                formatButtonTextStyle: TextStyle(fontSize: isCompact ? 8 : 10),
                headerPadding: EdgeInsets.symmetric(
                  vertical: isVeryCompact ? 1 : 2,
                ),
                headerMargin: EdgeInsets.only(bottom: isVeryCompact ? 2 : 4),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: isVeryCompact ? 1 : (isCompact ? 2 : 3),
                cellMargin: EdgeInsets.all(
                  isVeryCompact ? 0.25 : (isCompact ? 0.5 : 1),
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                markerSize: isVeryCompact ? 2 : (isCompact ? 3 : 4),
                selectedDecoration: BoxDecoration(
                  color: _isMultiSelectMode ? Colors.blue : Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: Colors.deepPurple.withOpacity(0.2),
                withinRangeDecoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(
                  fontSize: isVeryCompact ? 8 : (isCompact ? 9 : 12),
                ),
                weekendTextStyle: TextStyle(
                  fontSize: isVeryCompact ? 8 : (isCompact ? 9 : 12),
                  color: Colors.red[400],
                ),
                holidayTextStyle: TextStyle(
                  fontSize: isVeryCompact ? 8 : (isCompact ? 9 : 12),
                ),
                tablePadding: EdgeInsets.symmetric(
                  horizontal: isVeryCompact ? 1 : (isCompact ? 2 : 4),
                  vertical: isVeryCompact ? 0.5 : (isCompact ? 1 : 2),
                ),
                canMarkersOverflow: false,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: isVeryCompact ? 7 : (isCompact ? 8 : 10),
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: TextStyle(
                  fontSize: isVeryCompact ? 7 : (isCompact ? 8 : 10),
                  fontWeight: FontWeight.bold,
                  color: Colors.red[400],
                ),
                decoration: const BoxDecoration(),
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  final text = DateFormat.E().format(day);
                  return Center(
                    child: Text(
                      isVeryCompact
                          ? text.substring(0, 1)
                          : text.substring(0, 2),
                      style: TextStyle(
                        fontSize: isVeryCompact ? 7 : (isCompact ? 8 : 10),
                        fontWeight: FontWeight.bold,
                        color:
                            day.weekday == DateTime.saturday ||
                                    day.weekday == DateTime.sunday
                                ? Colors.red[400]
                                : null,
                      ),
                    ),
                  );
                },
                defaultBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: EdgeInsets.all(isVeryCompact ? 0.5 : 1),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: isVeryCompact ? 8 : (isCompact ? 9 : 12),
                        color:
                            day.weekday == DateTime.saturday ||
                                    day.weekday == DateTime.sunday
                                ? Colors.red[400]
                                : null,
                      ),
                    ),
                  );
                },
              ),
              onDaySelected:
                  _rangeSelectionMode == RangeSelectionMode.toggledOff
                      ? _onDaySelected
                      : null,
              onRangeSelected:
                  _rangeSelectionMode == RangeSelectionMode.toggledOn
                      ? _onRangeSelected
                      : null,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              selectedDayPredicate: (day) {
                if (_isMultiSelectMode) {
                  return _multiSelectedDays.contains(day);
                }
                return isSameDay(_selectedDay, day);
              },
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons(bool isCompact, bool isVeryCompact) {
    return Container(
      padding: EdgeInsets.all(isVeryCompact ? 4 : (isCompact ? 8 : 12)),
      child:
          isVeryCompact
              ? Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => _createNoteForSelectedDays(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        'Create Note',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  if (_isMultiSelectMode && _multiSelectedDays.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 24,
                      child: OutlinedButton(
                        onPressed: () => _viewSelectedDaysNotes(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'View All',
                          style: TextStyle(fontSize: 9),
                        ),
                      ),
                    ),
                  ],
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _createNoteForSelectedDays(),
                      icon: Icon(Icons.add, size: isCompact ? 16 : 20),
                      label: Text(
                        isCompact
                            ? (_isMultiSelectMode
                                ? 'Create (${_multiSelectedDays.length})'
                                : 'Create Note')
                            : (_isMultiSelectMode
                                ? 'Create Note for ${_multiSelectedDays.length} Days'
                                : 'Create Note for Range'),
                        style: TextStyle(fontSize: isCompact ? 11 : 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 8 : 16,
                          vertical: isCompact ? 6 : 8,
                        ),
                      ),
                    ),
                  ),
                  if (_isMultiSelectMode && _multiSelectedDays.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewSelectedDaysNotes(),
                        icon: Icon(Icons.view_list, size: isCompact ? 16 : 20),
                        label: Text(
                          isCompact ? 'View All' : 'View All Notes',
                          style: TextStyle(fontSize: isCompact ? 11 : 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 8 : 16,
                            vertical: isCompact ? 6 : 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
    );
  }

  Widget _buildNotesSection(bool isCompact, bool isVeryCompact) {
    return ValueListenableBuilder<List<Note>>(
      valueListenable: _selectedNotes,
      builder: (context, notes, _) {
        if (notes.isEmpty) {
          return _buildEmptyState(isCompact, isVeryCompact);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(isVeryCompact ? 6 : (isCompact ? 8 : 12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getHeaderText(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isVeryCompact ? 12 : (isCompact ? 14 : 16),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${notes.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontSize: isVeryCompact ? 10 : (isCompact ? 11 : 12),
                    ),
                  ),
                ],
              ),
            ),

            // Notes list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: isVeryCompact ? 6 : (isCompact ? 8 : 12),
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: isVeryCompact ? 3 : (isCompact ? 4 : 6),
                    ),
                    child: _buildCompactNoteCard(
                      note,
                      isCompact,
                      isVeryCompact,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactNoteCard(Note note, bool isCompact, bool isVeryCompact) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isVeryCompact ? 6 : (isCompact ? 8 : 12),
          vertical: isVeryCompact ? 2 : (isCompact ? 4 : 6),
        ),
        title: Text(
          note.title,
          style: TextStyle(
            fontSize: isVeryCompact ? 11 : (isCompact ? 12 : 14),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle:
            note.content.isNotEmpty
                ? Text(
                  note.content,
                  style: TextStyle(
                    fontSize: isVeryCompact ? 9 : (isCompact ? 10 : 12),
                  ),
                  maxLines: isVeryCompact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                )
                : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.isFavorite)
              Icon(
                Icons.favorite,
                color: Colors.red,
                size: isVeryCompact ? 12 : (isCompact ? 14 : 16),
              ),
            if (note.isCompleted)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: isVeryCompact ? 12 : (isCompact ? 14 : 16),
              ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: isVeryCompact ? 14 : (isCompact ? 16 : 18),
              ),
              onSelected: (value) => _handleNoteAction(value, note),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'favorite',
                      child: Text('Toggle Favorite'),
                    ),
                    const PopupMenuItem(
                      value: 'complete',
                      child: Text('Toggle Complete'),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
            ),
          ],
        ),
        onTap: () => _navigateToEditNote(context, note),
      ),
    );
  }

  void _handleNoteAction(String action, Note note) {
    switch (action) {
      case 'edit':
        _navigateToEditNote(context, note);
        break;
      case 'favorite':
        context.read<NotesProvider>().toggleFavorite(note);
        break;
      case 'complete':
        context.read<NotesProvider>().toggleCompletion(note);
        break;
      case 'delete':
        _showDeleteDialog(context, note.id!);
        break;
    }
  }

  Widget _buildEmptyState(bool isCompact, bool isVeryCompact) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isVeryCompact ? 8 : (isCompact ? 12 : 16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: isVeryCompact ? 32 : (isCompact ? 48 : 64),
              color: Colors.grey[400],
            ),
            SizedBox(height: isVeryCompact ? 4 : (isCompact ? 8 : 12)),
            Text(
              'No notes scheduled',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontSize: isVeryCompact ? 12 : (isCompact ? 14 : 18),
              ),
            ),
            SizedBox(height: isVeryCompact ? 2 : (isCompact ? 4 : 6)),
            Text(
              _getEmptyStateSubtext(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
                fontSize: isVeryCompact ? 10 : (isCompact ? 11 : 13),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isVeryCompact ? 6 : (isCompact ? 8 : 12)),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddNote(context),
              icon: Icon(
                Icons.add,
                size: isVeryCompact ? 14 : (isCompact ? 16 : 20),
              ),
              label: Text(
                'Add Note',
                style: TextStyle(
                  fontSize: isVeryCompact ? 10 : (isCompact ? 12 : 14),
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isVeryCompact ? 8 : (isCompact ? 12 : 16),
                  vertical: isVeryCompact ? 4 : (isCompact ? 6 : 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isVeryCompact) {
    return FloatingActionButton(
      onPressed: () => _navigateToAddNote(context),
      tooltip: 'Add Note',
      mini: isVeryCompact,
      child: Icon(Icons.add, size: isVeryCompact ? 18 : 24),
    );
  }

  String _getHeaderText() {
    if (_isMultiSelectMode && _multiSelectedDays.isNotEmpty) {
      return 'Notes for ${_multiSelectedDays.length} selected days';
    } else if (_rangeStart != null && _rangeEnd != null) {
      return 'Notes from ${DateFormat('MMM dd').format(_rangeStart!)} to ${DateFormat('MMM dd, yyyy').format(_rangeEnd!)}';
    } else if (_selectedDay != null) {
      return 'Notes for ${DateFormat('MMMM dd, yyyy').format(_selectedDay!)}';
    }
    return 'Notes';
  }

  String _getEmptyStateSubtext() {
    if (_isMultiSelectMode && _multiSelectedDays.isNotEmpty) {
      return 'for the ${_multiSelectedDays.length} selected days';
    } else if (_rangeStart != null && _rangeEnd != null) {
      return 'for the selected date range';
    } else if (_selectedDay != null) {
      return 'for ${DateFormat('MMMM dd, yyyy').format(_selectedDay!)}';
    }
    return 'for the selected period';
  }

  void _createNoteForSelectedDays() {
    List<DateTime> targetDates = [];

    if (_isMultiSelectMode && _multiSelectedDays.isNotEmpty) {
      targetDates = _multiSelectedDays.toList();
    } else if (_rangeStart != null && _rangeEnd != null) {
      targetDates = _getDaysInRange(_rangeStart!, _rangeEnd!);
    }

    if (targetDates.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  AddEditNoteScreenLuxury(preSelectedDates: targetDates),
        ),
      ).then((_) => _refreshSelectedNotes());
    }
  }

  void _viewSelectedDaysNotes() {
    final screenSize = MediaQuery.of(context).size;
    final isVeryCompact = screenSize.width < 450 || screenSize.height < 450;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Notes for ${_multiSelectedDays.length} Selected Days',
              style: TextStyle(fontSize: isVeryCompact ? 14 : 16),
            ),
            content: SizedBox(
              width: isVeryCompact ? screenSize.width * 0.9 : double.maxFinite,
              height: isVeryCompact ? screenSize.height * 0.5 : 400,
              child: ListView.builder(
                itemCount: _multiSelectedDays.length,
                itemBuilder: (context, index) {
                  final day = _multiSelectedDays.elementAt(index);
                  final dayNotes = _getNotesForDay(day);
                  return ExpansionTile(
                    title: Text(
                      DateFormat(
                        isVeryCompact ? 'MMM dd, yyyy' : 'MMMM dd, yyyy',
                      ).format(day),
                      style: TextStyle(fontSize: isVeryCompact ? 12 : 14),
                    ),
                    subtitle: Text(
                      '${dayNotes.length} note(s)',
                      style: TextStyle(fontSize: isVeryCompact ? 10 : 12),
                    ),
                    children:
                        dayNotes
                            .map(
                              (note) => ListTile(
                                dense: isVeryCompact,
                                title: Text(
                                  note.title,
                                  style: TextStyle(
                                    fontSize: isVeryCompact ? 11 : 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  note.content.length >
                                          (isVeryCompact ? 30 : 50)
                                      ? '${note.content.substring(0, isVeryCompact ? 30 : 50)}...'
                                      : note.content,
                                  style: TextStyle(
                                    fontSize: isVeryCompact ? 9 : 11,
                                  ),
                                  maxLines: isVeryCompact ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _navigateToEditNote(context, note);
                                },
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(fontSize: isVeryCompact ? 12 : 14),
                ),
              ),
            ],
          ),
    );
  }

  void _navigateToAddNote(BuildContext context) {
    DateTime? preSelectedDate;
    List<DateTime>? preSelectedDates;

    if (_isMultiSelectMode && _multiSelectedDays.isNotEmpty) {
      preSelectedDates = _multiSelectedDays.toList();
    } else if (_rangeStart != null && _rangeEnd != null) {
      preSelectedDates = _getDaysInRange(_rangeStart!, _rangeEnd!);
    } else if (_selectedDay != null) {
      preSelectedDate = _selectedDay;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddEditNoteScreenLuxury(
              scheduledDate: preSelectedDate,
              preSelectedDates: preSelectedDates,
            ),
      ),
    ).then((_) => _refreshSelectedNotes());
  }

  void _navigateToEditNote(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreenLuxury(note: note),
      ),
    ).then((_) => _refreshSelectedNotes());
  }

  void _refreshSelectedNotes() {
    setState(() {
      _selectedNotes.value = _getNotesForSelectedDays();
    });
  }

  void _showDeleteDialog(BuildContext context, int noteId) {
    final screenSize = MediaQuery.of(context).size;
    final isVeryCompact = screenSize.width < 450 || screenSize.height < 450;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Note',
              style: TextStyle(fontSize: isVeryCompact ? 14 : 16),
            ),
            content: Text(
              'Are you sure you want to delete this note?',
              style: TextStyle(fontSize: isVeryCompact ? 12 : 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: isVeryCompact ? 12 : 14),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<NotesProvider>().deleteNote(noteId);
                  Navigator.pop(context);
                  _refreshSelectedNotes();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(fontSize: isVeryCompact ? 12 : 14),
                ),
              ),
            ],
          ),
    );
  }
}
