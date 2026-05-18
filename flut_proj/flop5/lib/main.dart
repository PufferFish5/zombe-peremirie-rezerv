import 'package:flutter/material.dart';
import 'screens/add_task_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/task_list_screen.dart';


void main() => runApp(const MyApp());

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFE8D8C9),
    onPrimary: Colors.black,
    secondary: Color(0xFF4B607F),
    onSecondary: Colors.white,
    surface: Color(0xFFFCF8F5),
    onSurface: Color(0xFF121312),
  ),
);
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF121212),
    onPrimary: Colors.white,
    secondary: Color(0xFFF3701E),
    onSecondary: Colors.black,
    //surface: Color(0xFF1F1B24),
    surface: Color(0xFF1A1A1A),
    onSurface: Colors.white,
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'What to do?',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const ListScreen(),
        '/add': (context) => const AddScreen(),
        '/details': (context) => const DetailScreen(),
      },
    );
  }
}
