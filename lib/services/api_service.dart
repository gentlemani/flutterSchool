import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  /// Function to create a new recipe.
  /// It needs the following:
  /// [name] recipe name,
  /// [description] steps to achive the recipe,
  /// [ingredients] an array with the ingredients needed,
  /// [portions] portions needeed for every ingredient,
  /// [imageFile] an image related with the recipe.
  ///
  Future<void> createRecipe(
      String name,
      String description,
      List<String> ingredients,
      List<String> portions,
      String diners,
      File imageFile,
      String token) async {
    try {
      var uri = Uri.parse('${dotenv.get('HOST')}/api/v1/recipe');

      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      var imageStream = http.ByteStream(imageFile.openRead());
      var imageLength = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['diners'] = diners;
      // // Add ingredients as separate fields
      // for (String ingredient in ingredients) {
      //   request.fields.addAll({'ingredients': ingredient});
      // }

      // // Add portions as separate fields with the same key 'portions'
      // for (String portion in portions) {
      //   request.fields.addAll({'portions': portion});
      // }
      request.fields['ingredients'] = jsonEncode(ingredients);
      request.fields['portions'] = jsonEncode(portions);
      request.fields.forEach((key, value) {});
      var response = await request.send();
      if (response.statusCode == 201) {
        print('Receta creada correctamente');
      } else {
        String errorResponse = await response.stream.bytesToString();
        throw Exception('Error ${response.statusCode}: $errorResponse');
      }
    } catch (e) {
      throw Exception('Error al intentar subir la receta: $e');
    }
  }
}
