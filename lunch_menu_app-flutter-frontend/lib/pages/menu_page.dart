import 'dart:convert';

import "package:http/http.dart" as http;
import 'package:flutter/material.dart';

import 'package:flutter_lunch_menu_app/model/menu_week.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<MenuWeek> menuWeek;

  @override
  void initState() {
    super.initState();

    setState(() {
      menuWeek = fetchMenu();
    });
  }

  Future<MenuWeek> fetchMenu() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8888/api/v1/lunch-menu-weeks/latest'));

    if (response.statusCode == 200) {
      return menuWeekFromJson(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load menu');
    }
  }

  MenuDay? getMenuDay(MenuWeek? menuWeek, bool tomorrow) {
    DateTime now = DateTime.now();
    int dayOfWeek = tomorrow ? now.weekday : now.weekday - 1;
    if (menuWeek!.menuDays.length <= dayOfWeek) {
      return null;
    }
    return menuWeek.menuDays[dayOfWeek];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: FutureBuilder<MenuWeek>(
        future: menuWeek,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
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
                      children: [
                        Text("Salad: ${snapshot.data!.saladCoursePrice}"),
                        Text("Soup: ${snapshot.data!.soupCoursePrice}"),
                        Text("Main: ${snapshot.data!.mainCoursePrice}"),
                      ],
                    ),
                  ],
                ),
                DayMenuTitleWidget(
                  relativeDay: "Today",
                  menuDay: getMenuDay(snapshot.data, false),
                ),
                DayMenuTitleWidget(
                  relativeDay: "Tomorrow",
                  menuDay: getMenuDay(snapshot.data, true),
                ),
                const SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    "This ${snapshot.data!.weekName}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.menuDays.length,
                  itemBuilder: (context, index) {
                    MenuDay menuDay = snapshot.data!.menuDays[index];
                    return DayMenuWidget(menuDay: menuDay);
                  },
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return const Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(),
            ),
          );
        },
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

  String lengthenDayName(String dayName) {
    List<String> daysInEnglish = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
    List<String> daysInFinnish = ["Maanantai", "Tiistai", "Keskiviikko", "Torstai", "Perjantai"];

    bool useEnglishTranslation = true;

    for (var i = 0; i < daysInFinnish.length; i++) {
      if (daysInFinnish[i].startsWith(dayName.substring(0, 2))) {
        return dayName.replaceAll(dayName.substring(0, 2), useEnglishTranslation ? daysInEnglish[i] : daysInFinnish[i]);
      }
    }

    return dayName;
  }

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
          lengthenDayName(menuDay!.dayName),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menuDay!.menuCourses.length,
          itemBuilder: (context, index) {
            MenuCourse menuCourse = menuDay!.menuCourses[index];
            return CourseCardWidget(
                courseName: menuCourse.courseName, courseType: menuCourse.courseType, allergens: menuCourse.allergens);
          },
        ),
      ],
    );
  }
}

class CourseCardWidget extends StatelessWidget {
  final String courseName;
  final String courseType;
  final List<Allergen> allergens;

  const CourseCardWidget({super.key, required this.courseName, required this.courseType, required this.allergens});

  ImageIcon getMenuTypeIcon(String courseName) {
    if (courseType.toLowerCase().contains("salad")) {
      return const ImageIcon(
        AssetImage('assets/icon_salad.png'),
        color: Colors.green,
        size: 44,
      );
    } else if (courseType.toLowerCase().contains("soup")) {
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
                    if (allergens.any((i) => i.allergenSymbol == "L"))
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
                    if (allergens.any((i) => i.allergenSymbol == "G"))
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
