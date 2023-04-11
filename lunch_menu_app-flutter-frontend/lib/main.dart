import 'package:flutter/material.dart';

import 'model/menu_day.dart';
import 'model/menu_week.dart';
import 'model/menu_course.dart';

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
  late MenuWeek menuWeek;

  @override
  void initState() {
    super.initState();
    List<MenuDay> menuDays = [];
    List<String> dayNames = ["Monday", "Tuesday", "Wednesday", "Thrusday", "Friday"];
    for (var i = 0; i < 5; i++) {
      List<MenuCourse> menuCourses = [
        MenuCourse(courseName: "Salad$i", allergens: ""),
        MenuCourse(courseName: "Soup$i", allergens: "G"),
        MenuCourse(courseName: "Main$i", allergens: "L")
      ];
      menuDays.add(MenuDay(dayName: "${dayNames[i]}, 1$i.4.", menuCourses: menuCourses));
    }

    setState(() {
      menuWeek = MenuWeek(weekName: "Week 23", menuDays: menuDays);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: [
            Column(
              children: [
                const Text(
                  "Lunch Menu App",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Lunch"),
                    Icon(Icons.access_time),
                    Text("10:30-13:00"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Text("Salad: 4,70€"),
                    Text("Soup: 5,60€"),
                    Text("Main: 7,10€"),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuWeek.menuDays.length,
              itemBuilder: (context, index) {
                MenuDay menuDay = menuWeek.menuDays[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuDay.dayName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: menuDay.menuCourses.length,
                      itemBuilder: (context, index) {
                        MenuCourse menuCourse = menuDay.menuCourses[index];
                        return CourseCardWidget(courseName: menuCourse.courseName, allergens: menuCourse.allergens);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCardWidget extends StatelessWidget {
  final String courseName;
  final String allergens;

  const CourseCardWidget({super.key, required this.courseName, required this.allergens});

  Icon getMenuTypeIcon(String courseName) {
    if (courseName.toLowerCase().contains("salad")) {
      return const Icon(
        Icons.restaurant_menu,
        color: Colors.green,
        size: 40,
      );
    } else if (courseName.toLowerCase().contains("soup")) {
      return const Icon(
        Icons.restaurant,
        color: Colors.red,
        size: 40,
      );
    } else {
      return const Icon(
        Icons.egg,
        color: Colors.cyan,
        size: 40,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getMenuTypeIcon(courseName),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseName),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (allergens.contains("L"))
                      Icon(
                        Icons.mail,
                        color: Colors.blue.shade800,
                      ),
                    if (allergens.contains("G"))
                      Icon(
                        Icons.mail,
                        color: Colors.orange.shade400,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
