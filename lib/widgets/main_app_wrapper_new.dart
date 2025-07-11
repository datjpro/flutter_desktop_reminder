import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../screens/home_screen_luxury.dart';
import '../widgets/quick_note_dialog.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

class MainAppWrapper extends StatefulWidget {
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> with WindowListener {
  bool _isMiniMode = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _initializeWindow();
    }
  }

  Future<void> _initializeWindow() async {
    await windowManager.ensureInitialized();
    windowManager.addListener(this);
    
    // Set default to normal mode
    await _enterNormalMode();
  }

  Future<void> _enterMiniMode() async {
    setState(() {
      _isMiniMode = true;
    });
    
    await windowManager.setSize(const Size(350, 500));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setResizable(false);
    await windowManager.setTitle('Notes - Mini');
    await windowManager.center(); // Luôn đưa về giữa màn hình
  }

  Future<void> _enterNormalMode() async {
    setState(() {
      _isMiniMode = false;
    });
    
    await windowManager.setSize(const Size(1200, 800));
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setResizable(true);
    await windowManager.setTitle('Notes App');
    await windowManager.center();
  }

  Future<void> _toggleMiniMode() async {
    if (_isMiniMode) {
      await _enterNormalMode();
    } else {
      await _enterMiniMode();
    }
  }

  @override
  void onWindowClose() async {
    // Không cho đóng hoàn toàn, chỉ chuyển về mini mode
    if (!_isMiniMode) {
      await _enterMiniMode();
    } else {
      // Nếu đã ở mini mode, mới cho phép đóng
      await windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    // For desktop platforms, use window manager
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return Scaffold(
        body: Stack(
          children: [
            // Main content
            _isMiniMode ? _buildMiniContent() : const HomeScreenLuxury(),
            
            // Control buttons - luôn hiển thị
            Positioned(
              top: 10,
              right: 10,
              child: Card(
                elevation: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _toggleMiniMode,
                      icon: Icon(_isMiniMode ? Icons.fullscreen : Icons.minimize),
                      tooltip: _isMiniMode ? 'Chế độ đầy đủ (F11)' : 'Chế độ mini (F11)',
                    ),
                    if (_isMiniMode)
                      IconButton(
                        onPressed: () => windowManager.center(),
                        icon: const Icon(Icons.center_focus_strong),
                        tooltip: 'Đưa về giữa màn hình',
                      ),
                    IconButton(
                      onPressed: () async {
                        if (_isMiniMode) {
                          await windowManager.destroy();
                        } else {
                          await _enterMiniMode();
                        }
                      },
                      icon: const Icon(Icons.close),
                      tooltip: _isMiniMode ? 'Thoát ứng dụng' : 'Thu nhỏ',
                    ),
                  ],
                ),
              ),
            ),
            
            // Mini mode instructions
            if (_isMiniMode)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Chế độ mini đang bật\n'
                      '🔹 Nhấn ⛶ để mở rộng\n'
                      '🔹 Nhấn ◎ để đưa về giữa màn hình\n'
                      '🔹 Nhấn X để thoát hoàn toàn\n'
                      '🔹 Phím F11 để chuyển đổi chế độ',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    
    // For mobile platforms, use regular app
    return const HomeScreenLuxury();
  }

  Widget _buildMiniContent() {
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
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 45, 12, 12), // Giảm padding
          child: SingleChildScrollView( // Thêm scroll để tránh overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Quan trọng: sử dụng min size
              children: [
                // App title - nhỏ hơn
                Row(
                  children: [
                    Icon(
                      Icons.note_alt,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 22, // Giảm size
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Notes Mini',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16, // Giảm font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16), // Giảm spacing
                
                // Quick stats - compact hơn
                Container(
                  padding: const EdgeInsets.all(12), // Giảm padding
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
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
                
                const SizedBox(height: 16), // Giảm spacing
              
                // Quick actions - compact hơn
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const QuickNoteDialog(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Thêm ghi chú', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _toggleMiniMode();
                        },
                        icon: const Icon(Icons.list, size: 14),
                        label: const Text('Danh sách', style: TextStyle(fontSize: 10)),
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
                          _toggleMiniMode();
                        },
                        icon: const Icon(Icons.calendar_today, size: 14),
                        label: const Text('Lịch', style: TextStyle(fontSize: 10)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Current time - compact
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateTime.now().toString().split(' ')[0],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
                      '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateTime.now().toString().split(' ')[0],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }
}
