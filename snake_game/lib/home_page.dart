import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/blank_pixel.dart';
import 'package:snake_game/highscore_tile.dart';
import 'package:snake_game/snake_pixel.dart';

import 'food_pixel.dart';

enum SnakeDirection { up, down, left, right }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var screenHeight = window.physicalSize.height / window.devicePixelRatio;
  var screenWidth = window.physicalSize.width / window.devicePixelRatio;
  int rowSize = 10;
  int totalNumberOfSquares = 100;
  bool gameHasStarted = false;

  final _nameController = TextEditingController();
  //user score
  int currentScore = 0;
  //snake position
  List<int> snakePos = [
    46,
    47,
    48,
  ];

  var currentDirection = SnakeDirection.right;

  int foodPos = 55;

  //highscore list

  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep the snake moving
        moveSnake();

        //check if the game is over
        if (gameOver()) {
          timer.cancel();
          //display a message to the user
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Game Over"),
                  insetPadding: MediaQuery.of(context).size.width > 428
                      ? const EdgeInsets.symmetric(vertical: 200)
                      : const EdgeInsets.symmetric(vertical: 100),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("Your score is:" + currentScore.toString()),
                          TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                  hintText: 'Enter Your Name')),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                              newGame();
                            },
                            child: const Text("Close"),
                            color: Colors.pink,
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                              submitScore();
                              newGame();
                            },
                            child: const Text("Submit"),
                            color: Colors.pink,
                          ),
                        ],
                      )
                    ],
                  ),
                  actions: [],
                );
              });
        }
      });
    });
  }

  void submitScore() {
    var database = FirebaseFirestore.instance;
    print(_nameController.text);
    print(currentScore);
    database
        .collection('highscores')
        .add({"name": _nameController.text, "score": currentScore});
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos = 55;
      currentDirection = SnakeDirection.right;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  void eatFood() {
    currentScore++;
    //HOW DOES THIS FUNCTION GET RANDOM NUMBERS EXCLUDING NUMBERS IN THE snakePos LIST
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case SnakeDirection.right:
        {
          //if snake is at the right wall, need to re-adjust
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;
      case SnakeDirection.left:
        {
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case SnakeDirection.up:
        {
          if (snakePos.last < rowSize)
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case SnakeDirection.down:
        {
          if (snakePos.last >= totalNumberOfSquares - rowSize) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      snakePos.removeAt(0);
    }
  }

  bool gameOver() {
    //duplicate checking for body collision
    //this list is the body of the snake (no head)
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);

    if (bodySnake.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
              currentDirection != SnakeDirection.up) {
            currentDirection = SnakeDirection.down;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
              currentDirection != SnakeDirection.down) {
            currentDirection = SnakeDirection.up;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
              currentDirection != SnakeDirection.right) {
            currentDirection = SnakeDirection.left;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
              currentDirection != SnakeDirection.left) {
            currentDirection = SnakeDirection.right;
          }
        },
        child: Center(
          child: SizedBox(
            width: screenWidth > 428 ? 428 : screenWidth,
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //user current score
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Current Score"),
                              Text(
                                currentScore.toString(),
                                style: const TextStyle(fontSize: 36),
                              ),
                            ],
                          ),
                        ),
                        //highscores top 5
                        Expanded(
                          child: gameHasStarted
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                  child: Column(
                                    children: [
                                      Row(children: [
                                        Text('Score'),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Name'),
                                      ]),
                                      FutureBuilder(
                                          future: letsGetDocIds,
                                          builder: (context, snapshot) {
                                            return Center(
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    highscore_DocIds.length,
                                                itemBuilder: ((context, index) {
                                                  return HighScoreTile(
                                                      documentId:
                                                          highscore_DocIds[
                                                              index]);
                                                }),
                                              ),
                                            );
                                          }),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    )),
                Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        if (details.delta.dy > 0 &&
                            currentDirection != SnakeDirection.up) {
                          currentDirection = SnakeDirection.down;
                        } else if (details.delta.dy < 0 &&
                            currentDirection != SnakeDirection.down) {
                          currentDirection = SnakeDirection.up;
                        }
                      },
                      onHorizontalDragUpdate: (details) {
                        if (details.delta.dx > 0 &&
                            currentDirection != SnakeDirection.left) {
                          currentDirection = SnakeDirection.right;
                        } else if (details.delta.dx < 0 &&
                            currentDirection != SnakeDirection.right) {
                          currentDirection = SnakeDirection.left;
                        }
                      },
                      child: GridView.builder(
                          itemCount: totalNumberOfSquares,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: rowSize),
                          itemBuilder: (context, index) {
                            if (snakePos.last == index &&
                                currentDirection == SnakeDirection.up) {
                              return const SnakeHeadUp();
                            } else if (snakePos.last == index &&
                                currentDirection == SnakeDirection.down) {
                              return const SnakeHeadDown();
                            } else if (snakePos.last == index &&
                                currentDirection == SnakeDirection.left) {
                              return const SnakeHeadLeft();
                            } else if (snakePos.last == index &&
                                currentDirection == SnakeDirection.right) {
                              return const SnakeHeadRight();
                            } else if (snakePos[0] == index &&
                                snakePos[1] == snakePos[0] + 10) {
                              return const SnakeTailUp();
                            } else if (snakePos[0] == index &&
                                snakePos[1] == snakePos[0] - 10) {
                              return const SnakeTailDown();
                            } else if (snakePos[0] == index &&
                                snakePos[1] > snakePos[0]) {
                              return const SnakeTailLeft();
                            } else if (snakePos[0] == index &&
                                snakePos[1] < snakePos[0]) {
                              return const SnakeTailRight();
                            } else if (snakePos.contains(index)) {
                              return const SnakePixel();
                            } else if (foodPos == index) {
                              return const FoodPixel();
                            } else if (foodPos != index ||
                                !snakePos.contains(index)) {
                              return const BlankPixel();
                            }
                          }),
                    )),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Center(
                        child: MaterialButton(
                      child: const Text("PLAY"),
                      textColor: Colors.white,
                      color: gameHasStarted ? Colors.grey : Colors.pink,
                      onPressed: gameHasStarted ? () {} : startGame,
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SnakeHeadRight extends StatelessWidget {
  const SnakeHeadRight({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
        child: const Image(image: AssetImage("assets/images/right.png")),
      ),
    );
  }
}

class SnakeHeadUp extends StatelessWidget {
  const SnakeHeadUp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
        child: const Image(image: AssetImage("assets/images/up.png")),
      ),
    );
  }
}

class SnakeHeadLeft extends StatelessWidget {
  const SnakeHeadLeft({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
        child: const Image(image: AssetImage("assets/images/left.png")),
      ),
    );
  }
}

class SnakeHeadDown extends StatelessWidget {
  const SnakeHeadDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
        child: const Image(image: AssetImage("assets/images/down.png")),
      ),
    );
  }
}

class SnakeTailDown extends StatelessWidget {
  const SnakeTailDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
        child: const Image(image: AssetImage("assets/images/down.png")),
      ),
    );
  }
}

class SnakeTailLeft extends StatelessWidget {
  const SnakeTailLeft({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
        child: const Image(image: AssetImage("assets/images/left.png")),
      ),
    );
  }
}

class SnakeTailRight extends StatelessWidget {
  const SnakeTailRight({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
        child: const Image(image: AssetImage("assets/images/right.png")),
      ),
    );
  }
}

class SnakeTailUp extends StatelessWidget {
  const SnakeTailUp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
        child: const Image(image: AssetImage("assets/images/up.png")),
      ),
    );
  }
}
