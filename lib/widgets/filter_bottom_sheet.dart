import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import 'priority_selector.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      notesProvider.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sort By
              Text(
                'Sort By',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    SortBy.values.map((sortBy) {
                      return FilterChip(
                        label: Text(_getSortByText(sortBy)),
                        selected: notesProvider.sortBy == sortBy,
                        onSelected: (selected) {
                          if (selected) {
                            notesProvider.setSortBy(sortBy);
                          }
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),

              // Priority Filter
              Text(
                'Priority',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: notesProvider.selectedPriority == null,
                    onSelected: (selected) {
                      if (selected) {
                        notesProvider.filterByPriority(null);
                      }
                    },
                  ),
                  ...List.generate(3, (index) {
                    final priority = index + 1;
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: PrioritySelector.getPriorityColor(
                                priority,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(PrioritySelector.getPriorityText(priority)),
                        ],
                      ),
                      selected: notesProvider.selectedPriority == priority,
                      onSelected: (selected) {
                        notesProvider.filterByPriority(
                          selected ? priority : null,
                        );
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // Status Filters
              Text(
                'Status',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              CheckboxListTile(
                title: const Text('Show Favorites Only'),
                value: notesProvider.showFavoritesOnly,
                onChanged: (value) {
                  notesProvider.toggleShowFavoritesOnly();
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              CheckboxListTile(
                title: const Text('Show Completed Only'),
                value: notesProvider.showCompletedOnly,
                onChanged: (value) {
                  notesProvider.toggleShowCompletedOnly();
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 20),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),

              // Safe area padding
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  String _getSortByText(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.title:
        return 'Title';
      case SortBy.priority:
        return 'Priority';
      case SortBy.dateCreated:
        return 'Date Created';
      case SortBy.dateUpdated:
        return 'Date Updated';
    }
  }
}
