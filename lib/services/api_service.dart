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
      request.fields['ingredients'] = jsonEncode(ingredients);
      request.fields['portions'] = jsonEncode(portions);
      var response = await request.send();
      if (response.statusCode == 201) {
      } else {
        String errorResponse = await response.stream.bytesToString();
        throw Exception('Error ${response.statusCode}: $errorResponse');
      }
    } catch (e) {
      throw Exception('Error al intentar subir la receta: $e');
    }
  }

  Future<List<dynamic>> getRecommendations(String token) async {
    try {
      var uri = Uri.parse('${dotenv.get('HOST')}/api/v1/recommendation');
      var response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['recommendations'];
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener las recomendaciones: $e');
    }
  }

  Future<List<String>> updateRecipe(
      List<String> ingredients, String token) async {
    try {
      var uri = Uri.parse('${dotenv.get('HOST')}/api/v1/category');

      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['ingredients'] = jsonEncode(ingredients);
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var responseBody = responseData.body;
        var jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['Categories'] != null) {
          List<String> category = List<String>.from(jsonResponse['Categories']);
          return category;
        } else {
          throw Exception('La respuesta no contiene el campo "categories"');
        }
      } else {
        throw Exception(
            'Failed to upload. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al intentar editar la receta: $e');
    }
  }
}
