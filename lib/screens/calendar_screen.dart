import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card_enhanced.dart';
import 'add_edit_note_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Note>> _selectedNotes;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
                _selectedNotes.value = _getNotesForDay(_selectedDay!);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedNotes.value = _getNotesForDay(selectedDay);
                    });
                  }
                },
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

          const Divider(height: 1),

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
                          Text(
                            'Notes for ${DateFormat('MMMM dd, yyyy').format(_selectedDay!)}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
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
            'for ${DateFormat('MMMM dd, yyyy').format(_selectedDay!)}',
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

  void _navigateToAddNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditNoteScreen()),
    ).then((_) {
      // Refresh the selected notes after returning
      setState(() {
        _selectedNotes.value = _getNotesForDay(_selectedDay!);
      });
    });
  }

  void _navigateToEditNote(BuildContext context, int noteId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(noteId: noteId),
      ),
    ).then((_) {
      // Refresh the selected notes after returning
      setState(() {
        _selectedNotes.value = _getNotesForDay(_selectedDay!);
      });
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
                  setState(() {
                    _selectedNotes.value = _getNotesForDay(_selectedDay!);
                  });
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
