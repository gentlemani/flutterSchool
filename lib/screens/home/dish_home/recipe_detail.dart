import 'package:eatsily/constants/constants.dart';
import 'package:eatsily/widgets/home/back_button_icon_recipe.dart';
import 'package:eatsily/widgets/home/recipe_steps_widget.dart';
import 'package:eatsily/widgets/home/vote_section_widget.dart';
import 'package:eatsily/widgets/home/diners_counter_widget.dart';
import 'package:eatsily/widgets/home/build_ingredients_list_widget.dart';
import 'package:eatsily/services/database_service.dart';
import 'package:eatsily/utils/recipe_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecipeDetail extends StatefulWidget {
  final String recetaId;
  const RecipeDetail({super.key, required this.recetaId});

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  String name = "";
  int likesCount = 0;
  int dislikesCount = 0;
  String selectedCategory = "Ingredientes";
  final DatabaseService _databaseService = DatabaseService();
  int counterDiners = 1;
  String? recipeImageUrl;
  List<String> recipeSteps = [];
  List<Map<String, dynamic>> selectedIngredients = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipeData();
  }

  Future<void> _fetchRecipeData() async {
    final data = await _databaseService.fetchRecipeData(widget.recetaId);
    if (data != null) {
      setState(() {
        name = data['name'] ?? '';
        recipeImageUrl = data['image'] ?? '';
        recipeSteps = parseRecipeSteps(data['description'] ?? '');
        selectedIngredients =
            formatIngredients(data['ingredients'], data['portions']);
        counterDiners = data['diner'] ?? 1;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching recipe data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: BackButtonIconRecipe(onPressed: () => Navigator.pop(context),),
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: recipeImageUrl != null
                  ? Image.network(recipeImageUrl!, fit: BoxFit.cover)
                  : const Center(
                      child: Text('Sin imagen',
                          style: TextStyle(color: Colors.white))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildSubMenu(selectedCategory),
            ),
          ),
          SliverToBoxAdapter(
            child: VoteSection(
              recipeId: widget.recetaId,
              userId: FirebaseAuth.instance.currentUser!.uid,
              likesCount: likesCount,
              dislikesCount: dislikesCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSubMenu(String category) {
    return Column(
      children: [
        Text(name, style: headingTextStyle),
        subMenu(),
        if ("Ingredientes" == category) ...{
          DinersCounter(),
          BuildIngredientsList(
            ingredients: selectedIngredients,
          ),
        } else if (category == "Pasos") ...{
          RecipeSteps(
            steps: recipeSteps,
          ),
        }
      ],
    );
  }

  Widget subMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedCategory = "Ingredientes";
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCategory == "Ingredientes"
                    ? Colors.blue
                    : Colors.grey,
              ),
              child: Text("Ingredientes", style: buttomTextStyle),
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedCategory = "Pasos";
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedCategory == "Pasos" ? Colors.blue : Colors.grey,
              ),
              child: Text("Pasos", style: buttomTextStyle),
            ),
          ),
        ],
      ),
    );
  }
}
