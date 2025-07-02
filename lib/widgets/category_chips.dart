import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await context.read<NotesProvider>().getAllCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length + 1, // +1 for "All" chip
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All" chip
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: notesProvider.selectedCategory.isEmpty,
                    onSelected: (selected) {
                      if (selected) {
                        notesProvider.filterByCategory('');
                      }
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              }

              final category = _categories[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: notesProvider.selectedCategory == category,
                  onSelected: (selected) {
                    if (selected) {
                      notesProvider.filterByCategory(category);
                    } else {
                      notesProvider.filterByCategory('');
                    }
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
