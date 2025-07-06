import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/tag_input_widget.dart';
import '../widgets/priority_selector.dart';
import '../widgets/luxury_components.dart';
import '../widgets/luxury_clock_widget.dart';
import '../utils/modern_theme.dart';

class AddEditNoteScreenLuxury extends StatefulWidget {
  final Note? note;
  final DateTime? scheduledDate;
  final List<DateTime>? preSelectedDates;

  const AddEditNoteScreenLuxury({
    super.key,
    this.note,
    this.scheduledDate,
    this.preSelectedDates,
  });

  @override
  State<AddEditNoteScreenLuxury> createState() => _AddEditNoteScreenLuxuryState();
}

class _AddEditNoteScreenLuxuryState extends State<AddEditNoteScreenLuxury>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isFavorite = false;
  bool _isCompleted = false;
  bool _isLoading = false;
  int _priority = 2;
  List<String> _tags = [];
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  String? _reminderType;
  Note? _originalNote;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadNote();
    _initializeFromParameters();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeFromParameters() {
    if (widget.preSelectedDates != null && widget.preSelectedDates!.isNotEmpty) {
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
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.noteId != null;

    return Scaffold(
      backgroundColor: AppThemeEnhanced.backgroundLight,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppThemeEnhanced.primaryBlue,
              AppThemeEnhanced.primaryBlueDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar with Clock
              _buildLuxuryAppBar(isEditing),
              
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppThemeEnhanced.backgroundLight,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Multi-date selection info
                              if (widget.preSelectedDates != null &&
                                  widget.preSelectedDates!.isNotEmpty)
                                _buildSelectedDatesWidget(),

                              // Title Field
                              _buildTitleSection(),
                              const SizedBox(height: 24),

                              // Category and Priority
                              _buildCategoryPrioritySection(),
                              const SizedBox(height: 24),

                              // Tags Section
                              _buildTagsSection(),
                              const SizedBox(height: 24),

                              // Schedule Section
                              _buildScheduleSection(),
                              const SizedBox(height: 24),

                              // Content Section
                              _buildContentSection(),
                              const SizedBox(height: 24),

                              // Reminder Section
                              _buildReminderSection(),
                              const SizedBox(height: 32),

                              // Save Button
                              _buildSaveButton(isEditing),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryAppBar(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title and Clock
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Note' : 'Create Note',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Capture your thoughts',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Compact Clock
          const CompactClockWidget(
            size: 60,
            showDate: true,
            color: Colors.white,
          ),
          
          const SizedBox(width: 16),
          
          // Action Buttons
          Row(
            children: [
              // Favorite Toggle
              GestureDetector(
                onTap: () => setState(() => _isFavorite = !_isFavorite),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isFavorite 
                        ? AppThemeEnhanced.accentGold.withOpacity(0.3)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? AppThemeEnhanced.accentGold : Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Completed Toggle
              GestureDetector(
                onTap: () => setState(() => _isCompleted = !_isCompleted),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isCompleted 
                        ? AppThemeEnhanced.successColor.withOpacity(0.3)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                    color: _isCompleted ? AppThemeEnhanced.successColor : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDatesWidget() {
    if (widget.preSelectedDates == null || widget.preSelectedDates!.isEmpty) {
      return const SizedBox.shrink();
    }

    return LuxuryCard(
      gradient: AppThemeEnhanced.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_note, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Creating note for ${widget.preSelectedDates!.length} selected days',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.preSelectedDates!.map((date) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                DateFormat('MMM dd').format(date),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        LuxuryTextField(
          controller: _titleController,
          hint: 'Enter note title...',
          prefixIcon: Icons.title,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryPrioritySection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              LuxuryTextField(
                controller: _categoryController,
                hint: 'Work, Personal, etc.',
                prefixIcon: Icons.category,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Priority',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              PrioritySelector(
                priority: _priority,
                onChanged: (priority) => setState(() => _priority = priority),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TagInputWidget(
          tags: _tags,
          onTagsChanged: (tags) => setState(() => _tags = tags),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule, color: AppThemeEnhanced.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Schedule',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (_scheduledDate != null)
                GestureDetector(
                  onTap: () => setState(() {
                    _scheduledDate = null;
                    _scheduledTime = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppThemeEnhanced.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.clear,
                      color: AppThemeEnhanced.errorColor,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: LuxuryButton(
                  text: _scheduledDate != null
                      ? DateFormat('MMM dd, yyyy').format(_scheduledDate!)
                      : 'Pick Date',
                  icon: Icons.calendar_today,
                  isOutlined: true,
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LuxuryButton(
                  text: _scheduledTime != null
                      ? _scheduledTime!.format(context)
                      : 'Pick Time',
                  icon: Icons.access_time,
                  isOutlined: true,
                  onPressed: _scheduledDate != null ? _pickTime : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        LuxuryTextField(
          controller: _contentController,
          hint: 'Start writing your note...',
          maxLines: 8,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter some content';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications, color: AppThemeEnhanced.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Reminder',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _reminderType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('No Reminder')),
              DropdownMenuItem(value: 'notification', child: Text('Notification')),
              DropdownMenuItem(value: 'email', child: Text('Email')),
            ],
            onChanged: (value) => setState(() => _reminderType = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return LuxuryButton(
      text: isEditing ? 'Update Note' : 'Save Note',
      icon: Icons.save,
      isLoading: _isLoading,
      onPressed: _saveNote,
      width: double.infinity,
      height: 56,
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppThemeEnhanced.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _scheduledDate = date;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppThemeEnhanced.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notesProvider = context.read<NotesProvider>();

      if (widget.noteId != null) {
        await _updateExistingNote(notesProvider);
      } else {
        if (widget.preSelectedDates != null && widget.preSelectedDates!.isNotEmpty) {
          await _createNotesForMultipleDates(notesProvider);
        } else {
          await _createSingleNote(notesProvider);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
            backgroundColor: AppThemeEnhanced.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateExistingNote(NotesProvider notesProvider) async {
    final now = DateTime.now();
    final note = Note(
      id: widget.noteId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
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
          backgroundColor: AppThemeEnhanced.successColor,
        ),
      );
    }
  }

  Future<void> _createSingleNote(NotesProvider notesProvider) async {
    final now = DateTime.now();
    final note = Note(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
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
          backgroundColor: AppThemeEnhanced.successColor,
        ),
      );
    }
  }

  Future<void> _createNotesForMultipleDates(NotesProvider notesProvider) async {
    final confirmed = await _showMultiDateConfirmationDialog();
    if (!confirmed) return;

    final now = DateTime.now();
    int successCount = 0;

    for (final date in widget.preSelectedDates!) {
      final scheduledDateTime = _scheduledTime != null
          ? DateTime(date.year, date.month, date.day, _scheduledTime!.hour, _scheduledTime!.minute)
          : date;

      final note = Note(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
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
          backgroundColor: successCount == widget.preSelectedDates!.length
              ? AppThemeEnhanced.successColor
              : AppThemeEnhanced.warningColor,
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppThemeEnhanced.largeRadius),
        title: const Text('Create Notes for Multiple Days'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are about to create the same note for ${widget.preSelectedDates!.length} different days:',
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.preSelectedDates!.map((date) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: AppThemeEnhanced.primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(date),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Do you want to proceed?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          LuxuryButton(
            text: 'Create Notes',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
