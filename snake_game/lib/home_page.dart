import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:snake_game/blank_pixel.dart';
import 'package:snake_game/snake_pixel.dart';

import 'food_pixel.dart';

enum SnakeDirection { up, down, left, right }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int rowSize = 10;
  int totalNumberOfSquares = 100;

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

  void startGame() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep the snake moving
        moveSnake();

        //check if the game is over
        if (gameOver()) {
          timer.cancel();
          //display a message to the user
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(title: Text("Game Over"),content: Text("Your score is:" + currentScore.toString()),);
              }); 
        }
      });
    });
  }

  void eatFood() {
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
      body: Column(
        children: [
          Expanded(child: Container()),
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowSize),
                    itemBuilder: (context, index) {
                      if (snakePos.contains(index)) {
                        return const SnakePixel();
                      } else if (foodPos == index) {
                        return const FoodPixel();
                      } else {
                        return const BlankPixel();
                      }
                    }),
              )),
          Expanded(
            child: Container(
              child: Center(
                  child: MaterialButton(
                child: Text("PLAY"),
                textColor: Colors.white,
                color: Colors.pink,
                onPressed: startGame,
              )),
            ),
          ),
        ],
      ),
    );
  }
}
