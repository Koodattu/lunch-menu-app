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
  MenuWeek? menuWeek;

  @override
  void initState() {
    super.initState();
    List<MenuDay> menuDays = [];
    List<String> dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
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

  MenuDay? getMenuDay(bool tomorrow) {
    DateTime now = DateTime.now();
    int dayOfWeek = tomorrow ? now.weekday : now.weekday - 1;
    if (menuWeek!.menuDays.length <= dayOfWeek) {
      return null;
    }
    return menuWeek!.menuDays[dayOfWeek];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Builder(
          builder: (context) {
            if (menuWeek == null) {
              return const Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return ListView(
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
                  DayMenuTitleWidget(
                    relativeDay: "Today",
                    menuDay: getMenuDay(false),
                  ),
                  DayMenuTitleWidget(
                    relativeDay: "Tomorrow",
                    menuDay: getMenuDay(true),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: Text(
                      "This ${menuWeek!.weekName}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: menuWeek?.menuDays.length,
                    itemBuilder: (context, index) {
                      MenuDay menuDay = menuWeek!.menuDays[index];
                      return DayMenuWidget(menuDay: menuDay);
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class DayMenuTitleWidget extends StatelessWidget {
  const DayMenuTitleWidget({
    super.key,
    required this.relativeDay,
    required this.menuDay,
  });

  final String relativeDay;
  final MenuDay? menuDay;

  @override
  Widget build(BuildContext context) {
    if (menuDay == null) {
      return const SizedBox();
    }
    return Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        Center(
          child: Text(
            relativeDay,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
        ),
        DayMenuWidget(menuDay: menuDay),
      ],
    );
  }
}

class DayMenuWidget extends StatelessWidget {
  const DayMenuWidget({
    super.key,
    required this.menuDay,
  });

  final MenuDay? menuDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 8,
        ),
        Text(
          menuDay!.dayName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menuDay!.menuCourses.length,
          itemBuilder: (context, index) {
            MenuCourse menuCourse = menuDay!.menuCourses[index];
            return CourseCardWidget(courseName: menuCourse.courseName, allergens: menuCourse.allergens);
          },
        ),
      ],
    );
  }
}

class CourseCardWidget extends StatelessWidget {
  final String courseName;
  final String allergens;

  const CourseCardWidget({super.key, required this.courseName, required this.allergens});

  ImageIcon getMenuTypeIcon(String courseName) {
    if (courseName.toLowerCase().contains("salad")) {
      return const ImageIcon(
        AssetImage('assets/icon_salad.png'),
        color: Colors.green,
        size: 44,
      );
    } else if (courseName.toLowerCase().contains("soup")) {
      return const ImageIcon(
        AssetImage('assets/icon_soup.png'),
        color: Colors.red,
        size: 44,
      );
    } else {
      return const ImageIcon(
        AssetImage('assets/icon_dinner.png'),
        color: Colors.cyan,
        size: 44,
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
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (allergens.contains("L"))
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          color: Colors.blue,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: ImageIcon(
                            AssetImage(
                              'assets/icon_lactose_free.png',
                            ),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    if (allergens.contains("G"))
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          color: Colors.orange,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: ImageIcon(
                            AssetImage(
                              'assets/icon_gluten_free.png',
                            ),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
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
