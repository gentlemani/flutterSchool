import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsily/constants/constants.dart';
import 'package:eatsily/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecipesHome extends StatefulWidget {
  final String recetaId;
  const RecipesHome({super.key, required this.recetaId});

  @override
  State<RecipesHome> createState() => _RecipesHomeState();
}

class _RecipesHomeState extends State<RecipesHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final DatabaseService _firestoreService;
  final user = FirebaseAuth.instance.currentUser;

  String name = "";
  String? _recipeImageUrl;
  List<String> _filteredIngredients = [];
  List<Map<String, dynamic>> selectedIngredients = [];
  List<String> recipeSteps = [];
  int counterDiners = 0;
  int originalDiners = 1;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _firestoreService = DatabaseService();
    }
    _fetchRecipeData();
  }

  Future<void> _fetchRecipeData() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Recetas').doc(widget.recetaId).get();
      if (doc.exists) {
        // Parse the recipe data here...
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener los datos de la receta')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('Recetas').doc(widget.recetaId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Error: ${snapshot.error ?? 'Receta no encontrada'}'));
          }
          final recipeData = snapshot.data!.data() as Map<String, dynamic>;
          // Extract data and build the UI
          return CustomScrollView(
            slivers: [
              RecipeAppBar(recipeImageUrl: _recipeImageUrl, recipeName: name),
              SliverToBoxAdapter(child: IngredientsSection(selectedIngredients: selectedIngredients, counterDiners: counterDiners)),
              SliverToBoxAdapter(child: StepsSection(recipeSteps: recipeSteps)),
              SliverToBoxAdapter(child: VotingSection(recetaId: widget.recetaId, userId: user!.uid)),
            ],
          );
        },
      ),
    );
  }
}

class RecipeAppBar extends StatelessWidget {
  final String? recipeImageUrl;
  final String recipeName;

  const RecipeAppBar({Key? key, required this.recipeImageUrl, required this.recipeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      flexibleSpace: FlexibleSpaceBar(
        background: recipeImageUrl != null
            ? Image.network(recipeImageUrl!, fit: BoxFit.cover)
            : Container(color: Colors.grey, child: const Center(child: Text('Sin imagen', style: TextStyle(color: Colors.white)))),
        centerTitle: true,
      ),
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(recipeName, style: headingTextStyle),
    );
  }
}

class IngredientsSection extends StatelessWidget {
  final List<Map<String, dynamic>> selectedIngredients;
  final int counterDiners;

  const IngredientsSection({Key? key, required this.selectedIngredients, required this.counterDiners}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add your diners UI here
        ListView.builder(
          shrinkWrap: true,
          itemCount: selectedIngredients.length,
          itemBuilder: (context, index) {
            final ingredient = selectedIngredients[index];
            return ListTile(
              title: Text(ingredient['name']),
              trailing: Text("${ingredient['quantity']} ${ingredient['unit']}"),
            );
          },
        ),
      ],
    );
  }
}

class StepsSection extends StatelessWidget {
  final List<String> recipeSteps;

  const StepsSection({Key? key, required this.recipeSteps}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: recipeSteps.map((step) {
        return ListTile(title: Text(step));
      }).toList(),
    );
  }
}

class VotingSection extends StatelessWidget {
  final String recetaId;
  final String userId;

  const VotingSection({Key? key, required this.recetaId, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Build voting UI here
      ],
    );
  }
}
