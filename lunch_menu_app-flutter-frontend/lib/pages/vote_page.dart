import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/model/menu_week.dart';
import "package:http/http.dart" as http;

class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> with AutomaticKeepAliveClientMixin<VotePage> {
  late Future<List<MenuCourse>> menuCourses;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getAllMenuCourses();
  }

  getAllMenuCourses() {
    setState(() {
      menuCourses = fetchAll();
    });
  }

  Future<List<MenuCourse>> fetchAll() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8888/api/v1/lunch-menu-courses'))
        .timeout(const Duration(seconds: 10));

    return menuCourseListFromJson(utf8.decode(response.bodyBytes));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: () async {
          await getAllMenuCourses();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FutureBuilder<List<MenuCourse>>(
                future: menuCourses,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        const Text(
                          "most_liked_courses",
                          style: TextStyle(fontSize: 18),
                        ).tr(),
                        Card(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: 3,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              MenuCourse menuCourse = snapshot.data![index];

                              return Row(
                                children: [
                                  const Icon(Icons.abc),
                                  Flexible(
                                    child: Column(
                                      children: [
                                        Text(menuCourse.courseName),
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.thumb_up, color: Colors.green),
                                              Text(menuCourse.courseVote.likes.toString()),
                                              const Expanded(
                                                child: LinearProgressIndicator(
                                                  minHeight: 6,
                                                  backgroundColor: Colors.red,
                                                  color: Colors.green,
                                                  value: 0.5,
                                                ),
                                              ),
                                              Text(menuCourse.courseVote.dislikes.toString()),
                                              const Icon(Icons.thumb_down, color: Colors.red),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              );
                            },
                          ),
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
