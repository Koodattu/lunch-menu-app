// To parse this JSON data, do
//
//     final menuWeek = menuWeekFromJson(jsonString);

import 'dart:convert';

import 'menu_day.dart';

class MenuWeek {
  MenuWeek({
    required this.id,
    required this.weekName,
    required this.saladCoursePrice,
    required this.soupCoursePrice,
    required this.mainCoursePrice,
    required this.menuDays,
  });

  final int id;
  final String weekName;
  final String saladCoursePrice;
  final String soupCoursePrice;
  final String mainCoursePrice;
  final List<MenuDay> menuDays;

  factory MenuWeek.fromRawJson(String str) => MenuWeek.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MenuWeek.fromJson(Map<String, dynamic> json) => MenuWeek(
        id: json["id"],
        weekName: json["weekName"],
        saladCoursePrice: json["saladCoursePrice"],
        soupCoursePrice: json["soupCoursePrice"],
        mainCoursePrice: json["mainCoursePrice"],
        menuDays: List<MenuDay>.from(json["menuDays"].map((x) => MenuDay.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "weekName": weekName,
        "saladCoursePrice": saladCoursePrice,
        "soupCoursePrice": soupCoursePrice,
        "mainCoursePrice": mainCoursePrice,
        "menuDays": List<dynamic>.from(menuDays.map((x) => x.toJson())),
      };
}
