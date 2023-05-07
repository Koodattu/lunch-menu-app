import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/model/menu_week.dart';
import 'package:flutter_lunch_menu_app/model/user_saved_vote.dart';
import 'package:flutter_lunch_menu_app/pages/menu_page.dart';
import 'package:flutter_lunch_menu_app/services/vote_saving_service.dart';
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

                                    return CourseLikesDislikes(menuCourse: menuCourse, index: index);
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AllMostLikedCourses(courses: snapshot.data!),
                                          ),
                                        );
                                      },
                                      child: const Text("show_all").tr(),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VoteOnCourses(
                                              menuCourses: snapshot.data!,
                                            ),
                                          ),
                                        );
                                      },
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

class CourseLikesDislikes extends StatelessWidget {
  const CourseLikesDislikes({super.key, required this.menuCourse, required this.index});

  final MenuCourse menuCourse;
  final int index;

  ImageIcon getRankIcon(int rank, String courseType) {
    if (rank >= 0 && rank <= 2) {
      final colors = [Colors.yellow, Colors.grey, Colors.brown];

      return ImageIcon(
        AssetImage("assets/icon_trophy_$rank.png"),
        size: 50,
        color: colors[rank],
      );
    }

    if (courseType.toLowerCase().contains("salad")) {
      return const ImageIcon(
        AssetImage('assets/icon_salad.png'),
        color: Colors.green,
        size: 50,
      );
    } else if (courseType.toLowerCase().contains("soup")) {
      return const ImageIcon(
        AssetImage('assets/icon_soup.png'),
        color: Colors.red,
        size: 50,
      );
    } else {
      return const ImageIcon(
        AssetImage('assets/icon_dinner.png'),
        color: Colors.cyan,
        size: 50,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          getRankIcon(index, menuCourse.courseType),
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
  }
}

class AllMostLikedCourses extends StatelessWidget {
  const AllMostLikedCourses({super.key, required this.courses});

  final List<MenuCourse> courses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("most_liked_courses").tr(),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: courses.where((element) => element.courseVote.calculateLikeDislikeRatio() != -1).length,
        itemBuilder: (context, index) {
          MenuCourse course = courses[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CourseLikesDislikes(menuCourse: course, index: index),
            ),
          );
        },
      ),
    );
  }
}

class VoteOnCourses extends StatefulWidget {
  const VoteOnCourses({super.key, required this.menuCourses});

  final List<MenuCourse> menuCourses;

  @override
  State<VoteOnCourses> createState() => _VoteOnCoursesState();
}

class _VoteOnCoursesState extends State<VoteOnCourses> {
  bool loading = true;
  VoteSavingService voteSavingService = VoteSavingService();
  List<MenuCourse> coursesToVote = [];
  List<UserSavedVote> savedVotes = [];
  MenuCourse? currentCourse;

  @override
  void initState() {
    super.initState();
    readSavedVotes();
  }

  void readSavedVotes() async {
    savedVotes = await voteSavingService.getAllVotes();
    coursesToVote = getCoursesWithoutVotes(widget.menuCourses, savedVotes);
    if (coursesToVote.isNotEmpty) {
      currentCourse = getRandomCourse(coursesToVote);
    }
    setState(() {
      loading = false;
    });
  }

  List<MenuCourse> getCoursesWithoutVotes(List<MenuCourse> allCourses, List<UserSavedVote> savedCourseVotes) {
    List<MenuCourse> coursesWithoutVotes = [];

    for (var course in allCourses) {
      var saved = savedCourseVotes.firstWhereOrNull((element) => element.id == course.id);
      if (saved == null || !saved.liked && !saved.disliked) {
        coursesWithoutVotes.add(course);
      }
    }

    return coursesWithoutVotes;
  }

  MenuCourse getRandomCourse(List<MenuCourse> menuCourses) {
    Random random = Random();
    MenuCourse randomMenuCourse = menuCourses[random.nextInt(menuCourses.length)];
    currentCourse ??= randomMenuCourse;
    while (randomMenuCourse == currentCourse && coursesToVote.length >= 2) {
      randomMenuCourse = menuCourses[random.nextInt(menuCourses.length)];
    }

    return randomMenuCourse;
  }

  void vote(bool? vote, MenuCourse courseVotedOn) async {
    bool savingResult = false;

    if (vote == true || vote == false) {
      UserSavedVote savedVote = await voteSavingService.getVote(courseVotedOn.id);
      UserSavedVote newSavedVote = await voteSavingService.saveVote(vote!, savedVote, courseVotedOn.id);
      savingResult = savedVote != newSavedVote;
    }

    if (savingResult) {
      coursesToVote.remove(courseVotedOn);
    }

    if (savingResult || vote == null) {
      setState(() {
        if (coursesToVote.isNotEmpty) {
          currentCourse = getRandomCourse(coursesToVote);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vote").tr(),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            if (loading) {
              return const CircularProgressIndicator();
            }
            if (coursesToVote.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      "all_voted",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ).tr(),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllVotedCourses(
                            votedCourses: widget.menuCourses.where((e) => !coursesToVote.contains(e)).toList(),
                          ),
                        ),
                      ).then((value) => readSavedVotes());
                    },
                    child: const Text("change_votes").tr(),
                  ),
                ],
              );
            }

            return SizedBox(
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "what_do_you_think_of",
                    style: TextStyle(fontSize: 22),
                  ).tr(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CourseCardWidget(
                      menuCourse: currentCourse!,
                      showVoteIcons: false,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BigVoteButton(
                        callback: () => vote(true, currentCourse!),
                        color: Colors.green,
                        icon: Icons.thumb_up_outlined,
                      ),
                      BigVoteButton(
                        callback: () => vote(null, currentCourse!),
                        color: Colors.yellow,
                        icon: Icons.skip_next,
                      ),
                      BigVoteButton(
                        callback: () => vote(false, currentCourse!),
                        color: Colors.red,
                        icon: Icons.thumb_down_outlined,
                      ),
                    ],
                  ),
                  const Text("left_to_vote_on").tr(args: [coursesToVote.length.toString()]),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllVotedCourses(
                            votedCourses: widget.menuCourses.where((e) => !coursesToVote.contains(e)).toList(),
                          ),
                        ),
                      ).then((value) => readSavedVotes());
                    },
                    child: const Text("change_votes").tr(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class BigVoteButton extends StatelessWidget {
  const BigVoteButton({super.key, required this.callback, required this.color, required this.icon});

  final VoidCallback callback;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 4, color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: callback,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 48,
            color: color,
          ),
        ),
      ),
    );
  }
}

class AllVotedCourses extends StatefulWidget {
  const AllVotedCourses({super.key, required this.votedCourses});

  final List<MenuCourse> votedCourses;

  @override
  State<AllVotedCourses> createState() => _AllVotedCoursesState();
}

class _AllVotedCoursesState extends State<AllVotedCourses> {
  List<MenuCourse> filteredCourses = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCourses = widget.votedCourses;
  }

  void searchCourse(String searchTerm) {
    setState(() {
      filteredCourses = widget.votedCourses
          .where((element) => element.courseName.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("change_votes").tr(),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "course_name".tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                onChanged: searchCourse,
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  MenuCourse course = filteredCourses[index];

                  return CourseCardWidget(menuCourse: course, showVoteIcons: true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
