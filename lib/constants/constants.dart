import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Set<String> userFrecuencyValuesNames = {
  'carne',
  'fruta',
  'verdura',
  'grasas',
  'cereales',
  'lacteos'
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
