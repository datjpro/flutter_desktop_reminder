import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and favorite button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Icon(
                      note.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: note.isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content preview
              if (note.content.isNotEmpty)
                Text(
                  note.content,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),

              // Category chip
              if (note.category != null && note.category!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    note.category!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // Footer with date and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date
                  Text(
                    '${dateFormat.format(note.updatedAt)} • ${timeFormat.format(note.updatedAt)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),

                  // Delete button
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
