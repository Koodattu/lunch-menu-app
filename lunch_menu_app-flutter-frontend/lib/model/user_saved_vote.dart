import 'dart:convert';

List<UserSavedVote> userSavedVoteListFromJson(String str) =>
    List<UserSavedVote>.from(json.decode(str).map((x) => UserSavedVote.fromJson(x)));
String userSavedVoteListToJson(List<UserSavedVote> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserSavedVote {
  UserSavedVote({required this.id, required this.liked, required this.disliked});

  final int id;
  bool liked;
  bool disliked;

  factory UserSavedVote.fromJson(Map<String, dynamic> json) => UserSavedVote(
        id: json["id"],
        liked: json["liked"],
        disliked: json["disliked"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "liked": liked,
        "disliked": disliked,
      };
}
