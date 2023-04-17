import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/pages/history_page.dart';
import 'package:flutter_lunch_menu_app/pages/menu_page.dart';

void main() {
  runApp(const LunchMenuApp());
}

class LunchMenuApp extends StatefulWidget {
  const LunchMenuApp({super.key});

  @override
  State<LunchMenuApp> createState() => _LunchMenuAppState();
}

class _LunchMenuAppState extends State<LunchMenuApp> {
  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData();
    final ThemeData darkTheme = ThemeData.dark();

    return MaterialApp(
      title: 'Lunch App',
      theme: lightTheme.copyWith(
        colorScheme: lightTheme.colorScheme.copyWith(secondary: Colors.blue),
      ),
      darkTheme: darkTheme.copyWith(
        colorScheme: darkTheme.colorScheme.copyWith(secondary: Colors.blue),
      ),
      themeMode: ThemeMode.dark,
      home: const HomePage(title: 'Lunch Menu App'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> pages = [
    const MenuPage(
      key: PageStorageKey("MenuPage"),
    ),
    const HistoryPage(
      key: PageStorageKey("HistoryPage"),
    ),
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
        backgroundColor: Colors.black54,
        selectedItemColor: Colors.blue,
        onTap: (int index) => setState(() => _selectedIndex = index),
        currentIndex: selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
      body: PageStorage(
        bucket: bucket,
        child: pages[_selectedIndex],
      ),
    );
  }
}
