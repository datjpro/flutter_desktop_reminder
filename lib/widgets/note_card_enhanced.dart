import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import 'priority_selector.dart';

class NoteCardEnhanced extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onCompletionToggle;
  final VoidCallback onDelete;

  const NoteCardEnhanced({
    super.key,
    required this.note,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onCompletionToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      elevation: note.isCompleted ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with title, priority and actions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Priority indicator
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: PrioritySelector.getPriorityColor(
                            note.priority,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Title
                      Expanded(
                        child: Text(
                          note.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration:
                                note.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                            color: note.isCompleted ? Colors.grey[600] : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Completion toggle
                          GestureDetector(
                            onTap: onCompletionToggle,
                            child: Icon(
                              note.isCompleted
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color:
                                  note.isCompleted ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Favorite toggle
                          GestureDetector(
                            onTap: onFavoriteToggle,
                            child: Icon(
                              note.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: note.isFavorite ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Content preview
                  if (note.content.isNotEmpty)
                    Text(
                      note.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            note.isCompleted
                                ? Colors.grey[500]
                                : Colors.grey[600],
                        decoration:
                            note.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),

                  // Tags
                  if (note.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children:
                          note.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  const SizedBox(height: 8),

                  // Category chip
                  if (note.category != null && note.category!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        note.category!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Scheduled date
                  if (note.hasScheduledDate)
                    Row(
                      children: [
                        Icon(
                          note.isOverdue ? Icons.warning : Icons.schedule,
                          size: 14,
                          color: note.isOverdue ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dateFormat.format(note.scheduledDate!)} • ${timeFormat.format(note.scheduledDate!)}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                note.isOverdue
                                    ? Colors.red
                                    : Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // Footer with date and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date
                      Text(
                        'Updated ${dateFormat.format(note.updatedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
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

            // Completed overlay
            if (note.isCompleted)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
