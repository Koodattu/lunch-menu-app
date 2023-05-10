import 'dart:math';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/model/course_last_seen.dart';
import 'package:flutter_lunch_menu_app/model/frequent_course.dart';
import 'package:flutter_lunch_menu_app/model/menu_week.dart';
import 'package:flutter_lunch_menu_app/model/user_saved_vote.dart';
import 'package:flutter_lunch_menu_app/pages/menu_page.dart';
import 'package:flutter_lunch_menu_app/services/networking_service.dart';
import 'package:flutter_lunch_menu_app/services/vote_saving_service.dart';
import 'package:tuple/tuple.dart';

class _CourseLists {
  List<MenuCourse> menuCourses;
  List<FrequentCourse> frequentCourses;
  List<CourseLastSeen> lastSeenCourses;
  _CourseLists(this.menuCourses, this.frequentCourses, this.lastSeenCourses);
}

enum _CourseType { mostLiked, frequent, longestWait, bestRanked }

class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> with AutomaticKeepAliveClientMixin<VotePage> {
  NetworkingService networkingService = NetworkingService();
  Future<_CourseLists>? courseLists;
  String? error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getAllMenuCourses();
  }

  getAllMenuCourses() async {
    List<MenuCourse> menuCourses = await fetchAllMenuCourses();
    List<FrequentCourse> frequentCourses = await fetchFrequentCourses();
    List<MenuWeek> menuWeeks = await fetchAllMenuWeeks();
    List<CourseLastSeen> lastSeenCourses = getLastSeenCourses(menuWeeks);
    setState(() {
      courseLists = error == null
          ? Future.value(_CourseLists(menuCourses, frequentCourses, lastSeenCourses))
          : Future.error(error!);
    });
  }

  Future<List<MenuCourse>> fetchAllMenuCourses() async {
    var response = await networkingService.getFromApi(RestApiType.allMenuCourses);

    if (response is List<MenuCourse>) {
      response.sort(sortByLikeDislikeRatio);
      response = response.reversed.toList();

      return response;
    }

    error = response as String;

    return [];
  }

  Future<List<FrequentCourse>> fetchFrequentCourses() async {
    var response = await networkingService.getFromApi(RestApiType.mostFrequentCourses);

    if (response is List<FrequentCourse>) {
      return response;
    }

    error = response as String;

    return [];
  }

  Future<List<MenuWeek>> fetchAllMenuWeeks() async {
    var response = await networkingService.getFromApi(RestApiType.allMenuWeeks);

    if (response is List<MenuWeek>) {
      return response;
    }

    error = response as String;

    return [];
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

  List<CourseLastSeen> getLastSeenCourses(List<MenuWeek> menuWeeks) {
    List<CourseLastSeen> lastSeenCourses = [];

    DateFormat format = DateFormat("dd.MM.yyyy");
    for (var week in menuWeeks) {
      for (var day in week.menuDays) {
        for (var course in day.menuCourses) {
          CourseLastSeen? lsCourse = lastSeenCourses.firstWhereOrNull((e) => e.course.courseName == course.courseName);
          DateTime dateTime =
              format.parse(day.dayName.substring(3, day.dayName.length) + week.documentSaveDate.year.toString());
          int daysSince = DateTime.now().difference(dateTime).inDays;
          if (lsCourse == null) {
            lastSeenCourses.add(CourseLastSeen(
              course: course,
              days: daysSince,
            ));
          } else {
            lastSeenCourses[lastSeenCourses.indexOf(lsCourse)].days = daysSince;
          }
        }
      }
    }

    lastSeenCourses.sort((a, b) => b.days.compareTo(a.days));

    return lastSeenCourses;
  }

  List<Tuple2<MenuCourse, int>> _getSortedList(List<MenuCourse> courses) {
    List<Tuple2<MenuCourse, int>> tupleList = courses.map((e) => Tuple2(e, e.courseVote.ranked)).toList();
    tupleList.sort((a, b) => b.item2.compareTo(a.item2));

    return tupleList;
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
              child: FutureBuilder<_CourseLists>(
                future: courseLists,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        _CoursesSummaryCard(
                          title: "most_liked_courses".tr(),
                          type: _CourseType.mostLiked,
                          coursesTuple: snapshot.data!.menuCourses.map((e) => Tuple2(e, 0)).toList(),
                        ),
                        _CoursesSummaryCard(
                          title: "best_ranked_courses".tr(),
                          type: _CourseType.bestRanked,
                          coursesTuple: _getSortedList(snapshot.data!.menuCourses),
                        ),
                        _CoursesSummaryCard(
                          title: "most_frequent_courses".tr(),
                          type: _CourseType.frequent,
                          coursesTuple: snapshot.data!.frequentCourses.map((e) => Tuple2(e.course, e.count)).toList(),
                        ),
                        _CoursesSummaryCard(
                          title: "longest_wait_courses".tr(),
                          type: _CourseType.longestWait,
                          coursesTuple: snapshot.data!.lastSeenCourses.map((e) => Tuple2(e.course, e.days)).toList(),
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

class MostLikedCoursesCard extends StatelessWidget {
  const MostLikedCoursesCard({
    super.key,
    required this.menuCourses,
  });

  final List<MenuCourse> menuCourses;

  @override
  Widget build(BuildContext context) {
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
                    MenuCourse menuCourse = menuCourses[index];

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
                            builder: (context) => AllMostLikedCourses(courses: menuCourses),
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
                              menuCourses: menuCourses,
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

class _CoursesSummaryCard extends StatelessWidget {
  const _CoursesSummaryCard({
    super.key,
    required this.title,
    required this.type,
    required this.coursesTuple,
  });

  final String title;
  final _CourseType type;
  final List<Tuple2<MenuCourse, int>> coursesTuple;

  Widget _getListRouteWidget(_CourseType type, String title, List<Tuple2<MenuCourse, int>> coursesTuple) {
    if (type == _CourseType.mostLiked) {
      return AllMostLikedCourses(courses: coursesTuple.map((e) => e.item1).toList());
    }

    return AllCoursesListView(title: title, coursesTuple: coursesTuple);
  }

  Widget _getVoteRouteWidget(_CourseType type) {
    if (type == _CourseType.mostLiked) {
      return VoteOnCourses(menuCourses: coursesTuple.map((e) => e.item1).toList());
    }
    if (type == _CourseType.bestRanked) {
      return Container();
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20),
          ),
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
                    Tuple2<MenuCourse, int> courseTuple = coursesTuple[index];

                    if (index.isOdd) {
                      return const Divider();
                    }

                    index = index ~/ 2;

                    if (type == _CourseType.mostLiked) {
                      return CourseLikesDislikes(menuCourse: courseTuple.item1, index: index);
                    }

                    return CourseRankCountWidget(course: courseTuple.item1, count: courseTuple.item2, index: index);
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
                            builder: (context) => _getListRouteWidget(type, title, coursesTuple),
                          ),
                        );
                      },
                      child: const Text("show_all").tr(),
                    ),
                    if (type == _CourseType.mostLiked || type == _CourseType.bestRanked)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => _getVoteRouteWidget(type),
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
  }
}

class CourseRankCountWidget extends StatelessWidget {
  const CourseRankCountWidget({super.key, required this.course, required this.count, required this.index});

  final MenuCourse course;
  final int count;
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getRankIcon(index, course.courseType),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                course.courseName,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class AllCoursesListView extends StatefulWidget {
  const AllCoursesListView({super.key, required this.title, required this.coursesTuple});

  final String title;
  final List<Tuple2<MenuCourse, int>> coursesTuple;

  @override
  State<AllCoursesListView> createState() => _AllCoursesListViewState();
}

class _AllCoursesListViewState extends State<AllCoursesListView> {
  List<Tuple2<MenuCourse, int>> filteredCourses = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCourses = widget.coursesTuple;
  }

  void searchCourse(String searchTerm) {
    setState(() {
      filteredCourses = widget.coursesTuple
          .where((element) => element.item1.courseName.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                  Tuple2<MenuCourse, int> courseTuple = filteredCourses[index];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CourseRankCountWidget(
                        course: courseTuple.item1,
                        count: courseTuple.item2,
                        index: index,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
