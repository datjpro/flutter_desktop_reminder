import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MiniAppSettings {
  static const String _positionXKey = 'mini_app_position_x';
  static const String _positionYKey = 'mini_app_position_y';
  static const String _autoHideKey = 'mini_app_auto_hide';
  static const String _opacityKey = 'mini_app_opacity';

  static Future<void> savePosition(Offset position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_positionXKey, position.dx);
    await prefs.setDouble(_positionYKey, position.dy);
  }

  static Future<Offset> loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final x = prefs.getDouble(_positionXKey) ?? 20.0;
    final y = prefs.getDouble(_positionYKey) ?? 50.0;
    return Offset(x, y);
  }

  static Future<void> saveAutoHide(bool autoHide) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoHideKey, autoHide);
  }

  static Future<bool> loadAutoHide() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoHideKey) ?? false;
  }

  static Future<void> saveOpacity(double opacity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_opacityKey, opacity);
  }

  static Future<double> loadOpacity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_opacityKey) ?? 1.0;
  }
}

class MiniAppSettingsDialog extends StatefulWidget {
  final Offset currentPosition;
  final bool autoHide;
  final double opacity;
  final Function(Offset) onPositionChanged;
  final Function(bool) onAutoHideChanged;
  final Function(double) onOpacityChanged;

  const MiniAppSettingsDialog({
    super.key,
    required this.currentPosition,
    required this.autoHide,
    required this.opacity,
    required this.onPositionChanged,
    required this.onAutoHideChanged,
    required this.onOpacityChanged,
  });

  @override
  State<MiniAppSettingsDialog> createState() => _MiniAppSettingsDialogState();
}

class _MiniAppSettingsDialogState extends State<MiniAppSettingsDialog> {
  late bool _autoHide;
  late double _opacity;

  @override
  void initState() {
    super.initState();
    _autoHide = widget.autoHide;
    _opacity = widget.opacity;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cài đặt Mini App'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Tự động ẩn'),
            subtitle: const Text('Ẩn mini bar khi không sử dụng'),
            value: _autoHide,
            onChanged: (value) {
              setState(() {
                _autoHide = value;
              });
              widget.onAutoHideChanged(value);
            },
          ),
          const SizedBox(height: 16),
          Text('Độ trong suốt: ${(_opacity * 100).round()}%'),
          Slider(
            value: _opacity,
            min: 0.3,
            max: 1.0,
            divisions: 7,
            onChanged: (value) {
              setState(() {
                _opacity = value;
              });
              widget.onOpacityChanged(value);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Reset to top-right corner
                    widget.onPositionChanged(const Offset(20, 50));
                  },
                  child: const Text('Góc trên'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Reset to center
                    final screenSize = MediaQuery.of(context).size;
                    widget.onPositionChanged(
                      Offset(
                        screenSize.width / 2 - 30,
                        screenSize.height / 2 - 30,
                      ),
                    );
                  },
                  child: const Text('Giữa màn hình'),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
