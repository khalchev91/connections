import 'package:app/constants.dart';
import 'package:app/models/group.dart';
import 'package:app/models/validation.dart';
import 'package:flutter/material.dart';

class Validate {
  static ValidationResponse checkWords(List<String> selectedWords) {
    var groups = day;
    Group group = Group('', [], 0, Colors.white);
    ValidationResponse response = ValidationResponse();

    for (var i = 0; i < groups.length; i++) {
      var groupWords = groups[i].items;

      var correctWords = 0;
      for (var j = 0; j < selectedWords.length; j++) {
        if (groupWords.contains(selectedWords[j])) {
          correctWords++;
        }
      }

      if (correctWords == 3) {
        group = Group(groups[i].name, groups[i].items, groups[i].difficulty,
            groups[i].color);
        response.group = group;
        response.validationMessage = 'Almost there! You need one more word.';
        return response;
      }

      if (correctWords == 4) {
        group = Group(groups[i].name, groups[i].items, groups[i].difficulty,
            groups[i].color);
        response.group = group;
        response.validationMessage = 'Woohoo!';

        return response;
      }
    }

    return response;
  }
}
