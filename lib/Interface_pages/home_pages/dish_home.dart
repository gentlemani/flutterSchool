import 'package:flutter/material.dart';
import 'package:eatsily/sesion/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Constant
const double kPaddingValue = 18.0;
const double kImageWidth = 250.0;
const double kTextFontSize = 25.0;
const double kImageHeight = 180.0;
const double kBorderWidth = 3.0;
const double kBorderRadius = 12.0;
const Color kBackgroundColor = Color.fromARGB(219, 155, 97, 200);
const Color kBorderColor = Color.fromARGB(255, 7, 188, 64);
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
  final String imagePath = 'assets/Fondo2.jpg';
  final int likesCount = 4;

  @override
  void initState() {
    super.initState();
    _firestoreService =
        DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    List<Map<String, dynamic>> recipes =
        await _firestoreService.getRecipes(10); // Limit of 10 recipes
    setState(() {
      _recipes = recipes;
    });
  }
/*     |----------------|
       |    Functions   |
       |----------------|
*/

  Widget beastMeals() {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(kPaddingValue)),
        builHeaderText(),
        const Padding(padding: EdgeInsets.all(kPaddingValue)),
        Flexible(
          child: _recipes.isEmpty
              ? const CircularProgressIndicator()
              : ListWheelScrollView(
                  physics: const FixedExtentScrollPhysics(),
                  itemExtent: 300,
                  diameterRatio: 5,
                  useMagnifier: false,
                  magnification: 1.22,
                  children: _recipes.map((recipe) {
                    return foodInformation(recipe, _firestoreService.uid);
                  }).toList()),
        )
      ],
    );
  }

  Widget foodInformation(Map<String, dynamic> recipe, String userId) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageWidth = screenWidth * 0.6; // 60% of screen width
    final double imageHeight =
        imageWidth * (kImageHeight / kImageWidth); // Maintain aspect ratio
    final String name = recipe['name'];
    final List<dynamic> ingredients = recipe['ingredients'];
    final String recetaId =
        recipe['recetaId']; // Asegúrate de que 'recetaId' esté en el documento
    final int likesCount = recipe['likes'] ?? 0;
    final int dislikesCount = recipe['dislikes'] ?? 0;

    String ingredientsText = ingredients.join('\n');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 25),
            ),
            Container(
              width:
                  imageWidth, // Slightly larger than image to accommodate the border
              height:
                  imageHeight, // Slightly larger than image to accommodate the border
              decoration: boxDecoration(),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      kBorderRadius), // Clip the image inside rounded corners
                  child: AspectRatio(
                    aspectRatio: kImageWidth / kImageHeight,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                    /*Image.network(
                    recipe['imageUrl'] ?? 'https://via.placeholder.com/250',
                    fit: BoxFit.cover,
                  ),*/
                  )),
            ),
            const SizedBox(height: 8), //space between text and image
            buildDescriptionText(ingredientsText, imageWidth)
          ],
        ),
        const SizedBox(width: 10), //space between image and icons
        buildLikesSection(recetaId, userId, likesCount),
        const SizedBox(
          width: 10,
        ), //space between the two icons
        buildDislikesSection(recetaId, userId, dislikesCount)
      ],
    );
  }

  Widget builHeaderText() {
    return const Text(
      "!Recomendación a tu gusto¡",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: kTextFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildDescriptionText(String ingredients, double width) {
    return SizedBox(
      width: width, //text length with the image
      child: Text(
        ingredients,
        textAlign: TextAlign.center, // Center the text
        overflow:
            TextOverflow.ellipsis, // Optional: Sample "..." If it's too long
        maxLines: 3, // limit The Text To A Maximum Of 3 Lines
        style: const TextStyle(fontSize: 17),
      ),
    );
  }

  Widget buildLikesSection(String recetaId, String userId, int currentLikes) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$currentLikes'),
        IconButton(
          icon: const Icon(Icons.thumb_up_alt_outlined),
          onPressed: () async {
            await _firestoreService.voteRecipe(recetaId, userId, true);
            // Aquí podrías actualizar la UI para reflejar el nuevo voto
          },
        )
      ],
    );
  }

  Widget buildDislikesSection(
      String recetaId, String userId, int currentDislikes) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$currentDislikes'),
        IconButton(
          icon: const Icon(Icons.thumb_down_alt_outlined),
          onPressed: () async {
            await _firestoreService.voteRecipe(recetaId, userId, false);
            // Aquí podrías actualizar la UI para reflejar el nuevo voto
          },
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
