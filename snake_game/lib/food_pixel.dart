import 'package:flutter/material.dart';

class FoodPixel extends StatelessWidget {
  const FoodPixel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          child: Image.asset(
            "food.png",
            height: 3,
            width: 3,
          ),
          decoration: BoxDecoration(
              color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
        ));
  }
}
