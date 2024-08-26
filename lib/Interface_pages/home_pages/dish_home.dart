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

/*     |----------------|
       |    Functions   |
       |----------------|
*/

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
    return Column(
      children: [
        Flexible(
            child: _recipes.isEmpty
                ? const CircularProgressIndicator()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemExtent: 270,
                    itemCount: _recipes.length,
                    //magnification: 1.22,
                    itemBuilder: (context, index) {
                      final String recetaId = _recipes[index]['recetaId'];
                      return foodInformation(recetaId, _firestoreService.uid);
                    },
                  ))
      ],
    );
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
              // Carga de Imagen
              FutureBuilder<String>(
                future: _firestoreService.getImageUrl(imagePath),
                builder: (context, imageSnapshot) {
                  if (imageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (imageSnapshot.hasError) {
                    return Center(child: Text('Error: ${imageSnapshot.error}'));
                  } else if (!imageSnapshot.hasData ||
                      imageSnapshot.data!.isEmpty) {
                    return const Center(child: Text('Imagen no disponible'));
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
              ),
              Text(name, style: const TextStyle(fontSize: 25)),
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
                        _handleLogout(context);
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
    return Container(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.005, horizontal: screenWidth * 0.01),
        child: Scaffold(
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
              child: recommendedDishes(),
            ),
            backgroundColor: kBackgroundColor));
  }
}
