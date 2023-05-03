import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/model/menu_week.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with AutomaticKeepAliveClientMixin<HistoryPage> {
  late Future<List<MenuWeek>> menuWeeks;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getAllMenuWeeks();
  }

  getAllMenuWeeks() {
    setState(() {
      menuWeeks = fetchAll();
    });
  }

  Future<List<MenuWeek>> fetchAll() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8888/api/v1/lunch-menu-weeks')).timeout(const Duration(seconds: 10));

    return menuWeekListFromJson(utf8.decode(response.bodyBytes));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: () async {
          await getAllMenuWeeks();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FutureBuilder<List<MenuWeek>>(
                future: menuWeeks,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            MenuWeek menuWeek = snapshot.data![index];

                            return Card(
                              child: ExpandablePanel(
                                header: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  child: Text(
                                    menuWeek.weekName,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                collapsed: const SizedBox(),
                                expanded: Column(
                                  children: [
                                    const Divider(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8),
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
                                  ],
                                ),
                              ),
                            );
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
