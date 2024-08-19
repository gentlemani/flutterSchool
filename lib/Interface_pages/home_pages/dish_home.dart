import 'package:flutter/material.dart';
import 'package:eatsily/sesion/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eatsily/auth.dart';
import 'package:eatsily/sesion/sign_in_page.dart';

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

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestoreService = DatabaseService(uid: user.uid);
      _fetchRecipes(); // Only if it is authenticated the recipes are charged
    } else {
      _handleLogout(context);
      // Redirect the user to the login screen
    }
  }

  Future<void> signOutFunction() async {
    await Auth().signOut();
  }

  Future<void> _fetchRecipes() async {
    List<Map<String, dynamic>> recipes =
        await _firestoreService.getRecipes(10); // Limit of 10 recipes
    setState(() {
      _recipes = recipes;
    });
  }

  void _handleLogout(BuildContext context) {
    signOutFunction();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const SignInPage(),
      ),
    );
  }
/*     |----------------|
       |    Functions   |
       |----------------|
*/

  Widget beastMeals() {
    return Column(
      children: [
        Flexible(
            child: _recipes.isEmpty
                ? const CircularProgressIndicator()
                : ListWheelScrollView(
                    physics: const FixedExtentScrollPhysics(),
                    itemExtent: 280,
                    diameterRatio: 70,
                    squeeze: 1.1,
                    useMagnifier: false,
                    //magnification: 1.22,
                    children: _recipes.map((recipe) {
                      final String recetaId = recipe['recetaId'];
                      return foodInformation(recetaId, _firestoreService.uid);
                    }).toList(),
                  ))
      ],
    );
  }

  Widget foodInformation(String recetaId, String userId) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageWidth = screenWidth * 0.9; // 60% of screen width
    final double imageHeight =
        imageWidth * (kImageHeight / kImageWidth); // Maintain aspect ratio

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestoreService.getUserVoteStream(recetaId, userId),
      builder: (context, voteSnapshot) {
        if (voteSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (voteSnapshot.hasError) {
          return Center(
            child: Text('Error: ${voteSnapshot.error}'),
          );
        } else {
          bool? userVote;
          if (voteSnapshot.hasData && voteSnapshot.data!.exists) {
            var voteData = voteSnapshot.data!.data() as Map<String, dynamic>?;
            userVote = voteData?['vote'] as bool?;
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: _firestoreService.getRecipeStream(recetaId),
            builder: (context, recipeSnapshot) {
              if (recipeSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (recipeSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${recipeSnapshot.error}'),
                );
              } else if (!recipeSnapshot.hasData ||
                  !recipeSnapshot.data!.exists) {
                return const Center(
                  child: Text('Receta no encontrada'),
                );
              } else {
                var recipeData =
                    recipeSnapshot.data!.data() as Map<String, dynamic>?;
                if (recipeData == null) {
                  return const Center(
                    child: Text('Datos de la receta no disponibles'),
                  );
                }

                final String name =
                    recipeData['name'] as String? ?? 'Nombre no disponible';
                final List<dynamic> ingredients =
                    recipeData['ingredients'] as List<dynamic>? ?? [];
                final int likesCount = recipeData['likes'] as int? ?? 0;
                final int dislikesCount = recipeData['dislikes'] as int? ?? 0;
                final String imagePath = recipeData['image'] as String? ?? '';

                String ingredientsText = ingredients.join('\n');

                return FutureBuilder<String>(
                  future: _firestoreService.getImageUrl(imagePath),
                  builder: (context, imageSnapshot) {
                    if (imageSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (imageSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${imageSnapshot.error}'),
                      );
                    } else if (!imageSnapshot.hasData ||
                        imageSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Imagen no disponible'),
                      );
                    } else {
                      final imageUrl = imageSnapshot.data!;

                      return buildRecipeUI(
                          name,
                          ingredientsText,
                          recetaId,
                          userId,
                          likesCount,
                          dislikesCount,
                          userVote,
                          imageWidth,
                          imageHeight,
                          imageUrl);
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  Widget buildRecipeUI(
      String name,
      String ingredientsText,
      String recetaId,
      String userId,
      int likesCount,
      int dislikesCount,
      bool? userVote,
      double imageWidth,
      double imageHeight,
      String imageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(name, style: const TextStyle(fontSize: 25)),
            Container(
              width: imageWidth,
              height: imageHeight,
              decoration: boxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kBorderRadius),
                child: AspectRatio(
                  aspectRatio: kImageWidth / kImageHeight,
                  child:
                      // Si usas imágenes de red:
                      Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            Row(
              children: [
                buildLikesSection(
                    recetaId, userId, likesCount, userVote == true),
                buildDislikesSection(
                    recetaId, userId, dislikesCount, userVote == false),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget buildLikesSection(
      String recetaId, String userId, int currentLikes, bool userLiked) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$currentLikes',
              style: const TextStyle(fontSize: 17),
            ),
            IconButton(
              iconSize: 25,
              icon: Icon(
                userLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                color: userLiked ? Colors.blue : null,
              ),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await _firestoreService.voteRecipe(recetaId, userId, true);
                } else {
                  _handleLogout(context);
                }
              },
            ),
          ],
        )
      ],
    );
  }

  Widget buildDislikesSection(
      String recetaId, String userId, int currentDislikes, bool userDisliked) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 25,
              icon: Icon(
                userDisliked
                    ? Icons.thumb_down_alt
                    : Icons.thumb_down_alt_outlined,
                color: userDisliked ? Colors.red : null,
              ),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await _firestoreService.voteRecipe(recetaId, userId, false);
                } else {
                  _handleLogout(context);
                }
              },
            ),
            Text(
              '$currentDislikes',
              style: const TextStyle(fontSize: 17),
            ),
          ],
        )
      ],
    );
  }

/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Title(
              color: const Color.fromARGB(255, 168, 89, 83),
              child: const Center(
                  child: Text(
                "Recomendación a tu gusto",
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ))),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          leading: null,
          automaticallyImplyLeading: false,
          elevation: 5,
        ),
        body: Center(
          child: beastMeals(),
        ),
        backgroundColor: kBackgroundColor);
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
