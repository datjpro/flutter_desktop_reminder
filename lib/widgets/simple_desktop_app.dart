import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/notes_provider.dart';
import '../screens/home_screen_luxury.dart';
import '../widgets/quick_note_dialog.dart';
import '../widgets/window_test_widget.dart';

class SimpleDesktopApp extends StatefulWidget {
  const SimpleDesktopApp({super.key});

  @override
  State<SimpleDesktopApp> createState() => _SimpleDesktopAppState();
}

class _SimpleDesktopAppState extends State<SimpleDesktopApp>
    with WindowListener {
  bool _isMiniMode = false;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _setupWindow();
  }

  Future<void> _setupWindow() async {
    // Đảm bảo cửa sổ luôn hiển thị trong taskbar
    await windowManager.setSkipTaskbar(false);
    await windowManager.setPreventClose(false);
  }

  @override
  void onWindowRestore() {
    setState(() {
      _isMinimized = false;
    });
  }

  @override
  void onWindowMinimize() {
    setState(() {
      _isMinimized = true;
    });
  }

  @override
  void onWindowFocus() {
    setState(() {
      _isMinimized = false;
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _switchToMiniMode() async {
    setState(() {
      _isMiniMode = true;
    });

    // Thay đổi window properties với đảm bảo an toàn
    await windowManager.setSize(const Size(320, 450));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setResizable(false);
    await windowManager.setSkipTaskbar(
      false,
    ); // ĐẢM BẢO luôn hiện trong taskbar
    await windowManager.setPreventClose(false); // Cho phép đóng bình thường
    await windowManager.setTitle('Notes Mini - Thu nhỏ để ẩn');

    // Đặt ở góc phải màn hình
    await windowManager.setPosition(const Offset(1580, 100));

    // Đảm bảo cửa sổ được focus
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _switchToFullMode() async {
    setState(() {
      _isMiniMode = false;
      _isMinimized = false;
    });

    // Khôi phục window properties
    await windowManager.setSize(const Size(1200, 800));
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setResizable(true);
    await windowManager.setSkipTaskbar(false); // Đảm bảo vẫn hiện trong taskbar
    await windowManager.setTitle('Notes App');
    await windowManager.center();

    // Đảm bảo cửa sổ được hiển thị và focus
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _isMiniMode ? _buildMiniMode() : _buildFullMode());
  }

  Widget _buildFullMode() {
    return Stack(
      children: [
        const HomeScreenLuxury(),

        // Nút chuyển sang mini mode
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _switchToMiniMode,
              icon: const Icon(Icons.minimize, color: Colors.white),
              tooltip: 'Chế độ Mini',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMode() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.purple],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với nút quay lại
            Row(
              children: [
                const Icon(Icons.note_alt, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Notes Mini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: _switchToFullMode,
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    tooltip: 'Chế độ đầy đủ',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Hướng dẫn
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isMinimized
                        ? '🔸 Đã thu nhỏ - Mở lại từ taskbar'
                        : '🔹 Chế độ Mini - Luôn hiển thị',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Nhấn ⛶ để chuyển chế độ đầy đủ\n• Nhấn "Thu nhỏ" để ẩn vào taskbar\n• Mở lại từ taskbar hoặc Alt+Tab\n• Không thể bị mất hoàn toàn',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Thống kê
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Consumer<NotesProvider>(
                builder: (context, notesProvider, child) {
                  final todayNotes = notesProvider.getTodayNotes();
                  final totalNotes = notesProvider.allNotes.length;
                  final favoriteNotes =
                      notesProvider.allNotes
                          .where((note) => note.isFavorite)
                          .length;

                  return Column(
                    children: [
                      _buildStatRow('Hôm nay', todayNotes.length.toString()),
                      const SizedBox(height: 6),
                      _buildStatRow('Tổng cộng', totalNotes.toString()),
                      const SizedBox(height: 6),
                      _buildStatRow('Yêu thích', favoriteNotes.toString()),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Nút thêm ghi chú và khôi phục khẩn cấp
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const QuickNoteDialog(),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm ghi chú mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 8),
            // Nút khôi phục khẩn cấp
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Khôi phục cửa sổ về trạng thái an toàn
                  await windowManager.setSkipTaskbar(false);
                  await windowManager.show();
                  await windowManager.focus();
                  await windowManager.setAlwaysOnTop(false);
                  await windowManager.setAlwaysOnTop(true);

                  setState(() {
                    _isMinimized = false;
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Đã khôi phục cửa sổ về trạng thái an toàn',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text(
                  'Khôi phục khẩn cấp',
                  style: TextStyle(fontSize: 11),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Nút xem danh sách và ẩn
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _switchToFullMode,
                    icon: const Icon(Icons.list, size: 14),
                    label: const Text(
                      'Xem đầy đủ',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Đảm bảo không bị ẩn hoàn toàn
                      await windowManager.setSkipTaskbar(false);
                      await windowManager.minimize();

                      // Hiển thị thông báo
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Ứng dụng đã được thu nhỏ. Nhấn vào biểu tượng trong taskbar để mở lại.',
                              style: TextStyle(fontSize: 12),
                            ),
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.keyboard_arrow_down, size: 14),
                    label: const Text(
                      'Thu nhỏ',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Thời gian hiện tại
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
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
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
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
