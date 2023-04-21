import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';

import 'package:flutter_lunch_menu_app/model/menu_week.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late SharedPreferences sharedPreferences;
  late Future<MenuWeek> menuWeek;

  bool showToday = true;
  bool showTomorrow = true;

  @override
  void initState() {
    super.initState();
    initWeekMenu();
  }

  initWeekMenu() async {
    getSettings();
    setState(() {
      menuWeek = fetchMenu();
    });
  }

  getSettings() async {
    sharedPreferences = await SharedPreferences.getInstance();
    showToday = sharedPreferences.getBool("app_settings_menu_show_today") ?? true;
    showTomorrow = sharedPreferences.getBool("app_settings_menu_show_tomorrow") ?? true;
  }

  Future<MenuWeek> fetchMenu() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8888/api/v1/lunch-menu-weeks/latest'))
        .timeout(const Duration(seconds: 10));
    return menuWeekFromJson(utf8.decode(response.bodyBytes));
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
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: () async {
          await initWeekMenu();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FutureBuilder<MenuWeek>(
                future: menuWeek,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Column(
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              "lunch_menu_app".tr(),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("lunch".tr()),
                                const Icon(Icons.access_time),
                                const Text("10:30-13:00"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text("salad_dish_price").tr(args: [snapshot.data!.saladCoursePrice]),
                                const Text("soup_dish_price").tr(args: [snapshot.data!.soupCoursePrice]),
                                const Text("main_dish_price").tr(args: [snapshot.data!.mainCoursePrice]),
                              ],
                            ),
                          ],
                        ),
                        if (showToday)
                          DayMenuTitleWidget(
                            relativeDay: "today".tr(),
                            menuDay: getMenuDay(snapshot.data, false),
                          ),
                        if (showTomorrow)
                          DayMenuTitleWidget(
                            relativeDay: "tomorrow".tr(),
                            menuDay: getMenuDay(snapshot.data, true),
                          ),
                        const SizedBox(
                          height: 16,
                        ),
                        Center(
                          child: Text(
                            "this_week".tr(args: [snapshot.data!.weekName]),
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
                    return Center(
                      child: Text(
                        "error_occurred".tr(args: [snapshot.error.toString()]),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    );
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
            ),
          ),
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

  String lengthenDayName(String dayName) {
    List<String> weekDays = ["monday".tr(), "tuesday".tr(), "wednesday".tr(), "thursday".tr(), "friday".tr()];
    List<String> daysInFinnish = ["Maanantai", "Tiistai", "Keskiviikko", "Torstai", "Perjantai"];

    for (var i = 0; i < daysInFinnish.length; i++) {
      if (daysInFinnish[i].startsWith(dayName.substring(0, 2))) {
        return dayName.replaceAll(dayName.substring(0, 2), weekDays[i]);
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
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
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
