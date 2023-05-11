import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_lunch_menu_app/model/frequent_course.dart';
import 'package:flutter_lunch_menu_app/model/menu_week.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import "package:easy_localization/easy_localization.dart";
import "package:http/http.dart" as http;

const localhostUrl = "http://10.0.2.2:8888";
const serverUrl = "http://10.0.2.2:8888";
const currentUrl = localhostUrl;

const apiBasePath = "/api/v1";

class NetworkingService {
  Future<Object> getFromApi(RestApiType type) async {
    Object? response;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool("app_settings_use_mock_data") ?? false) {
      response = await _getMockData(type);
    } else {
      String apiPath = _getApiPath(type);
      response = await _getFromApi(apiPath);
    }

    return _handleData(type, response);
  }

  Future<Object> postToApi(RestApiType type, Object body) async {
    Object? response;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool("app_settings_use_mock_data") ?? false) {
      response = await _getMockData(type);
    } else {
      String apiPath = _getApiPath(type);
      String json = _getJsonFromObject(type, body);
      response = await _postToApi(apiPath, json);
    }

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
      case RestApiType.mostFrequentCourses:
        return "/lunch-menu-courses/frequent";
      case RestApiType.voteRanked:
        return "/lunch-menu-course-votes/ranked";
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
      case RestApiType.mostFrequentCourses:
        return frequentCoursesListFromJson(json);
      case RestApiType.voteRanked:
        return courseVoteListFromJson(json);
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
      case RestApiType.mostFrequentCourses:
        return frequentCoursesListToJson(object as List<FrequentCourse>);
      case RestApiType.voteRanked:
        return courseVoteListToJson(object as List<CourseVote>);
    }
  }

  Future<Object> _getMockData(RestApiType type) async {
    await Future.delayed(const Duration(seconds: 1));
    String data = "";
    switch (type) {
      case RestApiType.latestMenuWeek:
        data = await rootBundle.loadString("assets/mock_data/latest_menu_week.json");
        break;
      case RestApiType.allMenuWeeks:
        data = await rootBundle.loadString("assets/mock_data/all_menu_weeks.json");
        break;
      case RestApiType.allMenuCourses:
        data = await rootBundle.loadString("assets/mock_data/all_courses.json");
        break;
      case RestApiType.vote:
        data = await rootBundle.loadString("assets/mock_data/course_vote.json");
        break;
      case RestApiType.mostFrequentCourses:
        data = await rootBundle.loadString("assets/mock_data/frequent_courses.json");
        break;
      case RestApiType.voteRanked:
        data = await rootBundle.loadString("assets/mock_data/course_vote.json");
        break;
    }

    return Tuple2<int, String>(200, data);
  }

  Future<Object> _getFromApi(String path) async {
    try {
      http.Response response = await http.get(Uri.parse(currentUrl + apiBasePath + path), headers: {
        HttpHeaders.acceptHeader: "application/json; charset=UTF-8",
      }).timeout(
        const Duration(seconds: 10),
      );

      return Tuple2<int, String>(response.statusCode, response.body);
    } catch (e) {
      return _parseError(e.toString());
    }
  }

  Future<Object> _postToApi(String path, String body) async {
    try {
      http.Response response = await http.post(Uri.parse(currentUrl + apiBasePath + path), body: body, headers: {
        HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
      }).timeout(
        const Duration(seconds: 10),
      );

      return Tuple2<int, String>(response.statusCode, response.body);
    } catch (e) {
      return _parseError(e.toString());
    }
  }

  String _parseError(String errorText) {
    String customErrorText = "";
    if (errorText.contains("Connection failed") || errorText.contains("SocketException")) {
      errorText = errorText.replaceAll(currentUrl, "*");
      customErrorText = "server_or_internet_down".tr();
    }
    if (errorText.contains("TimeoutException")) {
      customErrorText = "server_or_internet_slow".tr();
    }

    return customErrorText != "" ? customErrorText : errorText;
  }
}

enum RestApiType { latestMenuWeek, allMenuWeeks, allMenuCourses, vote, mostFrequentCourses, voteRanked }
