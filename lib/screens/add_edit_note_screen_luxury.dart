import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
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
  List<String> _tags = [];
  DateTime? _scheduledDate;
  List<DateTime> _selectedDates = [];

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeData() {
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _categoryController.text = widget.note!.category ?? '';
      _tags = List.from(widget.note!.tags);
      _scheduledDate = widget.note!.scheduledDate;
      _isFavorite = widget.note!.isFavorite;
      _isCompleted = widget.note!.isCompleted;
    }

    if (widget.scheduledDate != null) {
      _scheduledDate = widget.scheduledDate;
    }

    if (widget.preSelectedDates != null) {
      _selectedDates = List.from(widget.preSelectedDates!);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      backgroundColor: ModernAppTheme.backgroundGray,
      body: Container(
        decoration: const BoxDecoration(
          gradient: ModernAppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Modern Header
                _buildModernHeader(isEditing),
                
                // Content Area
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: ModernAppTheme.surfaceWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ModernAppTheme.space24),
                        topRight: Radius.circular(ModernAppTheme.space24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(ModernAppTheme.space20),
                      child: AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title Field
                                  _buildModernTextField(
                                    controller: _titleController,
                                    label: 'Title',
                                    hint: 'Enter note title...',
                                    icon: Icons.title,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter a title';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: ModernAppTheme.space20),
                                  
                                  // Content Field
                                  _buildModernTextField(
                                    controller: _contentController,
                                    label: 'Content',
                                    hint: 'Write your note content here...',
                                    icon: Icons.description,
                                    maxLines: 8,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter some content';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: ModernAppTheme.space20),
                                  
                                  // Category Field
                                  _buildModernTextField(
                                    controller: _categoryController,
                                    label: 'Category',
                                    hint: 'e.g., Work, Personal, Ideas...',
                                    icon: Icons.category,
                                  ),
                                  
                                  const SizedBox(height: ModernAppTheme.space20),
                                  
                                  // Tags Section
                                  _buildTagsSection(),
                                  
                                  const SizedBox(height: ModernAppTheme.space20),
                                  
                                  // Date Selection
                                  _buildDateSection(),
                                  
                                  const SizedBox(height: ModernAppTheme.space20),
                                  
                                  // Multi-Date Selection
                                  _buildMultiDateSection(),
                                  
                                  const SizedBox(height: ModernAppTheme.space20),
                                  
                                  // Options Section
                                  _buildOptionsSection(),
                                  
                                  const SizedBox(height: ModernAppTheme.space32),
                                  
                                  // Action Buttons
                                  _buildActionButtons(isEditing),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(ModernAppTheme.space20),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: ModernAppTheme.textDark.withOpacity(0.1),
                  borderRadius: ModernAppTheme.radiusMedium,
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: ModernAppTheme.textDark,
                  ),
                ),
              ),
              
              // Title
              Text(
                isEditing ? 'Edit Note' : 'New Note',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ModernAppTheme.textDark,
                ),
              ),
              
              // Compact Clock
              const CompactClockWidget(),
            ],
          ),
          
          const SizedBox(height: ModernAppTheme.space16),
          
          // Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                label: 'Favorite',
                isSelected: _isFavorite,
                onTap: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
              _buildQuickActionButton(
                icon: _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                label: 'Complete',
                isSelected: _isCompleted,
                onTap: () {
                  setState(() {
                    _isCompleted = !_isCompleted;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ModernAppTheme.space16,
          vertical: ModernAppTheme.space12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? ModernAppTheme.textDark.withOpacity(0.2)
              : ModernAppTheme.textDark.withOpacity(0.1),
          borderRadius: ModernAppTheme.radiusMedium,
          border: isSelected
              ? Border.all(
                  color: ModernAppTheme.textDark.withOpacity(0.3),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? ModernAppTheme.textDark
                  : ModernAppTheme.textDark.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: ModernAppTheme.space8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? ModernAppTheme.textDark
                    : ModernAppTheme.textDark.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ModernAppTheme.textDark,
          ),
        ),
        const SizedBox(height: ModernAppTheme.space8),
        Container(
          decoration: BoxDecoration(
            color: ModernAppTheme.surfaceGray,
            borderRadius: ModernAppTheme.radiusMedium,
            boxShadow: const [ModernAppTheme.lightShadow],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: ModernAppTheme.textLight),
              prefixIcon: Icon(icon, color: ModernAppTheme.primaryPurple),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(ModernAppTheme.space16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ModernAppTheme.textDark,
          ),
        ),
        const SizedBox(height: ModernAppTheme.space8),
        
        // Tags Input
        Container(
          decoration: BoxDecoration(
            color: ModernAppTheme.surfaceGray,
            borderRadius: ModernAppTheme.radiusMedium,
            boxShadow: const [ModernAppTheme.lightShadow],
          ),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Add tags (press Enter to add)',
              hintStyle: TextStyle(color: ModernAppTheme.textLight),
              prefixIcon: Icon(Icons.label, color: ModernAppTheme.primaryPurple),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(ModernAppTheme.space16),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty && !_tags.contains(value.trim())) {
                setState(() {
                  _tags.add(value.trim());
                });
              }
            },
          ),
        ),
        
        const SizedBox(height: ModernAppTheme.space12),
        
        // Tags Display
        if (_tags.isNotEmpty)
          Wrap(
            spacing: ModernAppTheme.space8,
            runSpacing: ModernAppTheme.space8,
            children: _tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ModernAppTheme.space12,
                  vertical: ModernAppTheme.space8,
                ),
                decoration: BoxDecoration(
                  color: ModernAppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: ModernAppTheme.radiusSmall,
                  border: Border.all(
                    color: ModernAppTheme.primaryPurple.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        color: ModernAppTheme.primaryPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: ModernAppTheme.space4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _tags.remove(tag);
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: ModernAppTheme.primaryPurple,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scheduled Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ModernAppTheme.textDark,
          ),
        ),
        const SizedBox(height: ModernAppTheme.space8),
        
        Container(
          decoration: BoxDecoration(
            color: ModernAppTheme.surfaceGray,
            borderRadius: ModernAppTheme.radiusMedium,
            boxShadow: const [ModernAppTheme.lightShadow],
          ),
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: ModernAppTheme.primaryPurple),
            title: Text(
              _scheduledDate != null
                  ? DateFormat('MMM dd, yyyy').format(_scheduledDate!)
                  : 'Select date',
              style: TextStyle(
                color: _scheduledDate != null
                    ? ModernAppTheme.textDark
                    : ModernAppTheme.textLight,
              ),
            ),
            trailing: _scheduledDate != null
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _scheduledDate = null;
                      });
                    },
                    icon: const Icon(Icons.clear, color: ModernAppTheme.errorRed),
                  )
                : null,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _scheduledDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _scheduledDate = date;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMultiDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Multiple Dates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ModernAppTheme.textDark,
              ),
            ),
            TextButton(
              onPressed: () async {
                final dates = await _showMultiDatePicker();
                if (dates != null) {
                  setState(() {
                    _selectedDates = dates;
                  });
                }
              },
              child: const Text(
                'Select Dates',
                style: TextStyle(color: ModernAppTheme.primaryPurple),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: ModernAppTheme.space8),
        
        if (_selectedDates.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(ModernAppTheme.space16),
            decoration: BoxDecoration(
              color: ModernAppTheme.surfaceGray,
              borderRadius: ModernAppTheme.radiusMedium,
              boxShadow: const [ModernAppTheme.lightShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedDates.length} dates selected',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: ModernAppTheme.textDark,
                  ),
                ),
                const SizedBox(height: ModernAppTheme.space8),
                Wrap(
                  spacing: ModernAppTheme.space8,
                  runSpacing: ModernAppTheme.space8,
                  children: _selectedDates.map((date) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ModernAppTheme.space12,
                        vertical: ModernAppTheme.space4,
                      ),
                      decoration: BoxDecoration(
                        color: ModernAppTheme.accentCyan.withOpacity(0.1),
                        borderRadius: ModernAppTheme.radiusSmall,
                        border: Border.all(
                          color: ModernAppTheme.accentCyan.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        DateFormat('MMM dd').format(date),
                        style: const TextStyle(
                          color: ModernAppTheme.accentCyan,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Container(
      padding: const EdgeInsets.all(ModernAppTheme.space16),
      decoration: BoxDecoration(
        color: ModernAppTheme.surfaceGray,
        borderRadius: ModernAppTheme.radiusMedium,
        boxShadow: const [ModernAppTheme.lightShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernAppTheme.textDark,
            ),
          ),
          const SizedBox(height: ModernAppTheme.space12),
          
          // Favorite Toggle
          Row(
            children: [
              Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? ModernAppTheme.errorRed : ModernAppTheme.textLight,
              ),
              const SizedBox(width: ModernAppTheme.space12),
              const Text(
                'Mark as Favorite',
                style: TextStyle(color: ModernAppTheme.textDark),
              ),
              const Spacer(),
              Switch(
                value: _isFavorite,
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
                activeColor: ModernAppTheme.primaryPurple,
              ),
            ],
          ),
          
          const SizedBox(height: ModernAppTheme.space12),
          
          // Completed Toggle
          Row(
            children: [
              Icon(
                _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                color: _isCompleted ? ModernAppTheme.successGreen : ModernAppTheme.textLight,
              ),
              const SizedBox(width: ModernAppTheme.space12),
              const Text(
                'Mark as Completed',
                style: TextStyle(color: ModernAppTheme.textDark),
              ),
              const Spacer(),
              Switch(
                value: _isCompleted,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value;
                  });
                },
                activeColor: ModernAppTheme.primaryPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    return Column(
      children: [
        // Save Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernAppTheme.primaryPurple,
              foregroundColor: ModernAppTheme.textDark,
              padding: const EdgeInsets.symmetric(vertical: ModernAppTheme.space16),
              shape: RoundedRectangleBorder(
                borderRadius: ModernAppTheme.radiusMedium,
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(ModernAppTheme.textDark),
                    ),
                  )
                : Text(
                    isEditing ? 'Update Note' : 'Save Note',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        
        const SizedBox(height: ModernAppTheme.space12),
        
        // Delete Button (only for editing)
        if (isEditing)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _showDeleteDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: ModernAppTheme.errorRed,
                side: const BorderSide(color: ModernAppTheme.errorRed),
                padding: const EdgeInsets.symmetric(vertical: ModernAppTheme.space16),
                shape: RoundedRectangleBorder(
                  borderRadius: ModernAppTheme.radiusMedium,
                ),
              ),
              child: const Text(
                'Delete Note',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<List<DateTime>?> _showMultiDatePicker() async {
    // Simple implementation - in a real app, you'd use a proper multi-date picker
    List<DateTime> selectedDates = List.from(_selectedDates);
    
    return showDialog<List<DateTime>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Multiple Dates'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: Column(
              children: [
                Text('Selected: ${selectedDates.length} dates'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null && !selectedDates.contains(date)) {
                      setState(() {
                        selectedDates.add(date);
                      });
                    }
                  },
                  child: const Text('Add Date'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedDates.length,
                    itemBuilder: (context, index) {
                      final date = selectedDates[index];
                      return ListTile(
                        title: Text(DateFormat('MMM dd, yyyy').format(date)),
                        trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              selectedDates.removeAt(index);
                            });
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, selectedDates),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final notesProvider = context.read<NotesProvider>();
      
      if (_selectedDates.isNotEmpty) {
        // Create multiple notes for each selected date
        for (final date in _selectedDates) {
          final note = Note(
            id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch + _selectedDates.indexOf(date),
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            category: _categoryController.text.trim(),
            tags: _tags,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            scheduledDate: date,
            isFavorite: _isFavorite,
            isCompleted: _isCompleted,
          );

          if (widget.note == null) {
            await notesProvider.addNote(note);
          } else {
            await notesProvider.updateNote(note);
          }
        }
      } else {
        // Create single note
        final note = Note(
          id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _categoryController.text.trim(),
          tags: _tags,
          createdAt: widget.note?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          scheduledDate: _scheduledDate,
          isFavorite: _isFavorite,
          isCompleted: _isCompleted,
        );

        if (widget.note == null) {
          await notesProvider.addNote(note);
        } else {
          await notesProvider.updateNote(note);
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.note == null ? 'Note created successfully' : 'Note updated successfully',
            ),
            backgroundColor: ModernAppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ModernAppTheme.errorRed,
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (widget.note != null) {
                await context.read<NotesProvider>().deleteNote(widget.note!.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note deleted successfully'),
                      backgroundColor: ModernAppTheme.successGreen,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: ModernAppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
