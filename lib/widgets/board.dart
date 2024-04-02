import 'package:app/constants.dart';
import 'package:app/models/group.dart';
import 'package:app/services/validate_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget(Key? key, this._rowLength) : super(key: key);

  final int _rowLength;

  Widget _buildGrid(
      List<String> words, BuildContext context, List<Group> group) {
    var size = MediaQuery.of(context).size;

    final gridWidth = size.width;
    final gridHeight = size.height * 0.55;

    return Container(
        width: gridWidth,
        height: gridHeight,
        padding: const EdgeInsets.all(1.5),
        child: Column(verticalDirection: VerticalDirection.down, children: [
          GridView.count(
            crossAxisCount: 1,
            shrinkWrap: true,
            childAspectRatio: 4,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(group.length, (index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: group[index].color,
                child: Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          group[index].name,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          group[index].items.join(', '),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                ),
              );
            }),
          ),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _rowLength,
              childAspectRatio: 1,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: words.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                key: Key(words[index]),
                onTap: () => {tapKey(words[index], context)},
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: isSelected(words[index], context)
                      ? Colors.black
                      : Colors.grey[300],
                  child: Center(
                    child: Text(
                      words[index],
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected(words[index], context)
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ]));
  }

  Widget _buildRow(BuildContext context, List<Group> group) {
    var size = MediaQuery.of(context).size;

    final gridWidth = size.width;
    final gridHeight = size.height * 0.1;

    return Container(
        width: gridWidth,
        height: gridHeight,
        padding: const EdgeInsets.all(1.5),
        child: ListView.builder(
          itemCount: group.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: group[index].color,
              child: Center(
                child: Column(children: [
                  Text(
                    group[index].name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    group[index].items.join(', '),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
              ),
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    var boardState = context.watch<BoardState>();

    var words = boardState.words;
    var groups = boardState.groups;

    Widget gridWidget = _buildGrid(words, context, groups);
    // Widget rowWidget = _buildRow(context, groups);

    final today = DateTime.now();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Text(
              'Connections',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(DateFormat('MMMM dd, yyyy').format(today)),
          ],
        ),
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          gridWidget,
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  boardState.shuffle();
                },
                child: const Text('Shuffle'),
              ),
              ElevatedButton(
                onPressed: anySelected(context)
                    ? () {
                        var boardState = context.read<BoardState>();
                        boardState.resetBoard();
                      }
                    : null,
                child: const Text('Deselect All'),
              ),
              ElevatedButton(
                onPressed: enableSubmit(context)
                    ? () {
                        var validateMessage =
                            Validate.checkWords(boardState.selectedWords);

                        if (validateMessage.validationMessage == 'Woohoo!') {
                          boardState.addToGroup(validateMessage.group);
                          boardState.resetUnselectedWords();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(validateMessage.validationMessage),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(validateMessage.validationMessage),
                            ),
                          );
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(validateMessage.validationMessage),
                          ),
                        );
                      }
                    : null,
                child: const Text('Submit'),
              ),
            ],
          ),
        ]),
      ],
    );
  }
}

bool isSelected(String word, BuildContext context) {
  var boardState = context.read<BoardState>();
  return boardState.selectedWords.contains(word);
}

void tapKey(String key, BuildContext context) {
  var boardState = context.read<BoardState>();
  boardState.selectWord(key);
}

bool anySelected(BuildContext context) {
  var boardState = context.read<BoardState>();
  return boardState.selectedWords.isNotEmpty;
}

bool enableSubmit(BuildContext context) {
  var boardState = context.read<BoardState>();
  return boardState.selectedWords.length == 4;
}

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
