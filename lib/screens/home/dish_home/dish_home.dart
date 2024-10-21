import 'package:eatsily/screens/session/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/services/api_service.dart';
import 'package:eatsily/utils/auth.helpers.dart';
import 'package:eatsily/constants/constants.dart';
import 'package:eatsily/widgets/home/recommended_dishes_widget.dart';
import 'package:eatsily/services/database_service.dart';
import 'package:eatsily/services/user_service.dart'; 
import 'package:eatsily/services/recipe_service.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsily/models/recipe_model.dart';

class DishHome extends StatefulWidget {
  const DishHome({super.key});

  @override
  State<DishHome> createState() => _DishHomeState();
}

class _DishHomeState extends State<DishHome> {
  late final DatabaseService _firestoreService;
  List<Map<String, dynamic>> _recipes = [];
  final User? user = FirebaseAuth.instance.currentUser;
  final ApiService _apiService = ApiService();
  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      // Initialize services
      _userService = UserService(
        firebaseAuth: FirebaseAuth.instance,
        db: FirebaseFirestore.instance,
        user: user,
      );
      final recipeService = RecipeService(
        db: FirebaseFirestore.instance,
      );
      _firestoreService = DatabaseService(
        userService: _userService,
        recipeService: recipeService,
      );
      _fetchRecommendations();
    } else {
      handleLogout(context, redirectTo: const WidgetTree());
    }
  }

  Future<void> _fetchRecommendations() async {
    try {
      if (user != null) {
        List<String> dislikedRecipeIds =
            await _firestoreService.userService.getDislikedRecipeIds();
        String? token = await _userService.getUserToken();

        if (token != null) {
          List<dynamic> result = await _apiService.getRecommendations(token);
          if (result.isEmpty) return;

          List<Map<String, dynamic>> recommendedRecipesFromApi =
              List<Map<String, dynamic>>.from(result.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'puntuation': item['puntuation'],
            };
          }));

          List<Map<String, dynamic>> filteredRecipesFromApi =
              recommendedRecipesFromApi.where((recipe) {
            return !dislikedRecipeIds.contains(recipe['id']);
          }).toList();

          if (filteredRecipesFromApi.isEmpty) {
            return;
          }

          List<RecipeModel> recipeModels = await _firestoreService.recipeService.getRecipesByIds(
          filteredRecipesFromApi.map((recipe) => recipe['id'] as String).toList(),
        );
        List<Map<String, dynamic>> recommendedRecipes = recipeModels.map((recipe) => recipe.toMap()).toList();

          for (var recipe in recommendedRecipes) {
            var matchedRecipe = recommendedRecipesFromApi.firstWhere(
              (item) => item['id'] == recipe['id'],
              orElse: () => {'id': recipe['id'], 'puntuation': 0},
            );
            recipe['puntuation'] = matchedRecipe['puntuation'] ?? 0;
          }

          recommendedRecipes.sort((a, b) {
            final puntuationA = a['puntuation']?.toDouble() ?? 0.0;
            final puntuationB = b['puntuation']?.toDouble() ?? 0.0;
            return puntuationB.compareTo(puntuationA);
          });

          if (mounted) {
            setState(() {
              _recipes = recommendedRecipes;
            });
          }
        }
      }
    } catch (e) {
      throw ('Error al obtener las recomendaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Recomendación a tu gusto"),
        backgroundColor: Colors.white,
        elevation: 10,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: Center(
        child: recommendedDishes(_recipes,user!),
      ),
      backgroundColor: kBackgroundColor,
    );
  }
}
