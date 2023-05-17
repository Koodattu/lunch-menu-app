import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_menu_app/model/user_saved_vote.dart';
import 'package:flutter_lunch_menu_app/services/vote_saving_service.dart';

class UserSavedVoteModel extends ChangeNotifier {
  final List<UserSavedVote> _savedVotes = [];

  UnmodifiableListView<UserSavedVote> get savedVotes => UnmodifiableListView(_savedVotes);

  UserSavedVoteModel() {
    _readAllSavedVotes();
  }

  void _readAllSavedVotes() async {
    _savedVotes.addAll(await VoteSavingService().getAllVotes());
    notifyListeners();
  }

  UserSavedVote findVoteById(int id) {
    if (_savedVotes.where((e) => e.id == id).isNotEmpty) {
      return _savedVotes.firstWhere((e) => e.id == id);
    }

    return UserSavedVote(id: id, liked: false, disliked: false);
  }

  void changeVote(UserSavedVote savedVote) {
    if (_savedVotes.where((e) => e.id == savedVote.id).isNotEmpty) {
      _savedVotes.remove(_savedVotes.firstWhere((e) => e.id == savedVote.id));
    }
    _savedVotes.add(savedVote);
    notifyListeners();
  }

  void removeAll() {
    _savedVotes.clear();
    notifyListeners();
  }
}
