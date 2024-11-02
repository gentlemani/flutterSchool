import 'package:flutter/material.dart';
import 'package:eatsily/widgets/home/food_information_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
Widget recommendedDishes(
    List<Map<String, dynamic>> recipes, User user) {
  return LayoutBuilder(builder: (context, constraints) {
    return Column(
      children: [
        Flexible(
          child: recipes.isEmpty
              ? const CircularProgressIndicator()
              : ListView.builder(
                  itemCount: recipes.length < 5 ? recipes.length : 5,
                  itemBuilder: (context, index) {
                    final recipeId = recipes[index]['id'] ?? '';
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: FoodInformation(recipeId: recipeId,userId:  user.uid),
                    );
                  },
                ),
        ),
      ],
    );
  });
}
