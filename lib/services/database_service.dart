import 'user_service.dart';
import 'recipe_service.dart';
import 'package:eatsily/models/recipe_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DatabaseService {
  final UserService userService;
  final RecipeService recipeService;

  DatabaseService({
    required this.userService,
    required this.recipeService,
  });

  // Método para obtener el stream de una receta específica
  Stream<DocumentSnapshot> getRecipeStream(String recetaId) {
    return recipeService.getRecipeStream(recetaId);
  }

  // Obtener recetas por lista de IDs
  Future<List<RecipeModel>> getRecipesByIds(List<String> ids) {
    return recipeService.getRecipesByIds(ids);
  }

  // Obtener la URL de la imagen de una receta
  Future<String> getImageUrl(String imagePath) {
    return recipeService.getImageUrl(imagePath);
  }

  // Votar una receta (Like/Dislike)
  Future<void> voteRecipe(String recetaId, String userId, bool vote) {
    return recipeService.voteRecipe(recetaId, userId, vote);
  }

  // Método para obtener IDs de recetas marcadas como "Dislike" por un usuario
  Future<List<String>> getDislikedRecipeIds() {
    return userService.getDislikedRecipeIds();
  }

}
