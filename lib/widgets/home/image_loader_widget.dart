import 'package:eatsily/services/recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/utils/box_decoration.dart';
import 'package:eatsily/constants/constants.dart';
import 'package:eatsily/screens/home/dish_home/recipes_home.dart';

class ImageLoader extends StatelessWidget {
  final String imagePath;
  final String recipeId;

  const ImageLoader({super.key, required this.imagePath, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final RecipeService recipeService = RecipeService();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipesHome(recetaId: recipeId),
          ),
        );
      },
      child: FutureBuilder<String>(
        future: recipeService.getImageUrl(imagePath),
        builder: (context, imageSnapshot) {
          if (imageSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (imageSnapshot.hasError) {
            return Center(child: Text('Error: ${imageSnapshot.error}'));
          } else if (!imageSnapshot.hasData || imageSnapshot.data!.isEmpty) {
            return const Center(child: Text('Imagen no disponible'));
          } else {
            final imageUrl = imageSnapshot.data!;
            return Container(
              width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
              height: MediaQuery.of(context).size.width * 0.9 * (kImageHeight / kImageWidth),
              decoration: boxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kBorderRadius),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            );
          }
        },
      ),
    );
  }
}