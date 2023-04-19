import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/pages/history_page.dart';
import 'package:flutter_lunch_menu_app/pages/menu_page.dart';
import 'package:flutter_lunch_menu_app/pages/more_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale("en"), Locale("fi")],
      path: "assets/translations",
      fallbackLocale: const Locale("en"),
      child: const LunchMenuApp(),
    ),
  );
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
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: "lunch_menu".tr(),
      theme: lightTheme.copyWith(
        colorScheme: lightTheme.colorScheme.copyWith(secondary: Colors.blue),
      ),
      darkTheme: darkTheme.copyWith(
        colorScheme: darkTheme.colorScheme.copyWith(secondary: Colors.blue),
      ),
      themeMode: ThemeMode.dark,
      home: HomePage(title: "lunch_menu_app".tr()),
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
    const MorePage(
      key: PageStorageKey("MorePage"),
    ),
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
        backgroundColor: Colors.black54,
        selectedItemColor: Colors.blue,
        onTap: (int index) => setState(() => _selectedIndex = index),
        currentIndex: selectedIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.restaurant_menu), label: "menu".tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: "history".tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.more), label: "more".tr()),
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
