import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/notes_provider.dart';
import 'screens/home_screen_luxury.dart';
import 'utils/modern_theme.dart';

void main() {
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
        home: const HomeScreenLuxury(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
