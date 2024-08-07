import 'package:flutter/material.dart';

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

  final String imagePath = 'assets/Fondo2.jpg';
  final int likesCount = 4;

/*     |----------------|
       |    Functions   |
       |----------------|
*/

  /*Widget beastMeals() {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(kPaddingValue)),
        builHeaderText(),
        const Padding(padding: EdgeInsets.all(kPaddingValue)),
        Expanded(
          child: ListWheelScrollView(
            physics: const ClampingScrollPhysics(),
            itemExtent: 300,
            diameterRatio: 5,
            useMagnifier: true,
            magnification: 1.22,
            children: [
              foodInformation(),
              foodInformation(),
            ],
          ),
        )
      ],
    );
  }

  Widget foodInformation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Text(
              "Nueces",
              style: TextStyle(fontSize: 20),
            ),
            Container(
              width:
                  260, // Slightly larger than image to accommodate the border
              height:
                  190, // Slightly larger than image to accommodate the border
              decoration: boxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    kBorderRadius), // Clip the image inside rounded corners
                child: Image.asset(
                  imagePath,
                  width: kImageWidth,
                  height: kImageHeight,
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8), //space between text and image
            buildDescriptionText()
          ],
        ),
        const SizedBox(width: 10), //space between image and icons
        buildLikesSection(),
        const SizedBox(
          width: 10,
        ), //space between the two icons
        buildDislikesSection()
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

  Widget buildDescriptionText() {
    return const SizedBox(
      width: kImageWidth, //text length with the image
      child: Text(
        "Praesent venenatis laoreet dui sed euismod. Fusce sed cursus sem, at posuere ex. Nulla vel ligula justo. Vivamus condimentum eros in erat tincidunt sollicitudin.",
        textAlign: TextAlign.center, // Center the text
        overflow:
            TextOverflow.ellipsis, // Optional: Sample "..." If it's too long
        maxLines: 3, // limit The Text To A Maximum Of 3 Lines
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Widget buildLikesSection() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('3'),
        Icon(Icons.thumb_up_alt_outlined),
      ],
    );
  }

  Widget buildDislikesSection() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('2'),
        Icon(
          Icons.thumb_down_alt_outlined,
        )
      ],
    );
  }
*/
/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(child: Text("data")
            //beastMeals(),
            ),
        backgroundColor: kBackgroundColor);
  }
}
/*

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
*/