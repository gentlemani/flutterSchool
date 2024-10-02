import 'package:flutter/material.dart';
import 'package:eatsily/services/api_service.dart';
import 'dart:io';

class UploadProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Future<void> uploadData(
      String name,
      String description,
      List<String> ingredients,
      List<String> portions,
      String diners,
      File imageFile,
      String token) async {
    try {
      await _apiService.createRecipe(
          name, description, ingredients, portions, diners, imageFile, token);
      // Notify UI, e.g., success
      notifyListeners();
    } catch (e) {
      // Handle error, e.g., show a message
      notifyListeners();
    }
  }
}
