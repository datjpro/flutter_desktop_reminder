import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SimpleWindowManager extends StatefulWidget {
  final Widget child;

  const SimpleWindowManager({super.key, required this.child});

  @override
  State<SimpleWindowManager> createState() => _SimpleWindowManagerState();
}

class _SimpleWindowManagerState extends State<SimpleWindowManager>
    with WindowListener {
  bool _isMiniMode = false;

  @override
  void initState() {
    super.initState();
    _initializeWindow();
  }

  Future<void> _initializeWindow() async {
    if (!Platform.isWindows) return;

    await windowManager.ensureInitialized();
    windowManager.addListener(this);

    // Load saved window state
    final prefs = await SharedPreferences.getInstance();
    final isMini = prefs.getBool('is_mini_mode') ?? false;

    setState(() {
      _isMiniMode = isMini;
    });

    if (isMini) {
      await _enterMiniMode();
    } else {
      await _enterNormalMode();
    }
  }

  Future<void> _enterMiniMode() async {
    setState(() {
      _isMiniMode = true;
    });

    await windowManager.setSize(const Size(300, 450));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setSkipTaskbar(false); // Vẫn hiển thị trong taskbar
    await windowManager.setResizable(false);
    await windowManager.setTitle('Notes - Mini');

    // Đặt ở góc phải màn hình
    await windowManager.setPosition(
      const Offset(
        1600, // Cách mép phải
        50, // Cách mép trên 50px
      ),
    );

    // Save state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_mini_mode', true);
  }

  Future<void> _enterNormalMode() async {
    setState(() {
      _isMiniMode = false;
    });

    await windowManager.setSize(const Size(1200, 800));
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setResizable(true);
    await windowManager.setTitle('Notes App');
    await windowManager.center();

    // Save state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_mini_mode', false);
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
    // Đóng ứng dụng hoàn toàn thay vì ẩn
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,

          // Controls cho chế độ mini
          if (_isMiniMode)
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
                      onPressed: _toggleMiniMode,
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      tooltip: 'Chế độ đầy đủ',
                      iconSize: 18,
                    ),
                    IconButton(
                      onPressed: () async {
                        await windowManager.minimize();
                      },
                      icon: const Icon(Icons.minimize, color: Colors.white),
                      tooltip: 'Thu nhỏ (sẽ hiện trong taskbar)',
                      iconSize: 18,
                    ),
                    IconButton(
                      onPressed: () async {
                        await windowManager.close();
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: 'Đóng ứng dụng',
                      iconSize: 18,
                    ),
                  ],
                ),
              ),
            ),

          // Nút chuyển sang mini mode cho chế độ bình thường
          if (!_isMiniMode)
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton.small(
                onPressed: _toggleMiniMode,
                tooltip: 'Chế độ mini',
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.minimize, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}

// Widget hiển thị hướng dẫn trong chế độ mini
class MiniModeGuide extends StatelessWidget {
  const MiniModeGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Hướng dẫn chế độ Mini',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Nhấn nút ⛶ để chế độ đầy đủ\n'
            '• Nhấn nút ⊟ để thu nhỏ vào taskbar\n'
            '• Nhấn nút ✕ để đóng ứng dụng\n'
            '• Kéo cửa sổ để di chuyển',
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
