import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowTestWidget extends StatefulWidget {
  const WindowTestWidget({super.key});

  @override
  State<WindowTestWidget> createState() => _WindowTestWidgetState();
}

class _WindowTestWidgetState extends State<WindowTestWidget> {
  String _status = 'Normal';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Trạng thái cửa sổ: $_status',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await windowManager.minimize();
                  setState(() {
                    _status = 'Minimized';
                  });
                },
                child: const Text('Test Minimize'),
              ),

              ElevatedButton(
                onPressed: () async {
                  await windowManager.show();
                  await windowManager.focus();
                  setState(() {
                    _status = 'Restored';
                  });
                },
                child: const Text('Test Restore'),
              ),

              ElevatedButton(
                onPressed: () async {
                  final isVisible = await windowManager.isVisible();
                  final isMinimized = await windowManager.isMinimized();
                  setState(() {
                    _status = 'Visible: $isVisible, Min: $isMinimized';
                  });
                },
                child: const Text('Check Status'),
              ),

              ElevatedButton(
                onPressed: () async {
                  await windowManager.setSkipTaskbar(false);
                  await windowManager.show();
                  await windowManager.focus();
                  setState(() {
                    _status = 'Force Show';
                  });
                },
                child: const Text('Force Show'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
