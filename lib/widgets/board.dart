import 'package:app/models/group.dart';
import 'package:app/services/validate_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../states/board_state.dart';

class BoardWidget extends StatefulWidget {
  const BoardWidget(Key? key, this._rowLength) : super(key: key);

  final int _rowLength;

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  late int chancesCount;

  @override
  void initState() {
    super.initState();
    chancesCount = 4;
  }

  Widget _buildChances(BuildContext context, int chances) {
    var size = MediaQuery.of(context).size;
    final gridWidth = size.width;
    if (!gameCompleted(context)) {
      return SizedBox(
        width: gridWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(chances, (index) {
            return Icon(
              Icons.circle,
              color: Colors.grey[300],
            );
          }),
        ),
      );
    } else {
      return Container();
    }
  }

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
              crossAxisCount: widget._rowLength,
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

  @override
  Widget build(BuildContext context) {
    var boardState = context.watch<BoardState>();

    var words = boardState.words;
    var groups = boardState.groups;

    Widget gridWidget = _buildGrid(words, context, groups);

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
          _buildChances(context, chancesCount),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: !gameCompleted(context)
                    ? () {
                        boardState.shuffle();
                      }
                    : null,
                child: const Text('Shuffle'),
              ),
              ElevatedButton(
                onPressed: anySelected(context) && !gameCompleted(context)
                    ? () {
                        var boardState = context.read<BoardState>();
                        boardState.resetBoard();
                      }
                    : null,
                child: const Text('Deselect All'),
              ),
              ElevatedButton(
                onPressed: enableSubmit(context) && !gameCompleted(context)
                    ? () {
                        var validateMessage =
                            Validate.checkWords(boardState.selectedWords);

                        if (validateMessage.validationMessage == 'Woohoo!') {
                          boardState.addToGroup(validateMessage.group);
                          boardState.resetUnselectedWords();
                        } else {
                          Fluttertoast.showToast(
                            msg: validateMessage.validationMessage,
                            toastLength: Toast.LENGTH_SHORT,
                            fontSize: 16.0,
                          );
                          if (chancesCount > 1) {
                            setState(() {
                              chancesCount--;
                            });
                          } else {
                            setState(() {
                              chancesCount = 0;
                            });
                            boardState.displayAnswers();
                          }
                        }
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

  bool gameCompleted(BuildContext context) {
    var boardState = context.read<BoardState>();
    return boardState.groups.length == 4 || chancesCount == 0;
  }
}
