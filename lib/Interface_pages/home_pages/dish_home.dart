import 'package:eatsily/Interface_pages/home_pages/recipes_page/recipes.dart';
import 'package:eatsily/services/api_service.dart';
import 'package:eatsily/services/auth_service.dart';
import 'package:eatsily/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/sesion/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eatsily/utils/auth.helpers.dart';

//Constant
const double kPaddingValue = 18.0;
const double kImageWidth = 400.0;
const double kTextFontSize = 25.0;
const double kImageHeight = 180.0;
const double kBorderWidth = 3.0;
const double kBorderRadius = 12.0;
const Color kBackgroundColor = Color.fromARGB(255, 255, 255, 255);
const Color kBorderColor = Color.fromARGB(255, 0, 0, 0);
const Color kShadowColor = Color.fromARGB(255, 54, 50, 50);

class DishHome extends StatefulWidget {
  const DishHome({super.key});

  @override
  State<DishHome> createState() => _DishHomeState();
}

class _DishHomeState extends State<DishHome> {
/*     |-----------------|
       |    Variables    |
       |-----------------|
*/
  late final DatabaseService _firestoreService;
  List<Map<String, dynamic>> _recipes = [];
  final user = FirebaseAuth.instance.currentUser;
  final ApiService _apiService = ApiService();
  List<dynamic> recommendations = [];
/*     |----------------|
       |    Functions   |
       |----------------|
*/

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _firestoreService = DatabaseService(uid: user!.uid);
      //_fetchRecipes(); // Only if it is authenticated the recipes are charged
      _fetchRecommendations();
    } else {
      handleLogout(context, redirectTo: const WidgetTree());
      // Redirect the user to the login screen
    }
  }

  Future<void> _fetchRecommendations() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Obtén los IDs de las recetas que el usuario ha marcado como 'Dislike'
        List<String> dislikedRecipeIds =
            await _firestoreService.getDislikedRecipeIds(user.uid);

        String? token = await AuthService().getUserToken();
        if (token != null) {
          List<dynamic> result = await _apiService.getRecommendations(token);

          // Verifica el resultado obtenido
          print('Resultado de la API: $result');
          if (result.isEmpty) {
            print('No se encontraron recomendaciones.');
            return; // No continuar si no hay resultados
          }

          // Convertimos result en una lista de mapas
          List<Map<String, dynamic>> recommendedRecipesFromApi =
              List<Map<String, dynamic>>.from(result.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'puntuation': item['puntuation'],
            };
          }));

          // Extraemos los IDs de las recetas recomendadas
          List<String> recommendedRecipeIds =
              recommendedRecipesFromApi.map((recipe) {
            return recipe['id'] as String;
          }).toList();

          // Filtra las recetas recomendadas para excluir las que el usuario ha marcado con 'Dislike'
          List<String> filteredRecipeIds = recommendedRecipeIds
              .where((id) => !dislikedRecipeIds.contains(id))
              .toList();

          // Verifica si hay recetas recomendadas filtradas
          if (filteredRecipeIds.isEmpty) {
            print('No hay recetas recomendadas después del filtrado.');
            return;
          }

          print('IDs filtrados: $filteredRecipeIds');

          // Obtener las recetas completas desde Firestore en un solo query
          List<Map<String, dynamic>> recommendedRecipes =
              await _firestoreService.getRecipesByIds(filteredRecipeIds);

          // Verifica el resultado de Firestore
          print('Recetas obtenidas de Firestore: $recommendedRecipes');

          for (var recipe in recommendedRecipes) {
            var matchedRecipe = recommendedRecipesFromApi.firstWhere(
              (item) => item['id'] == recipe['id'],
              orElse: () => {'id': recipe['id'], 'puntuation': 0},
            );
            recipe['puntuation'] =
                matchedRecipe['puntuation']; // Añade la puntuación a la receta
          }

          // Ordenar las recetas por puntuación (de mayor a menor)
          recommendedRecipes.sort((a, b) {
            final puntuationA = a['puntuation'] ?? 0;
            final puntuationB = b['puntuation'] ?? 0;
            return (puntuationB as int).compareTo(puntuationA as int);
          });

          if (mounted) {
            setState(() {
              _recipes = recommendedRecipes;
            });
          }

          // Muestra las recetas recomendadas en la consola
          for (var recipe in _recipes) {
            print('Receta: ${recipe['name']} - Likes: ${recipe['likes']}');
          }
        }
      }
    } catch (e) {
      print('Error al obtener las recomendaciones: $e');
    }
  }

  Future<void> _fetchRecipes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtain recipe ids that the user has marked as 'Dislike'
      List<String> dislikedRecipeIds =
          await _firestoreService.getDislikedRecipeIds(user.uid);

      // Get recipes
      QuerySnapshot snapshot = await _firestoreService.getRecipes2(30);

      //Filter recipes to exclude what the user has marked as 'Dislike'
      List<Map<String, dynamic>> recipes = snapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['recetaId'] = doc.id; // Add the document ID to the data
            return data;
          })
          .where((recipe) => !dislikedRecipeIds.contains(recipe['recetaId']))
          .toList();
      if (mounted) {
        setState(() {
          _recipes = recipes;
        });
      }
    }
  }

/*     |---------------------|
       |    Decorate image   |
       |---------------------|
*/

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

/*     |----------------|
       |    Widgets     |
       |----------------|
*/

  Widget recommendedDishes() {
    // Get the total high screen
    final screenHeight = MediaQuery.of(context).size.height;
    final itemHeight = screenHeight * 0.4;
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Flexible(
            child: _recipes.isEmpty
                ? const CircularProgressIndicator()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemExtent: itemHeight, // Responsively adjusts height
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final String recetaId = _recipes[index]['recetaId'];
                      return Container(
                        margin: EdgeInsets.symmetric(
                          vertical: constraints.maxHeight * 0.05,
                          horizontal: constraints.maxWidth * 0.05,
                        ),
                        child: foodInformation(recetaId, _firestoreService.uid),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget foodInformation(String recetaId, String userId) {
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
          final int likesCount = recipeData['likes'] as int? ?? 0;
          final int dislikesCount = recipeData['dislikes'] as int? ?? 0;
          final String imagePath = recipeData['image'] as String? ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipesHome(recetaId: recetaId),
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
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildVoteSection(recetaId, userId, likesCount, true),
                  buildVoteSection(recetaId, userId, dislikesCount, false),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget buildVoteSection(
      String recetaId, String userId, int currentVotes, bool isLike) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestoreService.getUserVoteStream(recetaId, userId),
      builder: (context, voteSnapshot) {
        if (voteSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (voteSnapshot.hasError) {
          return Center(child: Text('Error: ${voteSnapshot.error}'));
        } else {
          bool? userVote;
          var voteData = voteSnapshot.data!.data() as Map<String, dynamic>?;
          userVote = voteData?['vote'] as bool?;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$currentVotes', style: const TextStyle(fontSize: 17)),
                  IconButton(
                    iconSize: 25,
                    icon: Icon(
                      isLike
                          ? (userVote == true
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined)
                          : (userVote == false
                              ? Icons.thumb_down_alt
                              : Icons.thumb_down_alt_outlined),
                      color: isLike
                          ? (userVote == true ? Colors.blue : null)
                          : (userVote == false ? Colors.red : null),
                    ),
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await _firestoreService.voteRecipe(
                            recetaId, userId, isLike);
                      } else {
                        handleLogout(context, redirectTo: const WidgetTree());
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }
/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Recomendación a tu gusto",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          automaticallyImplyLeading: false,
          shadowColor: Colors.grey,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        ),
        body: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            return Container(
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.005,
                  horizontal: screenWidth * 0.01),
              child: recommendedDishes(),
            );
          }),
        ),
        backgroundColor: kBackgroundColor);
  }
}
