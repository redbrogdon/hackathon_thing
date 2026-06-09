import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/journal_provider.dart';
import 'screens/list_screen.dart';
import 'theme/peejays_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<JournalProvider>(
      create: (_) => JournalProvider(),
      child: MaterialApp(
        title: 'Peejays',
        debugShowCheckedModeBanner: false,
        theme: PeejaysTheme.lightTheme,
        darkTheme: PeejaysTheme.darkTheme,
        themeMode: ThemeMode.system, // Dynamically matches device preference
        home: const ListScreen(),
      ),
    );
  }
}
