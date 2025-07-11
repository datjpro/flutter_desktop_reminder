import 'package:flutter/material.dart';
import '../screens/home_screen_luxury.dart';
import '../widgets/mini_app_bar.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isMiniMode = false;

  void _toggleMiniMode() {
    setState(() {
      _isMiniMode = !_isMiniMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main app content - only show when not in mini mode
          if (!_isMiniMode) const HomeScreenLuxury(),

          // Mini mode overlay - transparent background
          if (_isMiniMode)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(
                0.1,
              ), // Slight tint to show mini mode
              child: GestureDetector(
                onTap: () {
                  // Tap anywhere to exit mini mode
                  _toggleMiniMode();
                },
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      const MiniAppBar(),
                      // Instructions text
                      Positioned(
                        bottom: 100,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Chế độ mini đang bật\nChạm vào bất kỳ đâu để thoát\nKéo thanh mini để di chuyển',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Toggle button - always visible in bottom left
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton.small(
              heroTag: "miniToggle",
              onPressed: _toggleMiniMode,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                _isMiniMode ? Icons.fullscreen : Icons.minimize,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
