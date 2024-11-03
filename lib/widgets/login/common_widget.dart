import 'package:flutter/material.dart';

class CommonWidgets {
  static Widget background({
    String imagePath = 'assets/Fondo4.jpg',
    Color borderColor = Colors.black,
    double borderWidth = 5.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  static Widget title(
      {String title = "Eatsily", String subTitle = "Come seguro"}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 254, 250, 250),
          ),
        ),
        const SizedBox(height: 5), // Adding space between the texts
        Text(
          subTitle,
          style: const TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ],
    );
  }
}
