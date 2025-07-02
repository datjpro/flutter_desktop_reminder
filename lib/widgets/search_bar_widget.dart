import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<NotesProvider>().searchNotes(query);
    setState(() {
      _isSearching = query.isNotEmpty;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<NotesProvider>().searchNotes('');
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon:
              _isSearching
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: _clearSearch,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          // The listener will handle the search
        },
      ),
    );
  }
}
