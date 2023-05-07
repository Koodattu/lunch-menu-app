import 'dart:io';

import 'package:flutter_lunch_menu_app/model/menu_week.dart';
import 'package:flutter_lunch_menu_app/services/networking_service.dart';
import 'package:tuple/tuple.dart';

class MenuBackendService {
  final NetworkingService _networkingService = NetworkingService();

  Future<Object> getFromApi(RestApiType type) async {
    String apiPath = _getApiPath(type);
    var response = await _networkingService.getFromApi(apiPath);

    return _handleData(type, response);
  }

  Future<Object> postToApi(RestApiType type, Object body) async {
    String apiPath = _getApiPath(type);
    String json = _getJsonFromObject(type, body);
    var response = await _networkingService.postToApi(apiPath, json);

    return _handleData(type, response);
  }

  String _getApiPath(RestApiType type) {
    switch (type) {
      case RestApiType.latestMenuWeek:
        return "/lunch-menu-weeks/latest";
      case RestApiType.allMenuWeeks:
        return "/lunch-menu-weeks";
      case RestApiType.allMenuCourses:
        return "/lunch-menu-courses";
      case RestApiType.vote:
        return "/lunch-menu-course-votes/vote";
    }
  }

  Object _handleData(RestApiType type, Object data) {
    if (data is Tuple2) {
      int code = data.item1;
      String body = data.item2;

      return code == HttpStatus.ok ? _getObjectFromJson(type, body) : body;
    } else {
      return data;
    }
  }

  Object _getObjectFromJson(RestApiType type, String json) {
    switch (type) {
      case RestApiType.latestMenuWeek:
        return menuWeekFromJson(json);
      case RestApiType.allMenuWeeks:
        return menuWeekListFromJson(json);
      case RestApiType.allMenuCourses:
        return menuCourseListFromJson(json);
      case RestApiType.vote:
        return courseVoteFromJson(json);
    }
  }

  String _getJsonFromObject(RestApiType type, Object object) {
    switch (type) {
      case RestApiType.latestMenuWeek:
        return menuWeekToJson(object as MenuWeek);
      case RestApiType.allMenuWeeks:
        return menuWeekListToJson(object as List<MenuWeek>);
      case RestApiType.allMenuCourses:
        return menuCourseListToJson(object as List<MenuCourse>);
      case RestApiType.vote:
        return courseVoteToJson(object as CourseVote);
    }
  }
}

enum RestApiType { latestMenuWeek, allMenuWeeks, allMenuCourses, vote }
