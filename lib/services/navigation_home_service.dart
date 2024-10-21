import 'package:eatsily/screens/home/dish_home/dish_home.dart';
import 'package:flutter/material.dart';

class NavigationService {
  static Widget getPage(int index) {
    switch (index) {
      case 0:
        return const DishHome();
      case 1:
        return const DishHome(); //menu
      case 2:
        return const DishHome(); //Account
      default:
        return const DishHome();
    }
  }
}
