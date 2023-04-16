import 'dart:convert';

import 'menu_allergen.dart';

class MenuCourse {
  MenuCourse({
    required this.id,
    required this.courseName,
    required this.courseType,
    required this.allergens,
  });

  final int id;
  final String courseName;
  final String courseType;
  final List<Allergen> allergens;

  factory MenuCourse.fromRawJson(String str) => MenuCourse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MenuCourse.fromJson(Map<String, dynamic> json) => MenuCourse(
        id: json["id"],
        courseName: json["courseName"],
        courseType: json["courseType"],
        allergens: List<Allergen>.from(json["allergens"].map((x) => Allergen.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "courseName": courseName,
        "courseType": courseType,
        "allergens": List<dynamic>.from(allergens.map((x) => x.toJson())),
      };
}
