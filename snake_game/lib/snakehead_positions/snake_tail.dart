import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:snake_game/home_page.dart';

class SnakeTail extends StatefulWidget {
  SnakeTail({super.key, SnakeDirection? dir});

  @override
  State<SnakeTail> createState() => _SnakeTailState();
}

class _SnakeTailState extends State<SnakeTail> {
  SnakeDirection? dir;

  @override
  Widget build(BuildContext context) {
    switch (dir) {
      case SnakeDirection.left:
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12)),
            child: Image.asset("left.png"),
          ),
        );
      case SnakeDirection.right:
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12)),
            child: Image.asset("right.png"),
          ),
        );
      case SnakeDirection.up:
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12)),
            child: Image.asset("up.png"),
          ),
        );
      case SnakeDirection.down:
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12)),
            child: Image.asset("down.png"),
          ),
        );
      default:
        return (Container());
    }
  }
}
