import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class DesktopWindowManager extends StatefulWidget {
  final Widget child;

  const DesktopWindowManager({super.key, required this.child});

  @override
  State<DesktopWindowManager> createState() => _DesktopWindowManagerState();
}

class _DesktopWindowManagerState extends State<DesktopWindowManager>
    with WindowListener {
  final SystemTray _systemTray = SystemTray();
  bool _isMiniMode = false;

  @override
  void initState() {
    super.initState();
    _initializeWindow();
    _initSystemTray();
  }

  Future<void> _initializeWindow() async {
    await windowManager.ensureInitialized();
    windowManager.addListener(this);

    // Load saved window state
    final prefs = await SharedPreferences.getInstance();
    final isMini = prefs.getBool('is_mini_mode') ?? false;

    if (isMini) {
      await _enterMiniMode();
    } else {
      await _enterNormalMode();
    }
  }

  Future<void> _initSystemTray() async {
    if (!Platform.isWindows) return;

    try {
      await _systemTray.initSystemTray(
        title: "Notes App",
        iconPath: "assets/icon.ico", // You'll need to add this
      );

      final Menu menu = Menu();
      await menu.buildFrom([
        MenuItemLabel(
          label: 'Mở ứng dụng',
          onClicked: (menuItem) => _showWindow(),
        ),
        MenuItemLabel(
          label: 'Chế độ mini',
          onClicked: (menuItem) => _toggleMiniMode(),
        ),
        MenuItemLabel(label: '', onClicked: null),
        MenuItemLabel(label: 'Thoát', onClicked: (menuItem) => _exitApp()),
      ]);

      await _systemTray.setContextMenu(menu);

      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          _showWindow();
        }
      });
    } catch (e) {
      debugPrint('System tray initialization failed: $e');
    }
  }

  Future<void> _enterMiniMode() async {
    setState(() {
      _isMiniMode = true;
    });

    await windowManager.setSize(const Size(300, 400));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setResizable(false);
    await windowManager.setTitle('Notes - Mini');

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

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _hideWindow() async {
    await windowManager.hide();
  }

  Future<void> _exitApp() async {
    await windowManager.destroy();
  }

  @override
  void onWindowClose() async {
    // Instead of closing, hide to system tray
    await _hideWindow();
  }

  @override
  void onWindowMinimize() async {
    // Hide to system tray when minimized
    await _hideWindow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,

          // Mini mode controls
          if (_isMiniMode)
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _toggleMiniMode,
                    icon: const Icon(Icons.fullscreen),
                    tooltip: 'Chế độ đầy đủ',
                    iconSize: 20,
                  ),
                  IconButton(
                    onPressed: _hideWindow,
                    icon: const Icon(Icons.minimize),
                    tooltip: 'Ẩn vào system tray',
                    iconSize: 20,
                  ),
                  IconButton(
                    onPressed: _exitApp,
                    icon: const Icon(Icons.close),
                    tooltip: 'Thoát',
                    iconSize: 20,
                  ),
                ],
              ),
            ),

          // Normal mode mini toggle button
          if (!_isMiniMode)
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton.small(
                onPressed: _toggleMiniMode,
                tooltip: 'Chế độ mini',
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

// Mini mode content widget
class MiniModeContent extends StatelessWidget {
  const MiniModeContent({super.key});

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
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
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
                  Text(
                    'Notes Mini',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quick stats
              _buildQuickStats(),

              const SizedBox(height: 20),

              // Quick actions
              _buildQuickActions(context),

              const Spacer(),

              // Current time
              _buildCurrentTime(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          _StatRow(label: 'Hôm nay', value: '3'),
          SizedBox(height: 8),
          _StatRow(label: 'Tổng cộng', value: '15'),
          SizedBox(height: 8),
          _StatRow(label: 'Yêu thích', value: '5'),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Open add note dialog or navigate to add note
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
                  // Open notes list
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
                  // Open calendar
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
      ],
    );
  }

  Widget _buildCurrentTime() {
    return Container(
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
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
}
