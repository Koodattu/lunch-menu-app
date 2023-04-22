import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_lunch_menu_app/model/user_saved_vote.dart';
import 'package:path_provider/path_provider.dart';

class UserSavedVotesService {
  Future<String> get _localPath async {
    final Directory directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final String path = await _localPath;

    return File('$path/user_saved_votes.json');
  }

  Future<bool> writeFile(List<UserSavedVote> userSavedVotes) async {
    try {
      final File file = await _localFile;
      await file.writeAsString(userSavedVoteListToJson(userSavedVotes));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserSavedVote>> readFile() async {
    try {
      final File file = await _localFile;
      final String contents = await file.readAsString();

      return userSavedVoteListFromJson(contents);
    } catch (e) {
      return [];
    }
  }

  Future<UserSavedVote> readFromFile(int id) async {
    final List<UserSavedVote> saved = await readFile();

    return saved.firstWhereOrNull((element) => element.id == id) ??
        UserSavedVote(id: id, liked: false, disliked: false);
  }

  Future<bool> writeToFile(UserSavedVote userSavedVote) async {
    List<UserSavedVote> saved = await readFile();
    UserSavedVote? vote = saved.firstWhereOrNull((element) => element.id == userSavedVote.id);
    if (vote == null) {
      saved.add(userSavedVote);
    } else {
      saved[saved.indexOf(vote)] = userSavedVote;
    }

    return writeFile(saved);
  }

  Future<bool> deleteFile() async {
    try {
      final File file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
