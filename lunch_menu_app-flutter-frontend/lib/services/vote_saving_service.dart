import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/services/menu_backend_service.dart';
import 'package:flutter_lunch_menu_app/services/snackbar_service.dart';
import 'package:flutter_lunch_menu_app/model/menu_week.dart';
import 'package:flutter_lunch_menu_app/model/user_saved_vote.dart';
import 'package:flutter_lunch_menu_app/services/local_vote_storage_service.dart';

class VoteSavingService {
  LocalVoteStorageService savedVotesService = LocalVoteStorageService();
  MenuBackendService menuBackendService = MenuBackendService();

  Future<UserSavedVote> getVote(int id) async {
    final List<UserSavedVote> saved = await savedVotesService.readFile();

    return saved.firstWhereOrNull((element) => element.id == id) ??
        UserSavedVote(id: id, liked: false, disliked: false);
  }

  Future<List<UserSavedVote>> getAllVotes() async {
    return await savedVotesService.readFile();
  }

  Future<bool> saveVoteToFile(UserSavedVote userSavedVote) async {
    List<UserSavedVote> saved = await savedVotesService.readFile();
    UserSavedVote? vote = saved.firstWhereOrNull((element) => element.id == userSavedVote.id);
    if (vote == null) {
      saved.add(userSavedVote);
    } else {
      saved[saved.indexOf(vote)] = userSavedVote;
    }

    return savedVotesService.writeFile(saved);
  }

  Future<UserSavedVote> saveVote(bool votedLike, UserSavedVote savedVote, int menuCourseId) async {
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

    CourseVote courseVote = CourseVote(id: menuCourseId, likes: likes, dislikes: dislikes);

    var response = await menuBackendService.postToApi(RestApiType.vote, courseVote);
    if (response is CourseVote) {
      SnackBarService().showSnackBar("vote_succesful".tr(), Colors.green.shade600, Colors.white, Icons.done, true);

      return UserSavedVote(id: savedVote.id, liked: newLikeState, disliked: newDislikeState);
    }

    await saveVoteToFile(savedVote);
    SnackBarService().showSnackBar("vote_error".tr(), Colors.red.shade600, Colors.black, Icons.error_outline, true);

    return savedVote;
  }
}
