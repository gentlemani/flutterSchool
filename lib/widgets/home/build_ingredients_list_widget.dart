// import 'package:flutter/material.dart';

// class IngredientsList extends StatefulWidget {
//   List<Map<String, dynamic>> ingredients;

//   IngredientsList({super.key, required this.ingredients});

//   @override
//   State<IngredientsList> createState() => _IngredientsListState();
// }

// class _IngredientsListState extends State<IngredientsList> {
//   @override
//   Widget build(BuildContext context) {
//     print('Hola');
//     print(widget.ingredients);
//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: widget.ingredients.length,
//       itemBuilder: (context, index) {
//         final ingredient = widget.ingredients[index];
//         // print(ingredient);
//         return ListTile(
//           title: Text(ingredient['name']),
//           subtitle: Text("${ingredient['quantity']} ${ingredient['unit']}"),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:eatsily/widgets/home/ingredient_item_widget.dart';

class BuildIngredientsList extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients;
  const BuildIngredientsList({super.key, required this.ingredients});

  @override
  State<BuildIngredientsList> createState() => _BuildIngredientsListState();
}

class _BuildIngredientsListState extends State<BuildIngredientsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Avoid independent scroll
      itemCount: widget.ingredients.length, // Access ingredients via widget.ingredients
      itemBuilder: (context, index) {
        final ingredient = widget.ingredients[index];
        return IngredientItem(ingredient: ingredient);
      },
    );
  }
}
