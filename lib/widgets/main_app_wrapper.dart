import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../screens/home_screen_luxury.dart';
import '../widgets/quick_note_dialog.dart';
import '../widgets/simple_window_manager.dart';
import 'dart:io';'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../screens/home_screen_luxury.dart';
import '../widgets/simple_window_manager.dart';
import '../widgets/quick_note_dialog.dart';
import 'dart:io';

class MainAppWrapper extends StatefulWidget {
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  bool _isMiniMode = false;

  void _toggleMiniMode() {
    setState(() {
      _isMiniMode = !_isMiniMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // For desktop platforms, use window manager
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return SimpleWindowManager(
        child: Consumer<NotesProvider>(
          builder: (context, notesProvider, child) {
            // Check if we're in mini mode by checking window size
            return LayoutBuilder(
              builder: (context, constraints) {
                final isMiniWindow = constraints.maxWidth < 400;
                return isMiniWindow 
                  ? MiniDesktopApp(onToggleMode: _toggleMiniMode)
                  : FullDesktopApp(onToggleMode: _toggleMiniMode);
              },
            );
          },
        ),
      );
    }
    
    // For mobile platforms, use regular app
    return const HomeScreenLuxury();
  }
}

class FullDesktopApp extends StatelessWidget {
  final VoidCallback onToggleMode;
  
  const FullDesktopApp({super.key, required this.onToggleMode});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const HomeScreenLuxury(),
        
        // Mini mode toggle button
        Positioned(
          top: 10,
          right: 10,
          child: FloatingActionButton.small(
            onPressed: onToggleMode,
            tooltip: 'Chế độ mini',
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.minimize, size: 20),
          ),
        ),
      ],
    );
  }
}

class MiniDesktopApp extends StatelessWidget {
  final VoidCallback onToggleMode;
  
  const MiniDesktopApp({super.key, required this.onToggleMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16), // Top padding để tránh controls
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App title
                Row(
                  children: [
                    Icon(
                      Icons.note_alt,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Notes Mini',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Hướdẫn
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chế độ Mini đang hoạt động',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• ⛶ Chế độ đầy đủ\n• ⊟ Thu nhỏ vào taskbar\n• ✕ Đóng ứng dụng',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Quick stats
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Consumer<NotesProvider>(
                    builder: (context, notesProvider, child) {
                      final todayNotes = notesProvider.getTodayNotes();
                      final totalNotes = notesProvider.allNotes.length;
                      final favoriteNotes = notesProvider.allNotes.where((note) => note.isFavorite).length;
                      
                      return Column(
                        children: [
                          _buildStatRow('Hôm nay', todayNotes.length.toString()),
                          const SizedBox(height: 8),
                          _buildStatRow('Tổng cộng', totalNotes.toString()),
                          const SizedBox(height: 8),
                          _buildStatRow('Yêu thích', favoriteNotes.toString()),
                        ],
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
              
              // Quick actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Show quick note dialog
                    showDialog(
                      context: context,
                      builder: (context) => const QuickNoteDialog(),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm ghi chú mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Switch to full mode and show notes list
                        onToggleMode();
                      },
                      icon: const Icon(Icons.list, size: 16),
                      label: const Text('Danh sách'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Switch to full mode and show calendar
                        onToggleMode();
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('Lịch'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Current time
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateTime.now().toString().split(' ')[0],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
