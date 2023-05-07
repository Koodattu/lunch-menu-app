import "dart:io";

import "package:easy_localization/easy_localization.dart";
import "package:http/http.dart" as http;
import "package:tuple/tuple.dart";

const localhostUrl = "http://10.0.2.2:8888";
const serverUrl = "http://10.0.2.2:8888";
const currentUrl = localhostUrl;

const apiBasePath = "/api/v1";

class NetworkingService {
  Future<Object> getFromApi(String path) async {
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

  Future<Object> postToApi(String path, String body) async {
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
