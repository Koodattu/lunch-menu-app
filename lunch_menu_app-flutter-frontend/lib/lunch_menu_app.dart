import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_lunch_menu_app/pages/history_page.dart';
import 'package:flutter_lunch_menu_app/pages/menu_page.dart';
import 'package:flutter_lunch_menu_app/pages/more_page.dart';
import 'package:flutter_lunch_menu_app/pages/vote_page.dart';
import 'package:flutter_lunch_menu_app/services/snackbar_service.dart';

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
      scaffoldMessengerKey: snackbarKey,
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
  int _selectedPageIndex = 0;
  late List<Widget> _pages;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pages = [
      const MenuPage(),
      const VotePage(),
      const HistoryPage(),
      const MorePage(),
    ];

    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  final List<Widget> pages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.restaurant_menu), label: "menu".tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.how_to_vote), label: "vote".tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: "history".tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.more), label: "more".tr()),
        ],
        backgroundColor: Colors.black54,
        selectedItemColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedPageIndex,
        onTap: (selectedPageIndex) {
          setState(() {
            _selectedPageIndex = selectedPageIndex;
            _pageController.jumpToPage(selectedPageIndex);
          });
        },
      ),
    );
  }
}
