import 'package:app/constants.dart';
import 'package:app/models/group.dart';
import 'package:flutter/material.dart';

class BoardState extends ChangeNotifier {
  List<String> words =
      day.map((group) => group.items).expand((element) => element).toList();

  List<String> selectedWords = [];
  List<Group> groups = List.empty(growable: true);

  void shuffle() {
    words.shuffle();
    notifyListeners();
  }

  void selectWord(String key) {
    var word = key;

    if (selectedWords.contains(word)) {
      selectedWords.remove(word);
    } else {
      if (selectedWords.length != 4) {
        selectedWords.add(word);
      }
    }
    notifyListeners();
  }

  void addToGroup(Group group) {
    groups.add(group);
    notifyListeners();
  }

  void displayAnswers() {
    for (var i = 0; i < day.length; i++) {
      var item = day[i];
      if (!groups.any((element) => element.name == item.name)) {
        groups.add(item);
      }
    }
    words.clear();
    notifyListeners();
  }

  void resetUnselectedWords() {
    for (var i = 0; i < selectedWords.length; i++) {
      words.remove(selectedWords[i]);
    }
    selectedWords.clear();
    notifyListeners();
  }

  void resetBoard() {
    selectedWords.clear();
    notifyListeners();
  }
}
