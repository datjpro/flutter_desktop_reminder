import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import 'add_edit_note_screen_luxury.dart';

class CalendarScreenSimple extends StatefulWidget {
  const CalendarScreenSimple({super.key});

  @override
  State<CalendarScreenSimple> createState() => _CalendarScreenSimpleState();
}

class _CalendarScreenSimpleState extends State<CalendarScreenSimple> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  List<Note> _getNotesForDay(DateTime day) {
    return context.read<NotesProvider>().notes.where((note) {
      if (note.scheduledDate == null) return false;
      return isSameDay(note.scheduledDate!, day);
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            tooltip: 'Today',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Container(
            padding: const EdgeInsets.all(16),
            child: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                return TableCalendar<Note>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getNotesForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    markersMaxCount: 3,
                    markerDecoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: true,
                  ),
                  onDaySelected: _onDaySelected,
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
                    return isSameDay(_selectedDay, day);
                  },
                );
              },
            ),
          ),

          const Divider(),

          // Selected day's notes
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                final selectedNotes =
                    _selectedDay != null
                        ? _getNotesForDay(_selectedDay!)
                        : <Note>[];

                if (selectedNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes scheduled',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedDay != null
                              ? 'for ${DateFormat('MMMM dd, yyyy').format(_selectedDay!)}'
                              : 'for the selected day',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[500]),
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
                              _selectedDay != null
                                  ? 'Notes for ${DateFormat('MMMM dd, yyyy').format(_selectedDay!)}'
                                  : 'Notes',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '${selectedNotes.length} note${selectedNotes.length == 1 ? '' : 's'}',
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
                        itemCount: selectedNotes.length,
                        itemBuilder: (context, index) {
                          final note = selectedNotes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  note.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle:
                                    note.content.isNotEmpty
                                        ? Text(
                                          note.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                        : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (note.isFavorite)
                                      const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                    if (note.isCompleted)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected:
                                          (value) =>
                                              _handleNoteAction(value, note),
                                      itemBuilder:
                                          (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'favorite',
                                              child: Text('Toggle Favorite'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'complete',
                                              child: Text('Toggle Complete'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                    ),
                                  ],
                                ),
                                onTap: () => _navigateToEditNote(context, note),
                              ),
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

  void _navigateToAddNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddEditNoteScreenLuxury(scheduledDate: _selectedDay),
      ),
    );
  }

  void _navigateToEditNote(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreenLuxury(note: note),
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
