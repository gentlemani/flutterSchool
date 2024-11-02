import 'package:flutter/material.dart';

class IngredientsList extends StatelessWidget {
  final List<Map<String, dynamic>> ingredients = [];

  IngredientsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return ListTile(
          title: Text(ingredient['name']),
          subtitle: Text("${ingredient['quantity']} ${ingredient['unit']}"),
        );
      },
    );
  }
}
