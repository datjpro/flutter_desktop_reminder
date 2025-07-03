import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/tag_input_widget.dart';
import '../widgets/priority_selector.dart';

class AddEditNoteScreenEnhanced extends StatefulWidget {
  final int? noteId;
  final DateTime? scheduledDate;
  final List<DateTime>? preSelectedDates;

  const AddEditNoteScreenEnhanced({
    super.key,
    this.noteId,
    this.scheduledDate,
    this.preSelectedDates,
  });

  @override
  State<AddEditNoteScreenEnhanced> createState() =>
      _AddEditNoteScreenEnhancedState();
}

class _AddEditNoteScreenEnhancedState extends State<AddEditNoteScreenEnhanced> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isFavorite = false;
  bool _isCompleted = false;
  bool _isLoading = false;
  int _priority = 2; // Medium priority by default
  List<String> _tags = [];
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  String? _reminderType;
  Note? _originalNote;

  @override
  void initState() {
    super.initState();
    _loadNote();
    _initializeFromParameters();
  }

  void _initializeFromParameters() {
    // If preSelectedDates are provided, set the first one as default scheduled date
    if (widget.preSelectedDates != null &&
        widget.preSelectedDates!.isNotEmpty) {
      _scheduledDate = widget.preSelectedDates!.first;
    } else if (widget.scheduledDate != null) {
      _scheduledDate = widget.scheduledDate;
    }
  }

  void _loadNote() {
    if (widget.noteId != null) {
      final notesProvider = context.read<NotesProvider>();
      _originalNote = notesProvider.getNoteById(widget.noteId!);
      if (_originalNote != null) {
        _titleController.text = _originalNote!.title;
        _contentController.text = _originalNote!.content;
        _categoryController.text = _originalNote!.category ?? '';
        _isFavorite = _originalNote!.isFavorite;
        _isCompleted = _originalNote!.isCompleted;
        _priority = _originalNote!.priority;
        _tags = List.from(_originalNote!.tags);
        _scheduledDate = _originalNote!.scheduledDate;
        if (_scheduledDate != null) {
          _scheduledTime = TimeOfDay.fromDateTime(_scheduledDate!);
        }
        _reminderType = _originalNote!.reminderType;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.noteId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Favorite toggle
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          // Completion toggle
          IconButton(
            icon: Icon(
              _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
              color: _isCompleted ? Colors.green : null,
            ),
            onPressed: () {
              setState(() {
                _isCompleted = !_isCompleted;
              });
            },
          ),
          // Save button
          TextButton(
            onPressed: _isLoading ? null : _saveNote,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Multi-date selection info
                      if (widget.preSelectedDates != null &&
                          widget.preSelectedDates!.isNotEmpty)
                        _buildSelectedDatesWidget(),

                      // Category and Priority Row
                      Row(
                        children: [
                          // Category Field
                          Expanded(
                            child: TextFormField(
                              controller: _categoryController,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                                hintText: 'Work, Personal, etc.',
                              ),
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Priority Selector
                          Expanded(
                            child: PrioritySelector(
                              priority: _priority,
                              onChanged: (priority) {
                                setState(() {
                                  _priority = priority;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      TagInputWidget(
                        tags: _tags,
                        onTagsChanged: (tags) {
                          setState(() {
                            _tags = tags;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Scheduled Date and Time
                      _buildDateTimeSection(),
                      const SizedBox(height: 16),

                      // Content Field
                      SizedBox(
                        height: 200,
                        child: TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                            hintText: 'Start writing your note...',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter some content';
                            }
                            return null;
                          },
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reminder Settings
                      _buildReminderSection(),
                    ],
                  ),
                ),
              ),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveNote,
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.save),
                  label: Text(isEditing ? 'Update Note' : 'Save Note'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_scheduledDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _scheduledDate = null;
                        _scheduledTime = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                // Date picker
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _scheduledDate != null
                          ? DateFormat('MMM dd, yyyy').format(_scheduledDate!)
                          : 'Pick Date',
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Time picker
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _scheduledDate != null ? _pickTime : null,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _scheduledTime != null
                          ? _scheduledTime!.format(context)
                          : 'Pick Time',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reminder',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _reminderType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Reminder Type',
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('No Reminder')),
                DropdownMenuItem(
                  value: 'notification',
                  child: Text('Notification'),
                ),
                DropdownMenuItem(value: 'email', child: Text('Email')),
              ],
              onChanged: (value) {
                setState(() {
                  _reminderType = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _scheduledDate = date;
        // Set default time if not already set
        if (_scheduledTime == null) {
          _scheduledTime = const TimeOfDay(hour: 9, minute: 0);
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (time != null) {
      setState(() {
        _scheduledTime = time;
      });
    }
  }

  DateTime? _getScheduledDateTime() {
    if (_scheduledDate == null) return null;

    final time = _scheduledTime ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(
      _scheduledDate!.year,
      _scheduledDate!.month,
      _scheduledDate!.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notesProvider = context.read<NotesProvider>();

      if (widget.noteId != null) {
        // Updating existing note
        final now = DateTime.now();
        final note = Note(
          id: widget.noteId,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category:
              _categoryController.text.trim().isEmpty
                  ? null
                  : _categoryController.text.trim(),
          tags: _tags,
          priority: _priority,
          isFavorite: _isFavorite,
          isCompleted: _isCompleted,
          scheduledDate: _getScheduledDateTime(),
          reminderType: _reminderType,
          createdAt: _originalNote?.createdAt ?? now,
          updatedAt: now,
        );

        await notesProvider.updateNote(note);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Creating new note(s)
        if (widget.preSelectedDates != null &&
            widget.preSelectedDates!.isNotEmpty) {
          // Create notes for multiple dates
          await _createNotesForMultipleDates(notesProvider);
        } else {
          // Create single note
          await _createSingleNote(notesProvider);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createSingleNote(NotesProvider notesProvider) async {
    final now = DateTime.now();
    final note = Note(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category:
          _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
      tags: _tags,
      priority: _priority,
      isFavorite: _isFavorite,
      isCompleted: _isCompleted,
      scheduledDate: _getScheduledDateTime(),
      reminderType: _reminderType,
      createdAt: now,
      updatedAt: now,
    );

    await notesProvider.addNote(note);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _createNotesForMultipleDates(NotesProvider notesProvider) async {
    // Show confirmation dialog first
    final confirmed = await _showMultiDateConfirmationDialog();
    if (!confirmed) return;

    final now = DateTime.now();
    int successCount = 0;

    for (final date in widget.preSelectedDates!) {
      final scheduledDateTime =
          _scheduledTime != null
              ? DateTime(
                date.year,
                date.month,
                date.day,
                _scheduledTime!.hour,
                _scheduledTime!.minute,
              )
              : date;

      final note = Note(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category:
            _categoryController.text.trim().isEmpty
                ? null
                : _categoryController.text.trim(),
        tags: _tags,
        priority: _priority,
        isFavorite: _isFavorite,
        isCompleted: _isCompleted,
        scheduledDate: scheduledDateTime,
        reminderType: _reminderType,
        createdAt: now,
        updatedAt: now,
      );

      try {
        await notesProvider.addNote(note);
        successCount++;
      } catch (e) {
        // Continue creating other notes even if one fails
        print('Failed to create note for $date: $e');
      }
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Created $successCount out of ${widget.preSelectedDates!.length} notes successfully',
          ),
          backgroundColor:
              successCount == widget.preSelectedDates!.length
                  ? Colors.green
                  : Colors.orange,
        ),
      );
    }
  }

  Future<bool> _showMultiDateConfirmationDialog() async {
    if (widget.preSelectedDates == null || widget.preSelectedDates!.isEmpty) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Notes for Multiple Days'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are about to create the same note for ${widget.preSelectedDates!.length} different days:',
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          widget.preSelectedDates!
                              .map(
                                (date) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    '• ${DateFormat('MMMM dd, yyyy').format(date)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Do you want to proceed?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Create Notes'),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  Widget _buildSelectedDatesWidget() {
    if (widget.preSelectedDates == null || widget.preSelectedDates!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Creating note for ${widget.preSelectedDates!.length} selected days',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                widget.preSelectedDates!
                    .map(
                      (date) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          DateFormat('MMM dd').format(date),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'This note will be created for each of these dates with the same content.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
