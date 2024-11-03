import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Set<String> userFrecuencyValuesNames = {
  'Azúcares_y_dulces',
  'Carnes_pescado_y_huevos',
  'Cereales_y_tuberculos',
  'Condimentos_y_salsas',
  'Frutas',
  'Grasas_y_aceites',
  'Lacteos',
  'Legumbres_y_frutos_secos',
  'Verduras_y_hortalizas'
};

//colors palette
const Color colorYellow = Color.fromARGB(255, 217, 210, 20);
const Color colorBlack = Color.fromARGB(255, 0, 0, 0);
const Color colorBlue = Color.fromARGB(255, 52, 162, 206);
const Color colorWhite = Color.fromARGB(255, 255, 255, 255);
const Color colorGreen = Color.fromARGB(255, 24, 200, 67);
const Color colorOrange = Color.fromARGB(255, 234, 120, 27);
const Color colorYellowOrange = Color.fromARGB(255, 231, 160, 28);

//styles
final TextStyle headingTextStyle =
    GoogleFonts.lato(color: Colors.black, fontSize: 24);
final TextStyle bodyTextStyle =
    GoogleFonts.montserrat(color: Colors.black, fontSize: 17);
final TextStyle buttomTextStyle =
    GoogleFonts.poppins(color: Colors.black, fontSize: 18);
final TextStyle instrucctionTextStyle =
    GoogleFonts.nunito(color: Colors.black, fontSize: 16);

  // constants/constants.dart
const double kPaddingValue = 18.0;
const double kImageWidth = 400.0;
const double kTextFontSize = 25.0;
const double kImageHeight = 180.0;
const double kBorderWidth = 3.0;
const double kBorderRadius = 12.0;
const Color kBackgroundColor = Color.fromARGB(255, 255, 255, 255);
const Color kBorderColor = Color.fromARGB(255, 0, 0, 0);
const Color kShadowColor = Color.fromARGB(255, 54, 50, 50);

final BoxDecoration ingredientDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ],
);
const TextStyle ingredientTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
);
final TextStyle quantityTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: Colors.grey[600],
);
