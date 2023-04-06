import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SnakeUp extends StatelessWidget {
  const SnakeUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
              child: Image.asset("snake_head/up.png"),
        ));
  }
}