import 'dart:convert';

import 'menu_course.dart';

class MenuDay {
  MenuDay({
    required this.id,
    required this.dayName,
    required this.menuCourses,
  });

  final int id;
  final String dayName;
  final List<MenuCourse> menuCourses;

  factory MenuDay.fromRawJson(String str) => MenuDay.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MenuDay.fromJson(Map<String, dynamic> json) => MenuDay(
        id: json["id"],
        dayName: json["dayName"],
        menuCourses: List<MenuCourse>.from(json["menuCourses"].map((x) => MenuCourse.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dayName": dayName,
        "menuCourses": List<dynamic>.from(menuCourses.map((x) => x.toJson())),
      };
}
