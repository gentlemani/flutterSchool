import 'package:flutter/material.dart';
import 'package:eatsily/constants/constants.dart';

class IngredientItem extends StatelessWidget {
  final Map<String, dynamic> ingredient;

  const IngredientItem({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: ingredientDecoration,
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                ingredient['name'],
                style: ingredientTextStyle,
              ),
            ),
            Text(
              "${ingredient['quantity']} ${ingredient['unit']}",
              style: quantityTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}

