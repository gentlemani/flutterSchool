import 'package:eatsily/constants/constants.dart';
import 'package:eatsily/widgets/home/recipe_steps_widget.dart';
import 'package:eatsily/widgets/home/vote_section_widget.dart';
import 'package:eatsily/widgets/home/diners_counter_widget.dart';
import 'package:eatsily/widgets/home/ingredients_list_widget.dart';
import 'package:eatsily/services/database_service.dart';
import 'package:eatsily/utils/recipe_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecipesHome extends StatefulWidget {
  final String recetaId;
  const RecipesHome({Key? key, required this.recetaId}) : super(key: key);

  @override
  State<RecipesHome> createState() => _RecipesHomeState();
}

class _RecipesHomeState extends State<RecipesHome> {
  String? _recipeImageUrl;
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
        recipeImageUrl = data['image'];
        recipeSteps = parseRecipeSteps(data['description'] ?? '');
        selectedIngredients = formatIngredients(data['ingredients'], data['portions']);
        counterDiners = data['diner'] ?? 1;
      });
    } else {
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
            title: Text(name, style: headingTextStyle),
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: _recipeImageUrl != null
                  ? Image.network(_recipeImageUrl!, fit: BoxFit.cover)
                  : const Center(child: Text('Sin imagen', style: TextStyle(color: Colors.white))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: selectedCategory == "Ingredientes" ? buildIngredients() : buildSteps(),
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

  Widget buildIngredients() {
    return Column(
      children: [
        DinersCounter(),
        IngredientsList(),
      ],
    );
  }

  Widget buildSteps() {
    return RecipeSteps(steps: recipeSteps,);
  }

}
