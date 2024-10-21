// widgets/food_information.dart
import 'package:eatsily/services/recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Widget foodInformation(String recetaId, String userId) {
  return StreamBuilder<DocumentSnapshot>(
    stream: RecipeService().getRecipeStream(recetaId),
    builder: (context, recipeSnapshot) {
      if (recipeSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (recipeSnapshot.hasError) {
        return Center(child: Text('Error: ${recipeSnapshot.error}'));
      } else if (!recipeSnapshot.hasData || !recipeSnapshot.data!.exists) {
        return const Center(child: Text('Receta no encontrada'));
      } else {
        final recipeData =
            recipeSnapshot.data!.data() as Map<String, dynamic>?;

        // Muestra los datos de la receta aquí...
        return Column(
          children: [
            Text(recipeData?['name'] ?? 'Nombre no disponible'),
            // Otras informaciones...
          ],
        );
      }
    },
  );
}
