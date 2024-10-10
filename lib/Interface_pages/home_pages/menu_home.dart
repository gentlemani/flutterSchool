import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsily/Interface_pages/home_pages/menu_home_page/all_recipes.dart';
import 'package:eatsily/Interface_pages/home_pages/recipes_page/recipes.dart';
import 'package:eatsily/services/api_service.dart';
import 'package:eatsily/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/sesion/services/database.dart';

const double kPaddingValue = 18.0;
const double kImageWidth = 400.0;
const double kTextFontSize = 25.0;
const double kImageHeight = 180.0;
const double kBorderWidth = 3.0;
const double kBorderRadius = 12.0;
const Color kBackgroundColor = Color.fromARGB(255, 255, 255, 255);
const Color kBorderColor = Color.fromARGB(255, 0, 0, 0);
const Color kShadowColor = Color.fromARGB(255, 54, 50, 50);

class MenuHome extends StatefulWidget {
  const MenuHome({super.key});

  @override
  State<MenuHome> createState() => _MenuHomeState();
}

class _MenuHomeState extends State<MenuHome> {
  late final DatabaseService _firestoreService;
  final ApiService _apiService = ApiService();

  final Map<String, List<Map<String, dynamic>>> _filteredRecipesByCategory = {
    'created_at': [],
    'Recetas Simples': []
  };
  Future<void> _fetchRecentRecommendedRecipes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtain recent recipes created in the last 5 days
        QuerySnapshot recentRecipesSnapshot = await FirebaseFirestore.instance
            .collection('Recetas')
            .where('created_at',
                isGreaterThan: DateTime.now().subtract(const Duration(days: 5)))
            .get();

        List<Map<String, dynamic>> recentRecipes =
            recentRecipesSnapshot.docs.map((doc) {
          return {
            'recetaId': doc.id,
            ...doc.data() as Map<String, dynamic>,
          };
        }).toList();
        String? token = await AuthService().getUserToken();
        if (token != null) {
          List<dynamic> result = await _apiService.getRecommendations(token);
          if (result.isEmpty) {
            return;
          }
          // Filter the recipes recommended by recent recipes
          List<Map<String, dynamic>> recentRecommendedRecipes =
              recentRecipes.where((recipe) {
            return result
                .any((recommended) => recommended['id'] == recipe['recetaId']);
          }).toList();
          if (recentRecommendedRecipes.isEmpty) {
            return;
          }

          if (mounted) {
            setState(() {
              _filteredRecipesByCategory['created_at'] =
                  recentRecommendedRecipes; // Update recipes in the state
            });
          }
        }
      }
    } catch (e) {
      throw ('Error al obtener las recetas recomendadas: $e');
    }
  }

  Future<void> _fetchRecommendedSimpleRecipes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? token = await AuthService().getUserToken();
        if (token != null) {
          List<dynamic> result = await _apiService.getRecommendations(token);

          if (result.isEmpty) {
            return;
          }

          QuerySnapshot snapshot =
              await FirebaseFirestore.instance.collection('Recetas').get();

          List<Map<String, dynamic>> simpleRecommendedRecipes = [];

          for (var doc in snapshot.docs) {
            Map<String, dynamic> recipeData =
                doc.data() as Map<String, dynamic>;

            List<String> ingredients =
                List<String>.from(recipeData['ingredients'] ?? []);

            // Verify if the recipe is simple (5 or less ingredients) and if recommended
            if (ingredients.length <= 5 &&
                result.any((recommended) => recommended['id'] == doc.id)) {
              simpleRecommendedRecipes.add({
                ...recipeData,
                'recetaId': doc.id, // Includes the Document ID in the data
                'puntuation': result.firstWhere(
                  (recommended) => recommended['id'] == doc.id,
                  orElse: () => {'puntuation': 0},
                )['puntuation'],
              });
            }
          }

          if (mounted) {
            setState(() {
              _filteredRecipesByCategory['Recetas Simples'] =
                  simpleRecommendedRecipes; // Update the State
            });
          }
        }
      }
    } catch (e) {
      throw ('Error al obtener las recetas recomendadas simples: $e');
    }
  }

  BoxDecoration boxDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: kBorderColor, // Border color
        width: kBorderWidth, // Border width
      ),
      borderRadius: BorderRadius.circular(kBorderRadius), // Rounded corners
      boxShadow: [
        BoxShadow(
          color: kShadowColor.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3), // Shadow position
        ),
      ],
    );
  }

  Widget _buildRecetasCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: const Color.fromARGB(255, 230, 118, 84),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget foodInformationD(String recetaId, String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestoreService.getRecipeStream(recetaId),
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
          if (recipeData == null) {
            return const Center(
                child: Text('Datos de la receta no disponibles'));
          }

          final String name =
              recipeData['name'] as String? ?? 'Nombre no disponible';
          final String imagePath = recipeData['image'] as String? ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipesHome(
                          recetaId: recetaId,
                        ),
                      ),
                    );
                  },
                  child:
                      // Image load
                      FutureBuilder<String>(
                    future: _firestoreService.getImageUrl(imagePath),
                    builder: (context, imageSnapshot) {
                      if (imageSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (imageSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${imageSnapshot.error}'));
                      } else if (!imageSnapshot.hasData ||
                          imageSnapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('Imagen no disponible'));
                      } else {
                        final imageUrl = imageSnapshot.data!;
                        return Container(
                          width: MediaQuery.of(context).size.width *
                              0.9, // 90% of screen width
                          height: MediaQuery.of(context).size.width *
                              0.9 *
                              (kImageHeight / kImageWidth),
                          decoration: boxDecoration(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(kBorderRadius),
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                        );
                      }
                    },
                  )),
              Text(
                name,
                style: const TextStyle(fontSize: 20),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          );
        }
      },
    );
  }

  Widget buildCategoryListView(
      String category, List<Map<String, dynamic>> recipes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: recipes.length,
              itemBuilder: (context, recipeIndex) {
                final String recetaId = recipes[recipeIndex]['recetaId'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: foodInformationD(recetaId, _firestoreService.uid),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestoreService = DatabaseService(uid: user.uid);
      _fetchRecentRecommendedRecipes(); //Load the usual recipes
      _fetchRecommendedSimpleRecipes(); //Load recipes with 5 ingredients or less
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Recetario",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
        elevation: 10,
        automaticallyImplyLeading: false,
        shadowColor: Colors.grey,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: _filteredRecipesByCategory['created_at']!.isEmpty &&
              _filteredRecipesByCategory['Recetas Simples']!.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (_filteredRecipesByCategory['created_at']!.isNotEmpty)
                    buildCategoryListView('Nuevas recetas',
                        _filteredRecipesByCategory['created_at']!),
                  if (_filteredRecipesByCategory['Recetas Simples']!.isNotEmpty)
                    buildCategoryListView('Cocinar con 5 Ingredientes o menos',
                        _filteredRecipesByCategory['Recetas Simples']!),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        children: [
                          _buildRecetasCard(
                            icon: Icons.dining_rounded,
                            title: 'Todas las recetas',
                            color: const Color.fromARGB(255, 0, 0, 0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllRecipes(),
                                ),
                              );
                            },
                          ),
                        ]),
                  )
                ],
              ),
            ),
    );
  }
}
