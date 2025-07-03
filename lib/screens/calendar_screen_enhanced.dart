import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card_enhanced.dart';
import 'add_edit_note_screen_enhanced.dart';

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
    return context.read<NotesProvider>().allNotes.where((note) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Multi-select toggle
          IconButton(
            icon: Icon(
              _isMultiSelectMode
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: _isMultiSelectMode ? Colors.blue : null,
            ),
            onPressed: () {
              setState(() {
                _isMultiSelectMode = !_isMultiSelectMode;
                if (!_isMultiSelectMode) {
                  _multiSelectedDays.clear();
                  _selectedNotes.value =
                      _selectedDay != null
                          ? _getNotesForDay(_selectedDay!)
                          : [];
                }
              });
            },
            tooltip:
                _isMultiSelectMode ? 'Exit Multi-select' : 'Multi-select Mode',
          ),
          // Range selection toggle
          IconButton(
            icon: Icon(
              Icons.date_range,
              color:
                  _rangeSelectionMode == RangeSelectionMode.toggledOn
                      ? Colors.blue
                      : null,
            ),
            onPressed: () {
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
                      _selectedDay != null
                          ? _getNotesForDay(_selectedDay!)
                          : [];
                }
              });
            },
            tooltip: 'Range Selection',
          ),
          // Today button
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
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
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Selection mode indicator
          if (_isMultiSelectMode ||
              _rangeSelectionMode == RangeSelectionMode.toggledOn)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    _isMultiSelectMode ? Icons.touch_app : Icons.date_range,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isMultiSelectMode
                        ? 'Multi-select mode: ${_multiSelectedDays.length} days selected'
                        : 'Range selection mode',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (_isMultiSelectMode && _multiSelectedDays.isNotEmpty)
                    TextButton(
                      onPressed:
                          () => setState(() => _multiSelectedDays.clear()),
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),

          // Calendar
          Consumer<NotesProvider>(
            builder: (context, notesProvider, child) {
              return TableCalendar<Note>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: _getNotesForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                rangeSelectionMode: _rangeSelectionMode,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  markersMaxCount: 3,
                  markerDecoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
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
          ),

          const Divider(height: 1),

          // Action buttons for multi-selection
          if ((_isMultiSelectMode && _multiSelectedDays.isNotEmpty) ||
              (_rangeStart != null && _rangeEnd != null))
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _createNoteForSelectedDays(),
                    icon: const Icon(Icons.add),
                    label: Text(
                      _isMultiSelectMode
                          ? 'Create Note for ${_multiSelectedDays.length} Days'
                          : 'Create Note for Range',
                    ),
                  ),
                  if (_isMultiSelectMode && _multiSelectedDays.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => _viewSelectedDaysNotes(),
                      icon: const Icon(Icons.view_list),
                      label: const Text('View All Notes'),
                    ),
                ],
              ),
            ),

          // Selected day's notes
          Expanded(
            child: ValueListenableBuilder<List<Note>>(
              valueListenable: _selectedNotes,
              builder: (context, notes, _) {
                if (notes.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _getHeaderText(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '${notes.length} note${notes.length == 1 ? '' : 's'}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    // Notes list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: NoteCardEnhanced(
                              note: note,
                              onTap:
                                  () => _navigateToEditNote(context, note.id!),
                              onFavoriteToggle:
                                  () => context
                                      .read<NotesProvider>()
                                      .toggleFavorite(note),
                              onCompletionToggle:
                                  () => context
                                      .read<NotesProvider>()
                                      .toggleCompletion(note),
                              onDelete:
                                  () => _showDeleteDialog(context, note.id!),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notes scheduled',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateSubtext(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddNote(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Note'),
          ),
        ],
      ),
    );
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
                  AddEditNoteScreenEnhanced(preSelectedDates: targetDates),
        ),
      ).then((_) => _refreshSelectedNotes());
    }
  }

  void _viewSelectedDaysNotes() {
    // Show a dialog or navigate to a view showing all notes from selected days
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Notes for ${_multiSelectedDays.length} Selected Days'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: _multiSelectedDays.length,
                itemBuilder: (context, index) {
                  final day = _multiSelectedDays.elementAt(index);
                  final dayNotes = _getNotesForDay(day);
                  return ExpansionTile(
                    title: Text(DateFormat('MMMM dd, yyyy').format(day)),
                    subtitle: Text('${dayNotes.length} note(s)'),
                    children:
                        dayNotes
                            .map(
                              (note) => ListTile(
                                title: Text(note.title),
                                subtitle: Text(
                                  note.content.length > 50
                                      ? '${note.content.substring(0, 50)}...'
                                      : note.content,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _navigateToEditNote(context, note.id!);
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
                child: const Text('Close'),
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
            (context) => AddEditNoteScreenEnhanced(
              scheduledDate: preSelectedDate,
              preSelectedDates: preSelectedDates,
            ),
      ),
    ).then((_) => _refreshSelectedNotes());
  }

  void _navigateToEditNote(BuildContext context, int noteId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreenEnhanced(noteId: noteId),
      ),
    ).then((_) => _refreshSelectedNotes());
  }

  void _refreshSelectedNotes() {
    setState(() {
      _selectedNotes.value = _getNotesForSelectedDays();
    });
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
                  _refreshSelectedNotes();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
