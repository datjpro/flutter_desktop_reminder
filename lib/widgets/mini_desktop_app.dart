import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/notes_provider.dart';
import '../screens/home_screen_luxury.dart';
import '../widgets/quick_note_dialog.dart';
import 'dart:io';

class MiniDesktopApp extends StatefulWidget {
  const MiniDesktopApp({super.key});

  @override
  State<MiniDesktopApp> createState() => _MiniDesktopAppState();
}

class _MiniDesktopAppState extends State<MiniDesktopApp> with WindowListener {
  bool _isMiniMode = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      _setupWindow();
    }
  }

  Future<void> _setupWindow() async {
    await windowManager.ensureInitialized();
    windowManager.addListener(this);
    await _setMiniMode();
  }

  Future<void> _setMiniMode() async {
    setState(() => _isMiniMode = true);

    await windowManager.setSize(const Size(320, 480));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setResizable(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setPosition(const Offset(50, 50));
  }

  Future<void> _setFullMode() async {
    setState(() => _isMiniMode = false);

    await windowManager.setSize(const Size(1200, 800));
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setResizable(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.center();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(body: _isMiniMode ? _buildMiniView() : _buildFullView()),
    );
  }

  Widget _buildMiniView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 40), // Space for close button
                // Header
                Row(
                  children: [
                    const Icon(Icons.note, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Notes Mini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Consumer<NotesProvider>(
                    builder: (context, provider, child) {
                      final todayCount = provider.getTodayNotes().length;
                      final totalCount = provider.allNotes.length;
                      final favoriteCount =
                          provider.allNotes.where((n) => n.isFavorite).length;

                      return Column(
                        children: [
                          _buildStatRow('Hôm nay', todayCount.toString()),
                          const SizedBox(height: 8),
                          _buildStatRow('Tổng cộng', totalCount.toString()),
                          const SizedBox(height: 8),
                          _buildStatRow('Yêu thích', favoriteCount.toString()),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Add note button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const QuickNoteDialog(),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm ghi chú'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _setFullMode,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: const Text(
                          'Mở rộng',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          windowManager.hide();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: const Text('Ẩn', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Time
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getCurrentTime(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getCurrentDate(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tip
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Tip: Dùng Alt+Tab để mở lại khi ẩn',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Close button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () {
                windowManager.close();
              },
              icon: const Icon(Icons.close, color: Colors.white),
              tooltip: 'Đóng ứng dụng',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullView() {
    return Stack(
      children: [
        const HomeScreenLuxury(),
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: _setMiniMode,
            tooltip: 'Chế độ mini',
            child: const Icon(Icons.minimize),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
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

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }
}
