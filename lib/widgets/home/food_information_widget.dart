import 'package:eatsily/services/recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsily/widgets/home/recipe_details_widget.dart';

class FoodInformation extends StatelessWidget {
  final String recipeId;
  final String userId;

  const FoodInformation({super.key, required this.recipeId, required this.userId});
  

  @override
  Widget build(BuildContext context) {
    final RecipeService recipeService = RecipeService();
    return StreamBuilder<DocumentSnapshot>(
      stream: recipeService.getRecipeStream(recipeId),
      builder: (context, recipeSnapshot) {
        if (recipeSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (recipeSnapshot.hasError) {
          return Center(child: Text('Error: ${recipeSnapshot.error}'));
        } else if (!recipeSnapshot.hasData || !recipeSnapshot.data!.exists) {
          return const Center(child: Text('Receta no encontrada'));
        } else {
          final recipeData = recipeSnapshot.data!.data() as Map<String, dynamic>?;
          if (recipeData == null) {
            return const Center(child: Text('Datos de la receta no disponibles'));
          }

          return RecipeDetails(recipeData: recipeData, recipeId: recipeId, userId: userId);
        }
      },
    );
  }
}
