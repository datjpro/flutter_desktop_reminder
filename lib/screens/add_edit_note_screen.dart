import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  final int? noteId;

  const AddEditNoteScreen({super.key, this.noteId});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isFavorite = false;
  bool _isLoading = false;
  Note? _originalNote;

  @override
  void initState() {
    super.initState();
    _loadNote();
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

              // Category Field
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                  hintText: 'e.g., Work, Personal, Ideas',
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              // Content Field
              Expanded(
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

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final note = Note(
        id: widget.noteId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category:
            _categoryController.text.trim().isEmpty
                ? null
                : _categoryController.text.trim(),
        isFavorite: _isFavorite,
        createdAt: _originalNote?.createdAt ?? now,
        updatedAt: now,
      );

      final notesProvider = context.read<NotesProvider>();

      if (widget.noteId != null) {
        await notesProvider.updateNote(note);
      } else {
        await notesProvider.addNote(note);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.noteId != null
                  ? 'Note updated successfully'
                  : 'Note saved successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
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
}
