import 'dart:convert';

RequestResult requestResultFromJson(String str) => RequestResult.fromJson(json.decode(str));

String requestResultToJson(RequestResult data) => json.encode(data.toJson());

class RequestResult {
  final bool result;

  RequestResult({
    required this.result,
  });

  factory RequestResult.fromJson(Map<String, dynamic> json) => RequestResult(
        result: json["result"],
      );

  Map<String, dynamic> toJson() => {
        "result": result,
      };
}
