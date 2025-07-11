import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/notes_provider.dart';
import '../screens/home_screen_luxury.dart';
import '../widgets/quick_note_dialog.dart';
import 'dart:io';

class SafeDesktopApp extends StatefulWidget {
  const SafeDesktopApp({super.key});

  @override
  State<SafeDesktopApp> createState() => _SafeDesktopAppState();
}

class _SafeDesktopAppState extends State<SafeDesktopApp> with WindowListener {
  bool _isMiniMode = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _toggleMode() async {
    if (_isMiniMode) {
      // Chuyển về chế độ đầy đủ
      setState(() => _isMiniMode = false);
      await windowManager.setSize(const Size(1200, 800));
      await windowManager.setAlwaysOnTop(false);
      await windowManager.setResizable(true);
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await windowManager.center();
    } else {
      // Chuyển sang chế độ mini
      setState(() => _isMiniMode = true);
      await windowManager.setSize(const Size(300, 400));
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setResizable(false);
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      // Đặt ở góc phải màn hình
      await windowManager.setPosition(const Offset(1600, 100));
    }
  }

  // Ngăn chặn việc ẩn cửa sổ bằng cách override window events
  @override
  void onWindowMinimize() {
    // Không cho phép minimize trong chế độ mini
    if (_isMiniMode) {
      windowManager.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Tự động phát hiện kích thước để hiển thị UI phù hợp
          final isSmall = constraints.maxWidth < 400;

          if (isSmall) {
            return _buildMiniUI();
          } else {
            return _buildFullUI();
          }
        },
      ),
    );
  }

  Widget _buildFullUI() {
    return Stack(
      children: [
        const HomeScreenLuxury(),

        // Nút chuyển sang chế độ mini
        Positioned(
          top: 10,
          right: 10,
          child: FloatingActionButton.small(
            onPressed: _toggleMode,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.compress, color: Colors.white),
            tooltip: 'Chế độ Mini',
          ),
        ),
      ],
    );
  }

  Widget _buildMiniUI() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade700, Colors.purple.shade700],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header với controls luôn hiển thị
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const Icon(Icons.note_alt, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Notes Mini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Nút mở rộng - LUÔN HIỂN THỊ
                  IconButton(
                    onPressed: _toggleMode,
                    icon: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 18,
                    ),
                    tooltip: 'Mở rộng (QUAN TRỌNG)',
                  ),
                  // Nút đóng - LUÔN HIỂN THỊ
                  IconButton(
                    onPressed: () => windowManager.close(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                    tooltip: 'Đóng ứng dụng',
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Warning box để người dùng biết cách mở rộng
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '⚠️ QUAN TRỌNG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Nhấn nút ⛶ để mở rộng',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Stats
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Consumer<NotesProvider>(
                        builder: (context, provider, child) {
                          final todayNotes = provider.getTodayNotes();
                          final totalNotes = provider.allNotes.length;
                          final favoriteNotes =
                              provider.allNotes
                                  .where((n) => n.isFavorite)
                                  .length;

                          return Column(
                            children: [
                              _buildStat('Hôm nay', todayNotes.length),
                              const SizedBox(height: 6),
                              _buildStat('Tổng cộng', totalNotes),
                              const SizedBox(height: 6),
                              _buildStat('Yêu thích', favoriteNotes),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Quick add button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            () => showDialog(
                              context: context,
                              builder: (context) => const QuickNoteDialog(),
                            ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text(
                          'Thêm ghi chú',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Time display
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateTime.now().toString().split(' ')[0],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
