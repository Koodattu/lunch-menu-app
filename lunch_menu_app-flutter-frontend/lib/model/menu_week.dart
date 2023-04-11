import 'package:flutter_lunch_menu_app/model/menu_day.dart';

class MenuWeek {
  String weekName;
  List<MenuDay> menuDays;
  MenuWeek({
    required this.weekName,
    required this.menuDays,
  });
}
