import 'dart:io';

import 'package:flutter_lunch_menu_app/model/user_saved_vote.dart';
import 'package:path_provider/path_provider.dart';

class LocalVoteStorageService {
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
