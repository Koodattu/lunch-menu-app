import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/model/user_saved_vote_model.dart';
import 'package:flutter_lunch_menu_app/services/networking_service.dart';
import 'package:flutter_lunch_menu_app/services/snackbar_service.dart';
import 'package:flutter_lunch_menu_app/model/menu_week.dart';
import 'package:flutter_lunch_menu_app/model/user_saved_vote.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VoteSavingService {
  final NetworkingService _networkingService = NetworkingService();

  Future<UserSavedVote> getVote(int id) async {
    final List<UserSavedVote> saved = await _readFile();

    return saved.firstWhereOrNull((element) => element.id == id) ??
        UserSavedVote(id: id, liked: false, disliked: false);
  }

  Future<List<UserSavedVote>> getAllVotes() async {
    return await _readFile();
  }

  Future<bool> saveVoteToFile(UserSavedVote userSavedVote) async {
    List<UserSavedVote> saved = await _readFile();
    UserSavedVote? vote = saved.firstWhereOrNull((element) => element.id == userSavedVote.id);
    if (vote == null) {
      saved.add(userSavedVote);
    } else {
      saved[saved.indexOf(vote)] = userSavedVote;
    }

    return _writeFile(saved);
  }

  Future<UserSavedVote> saveVote(bool votedLike, UserSavedVoteModel savedVotes, int menuCourseId) async {
    UserSavedVote savedVote = savedVotes.findVoteById(menuCourseId);
    bool oldLikeState = savedVote.liked;
    bool oldDislikeState = savedVote.disliked;

    bool newLikeState = oldLikeState && votedLike ? !votedLike : votedLike;
    bool newDislikeState = oldDislikeState && !votedLike ? votedLike : !votedLike;

    int likes = 0;
    int dislikes = 0;

    if (newLikeState && !oldLikeState) {
      likes++;
      if (!newDislikeState && oldDislikeState) {
        dislikes--;
      }
    } else if (!newLikeState && oldLikeState && !newDislikeState && !oldDislikeState) {
      likes--;
    }

    if (newDislikeState && !oldDislikeState) {
      dislikes++;
      if (!newLikeState && oldLikeState) {
        likes--;
      }
    } else if (!newDislikeState && oldDislikeState && !newLikeState && !oldLikeState) {
      dislikes--;
    }

    UserSavedVote newSavedVote = UserSavedVote(id: savedVote.id, liked: newLikeState, disliked: newDislikeState);

    bool localSaveResult = await saveVoteToFile(newSavedVote);

    if (!localSaveResult) {
      SnackBarService().showSnackBar("vote_error".tr(), Colors.red, Colors.black, Icons.error, true);

      return savedVote;
    }

    CourseVote courseVote = CourseVote(id: menuCourseId, likes: likes, dislikes: dislikes, ranked: 0);

    var response = await _networkingService.postToApi(RestApiType.vote, courseVote);
    if (response is CourseVote) {
      savedVotes.changeVote(newSavedVote);
      SnackBarService().showSnackBar("vote_succesful".tr(), Colors.green.shade600, Colors.white, Icons.done, true);

      return UserSavedVote(id: savedVote.id, liked: newLikeState, disliked: newDislikeState);
    }

    await saveVoteToFile(savedVote);
    SnackBarService().showSnackBar("vote_error".tr(), Colors.red.shade600, Colors.black, Icons.error_outline, true);

    return savedVote;
  }

  Future<bool> saveVoteRanked(CourseVote winner, CourseVote loser) async {
    var response = await _networkingService.postToApi(RestApiType.voteRanked, [winner, loser]);
    if (response is List<CourseVote>) {
      SnackBarService().showSnackBar("vote_succesful".tr(), Colors.green.shade600, Colors.white, Icons.done, true);

      return true;
    }

    SnackBarService().showSnackBar("vote_error".tr(), Colors.red, Colors.black, Icons.error, true);

    return false;
  }

  Future<bool> clearAllVotes() async {
    return await _deleteFile();
  }

  Future<String> get _localPath async {
    final Directory directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final String path = await _localPath;

    return File('$path/user_saved_votes.json');
  }

  Future<bool> _writeFile(List<UserSavedVote> userSavedVotes) async {
    try {
      final File file = await _localFile;
      await file.writeAsString(userSavedVoteListToJson(userSavedVotes));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserSavedVote>> _readFile() async {
    try {
      final File file = await _localFile;
      final String contents = await file.readAsString();

      return userSavedVoteListFromJson(contents);
    } catch (e) {
      return [];
    }
  }

  Future<bool> _deleteFile() async {
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
