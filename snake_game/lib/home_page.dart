import 'dart:async';

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

  //snake position
  List<int> snakePos = [
    0,
    1,
    2,
  ];

  var currentDirection = SnakeDirection.right;

  int foodPos = 55;

  void startGame() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        moveSnake();
      });
    });
  }

  void moveSnake() {
    switch (currentDirection) {
      case SnakeDirection.right:
        {
          snakePos.add(snakePos.last + 1);
          snakePos.removeAt(0);
        }
        break;
      case SnakeDirection.left:
        {
          snakePos.add(snakePos.last - 1);
          snakePos.removeAt(0);
        }
        break;
      case SnakeDirection.up:
        {
          snakePos.add(snakePos.last - rowSize);
          snakePos.removeAt(0);
        }
        break;
      case SnakeDirection.down:
        {
          snakePos.add(snakePos.last + rowSize);
          snakePos.removeAt(0);
        }
        break;
      default:
    }
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
                  if (details.delta.dy > 0) {
                    currentDirection = SnakeDirection.down;
                  } else if (details.delta.dy < 0) {
                    currentDirection = SnakeDirection.up;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0) {
                    currentDirection = SnakeDirection.right;
                  } else if (details.delta.dx < 0) {
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
