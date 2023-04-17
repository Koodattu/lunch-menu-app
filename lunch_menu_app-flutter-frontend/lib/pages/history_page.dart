import 'dart:convert';

import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/model/menu_week.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<MenuWeek>> menuWeek;

  @override
  void initState() {
    super.initState();

    setState(() {
      menuWeek = fetchAll();
    });
  }

  Future<List<MenuWeek>> fetchAll() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8888/api/v1/lunch-menu-weeks'));

    if (response.statusCode == 200) {
      return menuWeekListFromJson(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: FutureBuilder<List<MenuWeek>>(
        future: menuWeek,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                MenuWeek menuWeek = snapshot.data![index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menuWeek.weekName,
                          style: const TextStyle(fontSize: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Salad: ${menuWeek.saladCoursePrice}"),
                              Text("Soup: ${menuWeek.soupCoursePrice}"),
                              Text("Main: ${menuWeek.mainCoursePrice}"),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: menuWeek.menuDays.length,
                          itemBuilder: (context, index) {
                            MenuDay menuDay = menuWeek.menuDays[index];
                            return Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(menuDay.dayName),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: menuDay.menuCourses.length,
                                      itemBuilder: (context, index) {
                                        MenuCourse menuCourse = menuDay.menuCourses[index];
                                        return Text(menuCourse.courseName);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
