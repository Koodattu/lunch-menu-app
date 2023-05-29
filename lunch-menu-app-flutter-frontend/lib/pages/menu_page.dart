import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_lunch_menu_app/constants/app_settings_keys.dart';
import 'package:flutter_lunch_menu_app/model/user_saved_vote.dart';
import 'package:flutter_lunch_menu_app/model/user_saved_vote_model.dart';
import 'package:flutter_lunch_menu_app/services/networking_service.dart';
import 'package:flutter_lunch_menu_app/services/vote_saving_service.dart';
import 'package:flutter/material.dart';

import 'package:flutter_lunch_menu_app/model/menu_week.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with AutomaticKeepAliveClientMixin<MenuPage> {
  NetworkingService networkingService = NetworkingService();
  late SharedPreferences sharedPreferences;
  late Future<MenuWeek> menuWeek;

  bool showToday = true;
  bool showTomorrow = true;
  bool latestIsCurrentWeek = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initWeekMenu();
  }

  _initWeekMenu() {
    _getSettings();
    setState(() {
      menuWeek = _fetchMenu();
    });
  }

  _getSettings() async {
    sharedPreferences = await SharedPreferences.getInstance();
    showToday = sharedPreferences.getBool(appSettingShowToday) ?? true;
    showTomorrow = sharedPreferences.getBool(appSettingShowTomorrow) ?? true;
  }

  Future<MenuWeek> _fetchMenu() async {
    var response = await networkingService.getFromApi(RestApiType.latestMenuWeek);
    if (response is MenuWeek) {
      latestIsCurrentWeek = response.weekName.contains(_weekNumber(DateTime.now()).toString());

      return Future.value(response);
    }

    return Future.error(response);
  }

  int _numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));

    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  int _weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = _numOfWeeks(date.year - 1);
    } else if (woy > _numOfWeeks(date.year)) {
      woy = 1;
    }

    return woy;
  }

  MenuDay? _getMenuDay(MenuWeek? menuWeek, bool tomorrow) {
    DateTime now = DateTime.now();
    int dayOfWeek = tomorrow ? now.weekday : now.weekday - 1;
    if (menuWeek!.menuDays.length <= dayOfWeek) {
      return null;
    }

    return menuWeek.menuDays[dayOfWeek];
  }

  String _getWeekNumber(String weekName) {
    return weekName.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: () async {
          await _initWeekMenu();
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
                        if (!latestIsCurrentWeek)
                          Padding(
                            padding: const EdgeInsets.only(top: 32, bottom: 16),
                            child: const Text(
                              "current_week_not_yet_available",
                              style: TextStyle(fontSize: 16, color: Colors.orange),
                              textAlign: TextAlign.center,
                            ).tr(),
                          ),
                        if (showToday && latestIsCurrentWeek)
                          DayMenuTitleWidget(
                            relativeDay: "today".tr(),
                            menuDay: _getMenuDay(snapshot.data, false),
                            showVoteIcons: true,
                          ),
                        if (showTomorrow && latestIsCurrentWeek)
                          DayMenuTitleWidget(
                            relativeDay: "tomorrow".tr(),
                            menuDay: _getMenuDay(snapshot.data, true),
                            showVoteIcons: false,
                          ),
                        const SizedBox(
                          height: 16,
                        ),
                        Center(
                          child: Text(
                            "this_weeks_menu".tr(args: [_getWeekNumber(snapshot.data!.weekName)]),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.menuDays.length,
                          itemBuilder: (context, index) {
                            MenuDay menuDay = snapshot.data!.menuDays[index];

                            return DayMenuWidget(
                              menuDay: menuDay,
                              showVoteIcons: false,
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

class DayMenuTitleWidget extends StatelessWidget {
  const DayMenuTitleWidget({
    super.key,
    required this.relativeDay,
    required this.menuDay,
    required this.showVoteIcons,
  });

  final String relativeDay;
  final MenuDay? menuDay;
  final bool showVoteIcons;

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
        DayMenuWidget(
          menuDay: menuDay,
          showVoteIcons: showVoteIcons,
        ),
      ],
    );
  }
}

class DayMenuWidget extends StatelessWidget {
  const DayMenuWidget({
    super.key,
    required this.menuDay,
    required this.showVoteIcons,
  });

  final MenuDay? menuDay;
  final bool showVoteIcons;

  String _lengthenDayName(String dayName) {
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
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            _lengthenDayName(menuDay!.dayName),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menuDay!.menuCourses.length,
          itemBuilder: (context, index) {
            MenuCourse menuCourse = menuDay!.menuCourses[index];

            return CourseCardWidget(
              menuCourse: menuCourse,
              showVoteIcons: showVoteIcons,
            );
          },
        ),
      ],
    );
  }
}

class CourseCardWidget extends StatelessWidget {
  final MenuCourse menuCourse;
  final bool showVoteIcons;
  final VoidCallback? voidCallback;

  const CourseCardWidget({
    super.key,
    required this.menuCourse,
    this.showVoteIcons = false,
    this.voidCallback,
  });

  ImageIcon _getMenuTypeIcon(String courseType) {
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
    return SizedBox(
      height: 100,
      child: Card(
        child: InkWell(
          onTap: voidCallback,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _getMenuTypeIcon(menuCourse.courseType),
                      const SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menuCourse.courseName,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (menuCourse.allergens.any((i) => i.allergenSymbol == "L"))
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
                                if (menuCourse.allergens.any((i) => i.allergenSymbol == "G"))
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
                      ),
                    ],
                  ),
                ),
                if (showVoteIcons) VoteIcons(menuCourseId: menuCourse.id),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VoteIcons extends StatefulWidget {
  const VoteIcons({
    super.key,
    required this.menuCourseId,
  });

  final int menuCourseId;

  @override
  State<VoteIcons> createState() => _VoteIconsState();
}

class _VoteIconsState extends State<VoteIcons> {
  VoteSavingService voteSavingService = VoteSavingService();

  void _voteButtonPressed(UserSavedVoteModel votes, bool votedLike) async {
    UserSavedVote savedVote = votes.findVoteById(widget.menuCourseId);
    UserSavedVote newSavedVote = await voteSavingService.saveVote(votedLike, votes, widget.menuCourseId);
/*
    if (newSavedVote != savedVote) {
      setState(() {
        savedVote = newSavedVote;
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSavedVoteModel>(
      builder: (context, votes, child) {
        UserSavedVote savedVote = votes.findVoteById(widget.menuCourseId);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => _voteButtonPressed(votes, true),
                icon: Icon(
                  savedVote.liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => _voteButtonPressed(votes, false),
                icon: Icon(
                  savedVote.disliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
