import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsily/Interface_pages/home_pages/recipes_page/recipes.dart';
import 'package:eatsily/sesion/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

class AllRecipes extends StatefulWidget {
  const AllRecipes({super.key});

  @override
  State<AllRecipes> createState() => _AllRecipesState();
}

class _AllRecipesState extends State<AllRecipes> {
  late final DatabaseService _firestoreService;
  List<Map<String, dynamic>> _recipes = [];
  late final FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    if (_auth.currentUser != null) {
      _firestoreService = DatabaseService(uid: _auth.currentUser!.uid);
      _fetchRecipes(); // Only if it is authenticated the recipes are charged
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

  Future<void> _fetchRecipes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get all recipes
      QuerySnapshot snapshot = await _firestoreService.getAllRecipes();

      // Filter recipes to exclude what the user has marked as 'Dislike'
      List<Map<String, dynamic>> recipes = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['recetaId'] = doc.id; // Add the document ID to the data
        return data;
      }).toList();
      recipes = recipes.where((recipe) {
        return recipe['created_by'] == null ||
            recipe['created_by'] == _auth.currentUser!.uid;
      }).toList();

      setState(() {
        _recipes = recipes;
      });
    }
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
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Define a percentage of the screen that each element should occupy
    final itemHeight = screenHeight * 0.3;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Todas las recetas"),
          backgroundColor: Colors.white,
          elevation: 10,
          shadowColor: Colors.grey,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
          leading: IconButton(
            icon: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2)),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color.fromARGB(255, 0, 0, 0),
                )),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Flexible(
                child: _recipes.isEmpty
                    ? const CircularProgressIndicator()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemExtent: itemHeight,
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final String recetaId = _recipes[index]['recetaId'];
                          return foodInformation(
                              recetaId, _firestoreService.uid);
                        },
                      ))
          ],
        ));
  }
}
