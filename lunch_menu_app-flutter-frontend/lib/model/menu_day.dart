import 'package:flutter_lunch_menu_app/model/menu_course.dart';

class MenuDay {
  String dayName;
  List<MenuCourse> menuCourses;
  MenuDay({
    required this.dayName,
    required this.menuCourses,
  });
}
