import 'dart:convert';

import 'package:flutter_lunch_menu_app/model/menu_week.dart';

List<FrequentCourse> frequentCoursesListFromJson(String str) =>
    List<FrequentCourse>.from(json.decode(str).map((x) => FrequentCourse.fromJson(x)));

String frequentCoursesListToJson(List<FrequentCourse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FrequentCourse {
  final MenuCourse course;
  final int count;

  FrequentCourse({
    required this.course,
    required this.count,
  });

  factory FrequentCourse.fromJson(Map<String, dynamic> json) => FrequentCourse(
        course: MenuCourse.fromJson(json["course"]),
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "course": course.toJson(),
        "count": count,
      };
}
