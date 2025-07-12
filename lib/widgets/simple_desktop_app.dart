import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../screens/home_screen_luxury.dart';
import '../widgets/quick_note_dialog.dart';

class SimpleDesktopApp extends StatefulWidget {
  const SimpleDesktopApp({super.key});

  @override
  State<SimpleDesktopApp> createState() => _SimpleDesktopAppState();
}

class _SimpleDesktopAppState extends State<SimpleDesktopApp> {
  bool _isMiniMode = false;

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
              onPressed: () {
                setState(() {
                  _isMiniMode = true;
                });
              },
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
                    onPressed: () {
                      setState(() {
                        _isMiniMode = false;
                      });
                    },
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔹 Chế độ Mini đang hoạt động',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Nhấn ⛶ để chế độ đầy đủ\n• Cửa sổ này luôn hiển thị\n• Không thể bị ẩn hoàn toàn',
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

            // Nút thêm ghi chú
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

            // Nút xem danh sách
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isMiniMode = false;
                  });
                },
                icon: const Icon(Icons.list, size: 16),
                label: const Text('Xem danh sách đầy đủ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
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
