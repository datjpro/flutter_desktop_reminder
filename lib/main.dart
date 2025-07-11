import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/notes_provider.dart';
import 'widgets/simple_desktop_app.dart';
import 'utils/modern_theme.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false, // ĐẢM BẢO luôn hiện trong taskbar
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
      alwaysOnTop: false,
      fullScreen: false,
      minimumSize: Size(320, 450), // Kích thước tối thiểu
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotesProvider(),
      child: MaterialApp(
        title: 'Modern Notes App',
        theme: ModernAppTheme.lightTheme,
        darkTheme: ModernAppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SimpleDesktopApp(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
