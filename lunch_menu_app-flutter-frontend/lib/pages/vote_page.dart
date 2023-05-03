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

    List<MenuCourse> unsortedCourses = menuCourseListFromJson(utf8.decode(response.bodyBytes));
    unsortedCourses.sort(sortByLikeDislikeRatio);
    unsortedCourses = unsortedCourses.reversed.toList();

    return unsortedCourses;
  }

  int sortByLikeDislikeRatio(MenuCourse a, MenuCourse b) {
    final ratioA = a.courseVote.calculateLikeDislikeRatio();
    final ratioB = b.courseVote.calculateLikeDislikeRatio();

    final likesA = a.courseVote.likes;
    final likesB = b.courseVote.likes;

    final votesA = likesA + a.courseVote.dislikes;
    final votesB = likesB + b.courseVote.dislikes;

    if (ratioA == ratioB) {
      if (likesA == likesB) {
        if (votesA < votesB) {
          return -1;
        } else if (votesA > votesB) {
          return 1;
        }
      }

      if (likesA < likesB) {
        return -1;
      } else if (likesA > likesB) {
        return 1;
      }
    }

    if (ratioA < ratioB) {
      return -1;
    } else if (ratioA > ratioB) {
      return 1;
    }

    return 0;
  }

  ImageIcon getRankIcon(int rank) {
    if (rank >= 0 && rank <= 2) {
      final colors = [Colors.yellow, Colors.grey, Colors.brown];

      return ImageIcon(
        AssetImage("assets/icon_trophy_$rank.png"),
        size: 50,
        color: colors[rank],
      );
    }

    return const ImageIcon(
      AssetImage("assets/icon_dinner.png"),
      size: 24,
    );
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            "most_liked_courses",
                            style: TextStyle(fontSize: 20),
                          ).tr(),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: 6,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    MenuCourse menuCourse = snapshot.data![index];

                                    if (index.isOdd) {
                                      return const Divider();
                                    }

                                    index = index ~/ 2;

                                    return Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          getRankIcon(index),
                                          Flexible(
                                            child: Column(
                                              children: [
                                                Text(
                                                  menuCourse.courseName,
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(4),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.thumb_up, color: Colors.green),
                                                      Text(menuCourse.courseVote.likes.toString()),
                                                      Expanded(
                                                        child: LinearProgressIndicator(
                                                          minHeight: 6,
                                                          backgroundColor: Colors.red,
                                                          color: Colors.green,
                                                          value: menuCourse.courseVote.calculateLikeDislikeRatio(),
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
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: const Text("show_all").tr(),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: const Text("vote").tr(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
