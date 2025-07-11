import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/notes_provider.dart';
import '../screens/home_screen_luxury.dart';
import '../widgets/quick_note_dialog.dart';
import 'dart:io';

class SimpleApp extends StatefulWidget {
  const SimpleApp({super.key});

  @override
  State<SimpleApp> createState() => _SimpleAppState();
}

class _SimpleAppState extends State<SimpleApp> with WindowListener {
  bool _isMiniMode = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      _initWindowManager();
    }
  }

  Future<void> _initWindowManager() async {
    await windowManager.ensureInitialized();
    windowManager.addListener(this);

    // Set default to mini mode
    await _setMiniMode();
  }

  Future<void> _setMiniMode() async {
    setState(() => _isMiniMode = true);
    await windowManager.setSize(const Size(300, 400));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setResizable(false);
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
    ); // Ẩn thanh title bar
    await windowManager.setTitle('Notes Mini');
    await windowManager.setPosition(const Offset(1600, 100));
  }

  Future<void> _setFullMode() async {
    setState(() => _isMiniMode = false);
    await windowManager.setSize(const Size(1200, 800));
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setResizable(true);
    await windowManager.setTitleBarStyle(
      TitleBarStyle.normal,
    ); // Hiện lại thanh title bar
    await windowManager.setTitle('Notes App');
    await windowManager.center();
  }

  Future<void> _toggleMode() async {
    if (_isMiniMode) {
      await _setFullMode();
    } else {
      await _setMiniMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;

          if (isSmall) {
            return _buildMiniApp();
          } else {
            return _buildFullApp();
          }
        },
      ),
    );
  }

  Widget _buildMiniApp() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.note_alt, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Notes Mini',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Consumer<NotesProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            _buildStat(
                              'Hôm nay',
                              provider.getTodayNotes().length,
                            ),
                            const SizedBox(height: 8),
                            _buildStat('Tổng cộng', provider.allNotes.length),
                            const SizedBox(height: 8),
                            _buildStat(
                              'Yêu thích',
                              provider.allNotes
                                  .where((n) => n.isFavorite)
                                  .length,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Hướng dẫn nhỏ
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.yellow.withOpacity(0.5)),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Tip: Nếu ẩn ứng dụng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Dùng Alt+Tab để mở lại',
                          style: TextStyle(color: Colors.white70, fontSize: 9),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Actions
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
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _toggleMode,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text(
                            'Mở rộng',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            // Chỉ ẩn vào taskbar, không thu nhỏ window
                            await windowManager.hide();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text(
                            'Ẩn',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Time
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

          // Controls
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _toggleMode,
                    icon: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 18,
                    ),
                    tooltip: 'Mở rộng',
                  ),
                  IconButton(
                    onPressed: () async {
                      await windowManager.hide(); // Chỉ ẩn, không đóng
                    },
                    icon: const Icon(
                      Icons.visibility_off,
                      color: Colors.white,
                      size: 18,
                    ),
                    tooltip: 'Ẩn (Alt+Tab để mở lại)',
                  ),
                  IconButton(
                    onPressed: () async {
                      await windowManager.close();
                    },
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
          ),
        ],
      ),
    );
  }

  Widget _buildFullApp() {
    return Stack(
      children: [
        const HomeScreenLuxury(),
        Positioned(
          top: 10,
          right: 10,
          child: FloatingActionButton.small(
            onPressed: _toggleMode,
            tooltip: 'Chế độ mini',
            child: const Icon(Icons.minimize),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }
}
