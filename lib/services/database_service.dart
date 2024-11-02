import 'user_service.dart';
import 'recipe_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final UserService userService;
  final RecipeService recipeService;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService({
    UserService? userService,
    RecipeService? recipeService,
  })  : recipeService = recipeService ?? RecipeService(),
        userService = userService ?? UserService();

  Stream<DocumentSnapshot> getUserVoteStream(String recetaId, String userId) {
    return _db
        .collection('Users')
        .doc(userId)
        .collection('Vote')
        .doc(recetaId)
        .snapshots();
  }

    Future<void> voteRecipe(String recetaId, String userId, bool vote) async {
    DocumentReference userVoteRef =
        _db.collection('Users').doc(userId).collection('Vote').doc(recetaId);
    DocumentSnapshot userVoteSnapshot = await userVoteRef.get();
    DocumentReference recipeRef = _db.collection('Recetas').doc(recetaId);

    if (userVoteSnapshot.exists) {
      // The user has already voted
      bool previousVote = userVoteSnapshot['vote'];

      if (previousVote != vote) {
        // The user is changing his vote, updates the counters
        await userVoteRef.update({
          'vote': vote,
          'timestamp': FieldValue.serverTimestamp(),
        });
        // Change Likes/Dyslike counters in the recipe
        if (vote == true) {
          await recipeRef.update({
            'likes': FieldValue.increment(1),
            'dislikes': FieldValue.increment(-1),
          });
          increaseFieldsOrDecremend(recetaId, userId, vote);
        } else {
          await recipeRef.update({
            'likes': FieldValue.increment(-1),
            'dislikes': FieldValue.increment(1),
          });
          increaseFieldsOrDecremend(recetaId, userId, vote);
        }
      } else {
        // If the vote is the same, we do nothing
        return;
      }
    } else {
      await userVoteRef.set({
        'vote': vote,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // Update the vote counting in the recipe
      if (vote == true) {
        await recipeRef.update({
          'likes': FieldValue.increment(1),
        });
        increaseFieldsOrDecremend(recetaId, userId, vote);
      } else {
        await recipeRef.update({
          'dislikes': FieldValue.increment(1),
        });
        increaseFieldsOrDecremend(recetaId, userId, vote);
      }
    }
  }

    Future<void> increaseFieldsOrDecremend(
      String recipeId, String userId, bool vote) async {
    DocumentReference userCategoryReference =
        _db.collection('Users').doc(userId);
    DocumentSnapshot userCategoryDoc = await userCategoryReference.get();

    DocumentReference recipeReference = _db.collection('Recetas').doc(recipeId);
    DocumentSnapshot recipeDoc = await recipeReference.get();

    if (userCategoryDoc.exists && recipeDoc.exists) {
      Map<String, dynamic> userData =
          userCategoryDoc.data() as Map<String, dynamic>;
      List<dynamic> recipeCategories = recipeDoc['category'];
      Map<String, dynamic> updates = {};

      Map<String, String> categoryMapping = {
        'Categoria_Azúcares_y_dulces': 'Azúcares_y_dulces',
        'Categoria_Carnes_pescado_y_huevos': 'Carnes_pescado_y_huevos',
        'Categoria_Cereales_y_tuberculos': 'Cereales_y_tuberculos',
        'Categoria_Condimentos_y_salsas': 'Condimentos_y_salsas',
        'Categoria_Frutas': 'Frutas',
        'Categoria_Grasas_y_aceites': 'Grasas_y_aceites',
        'Categoria_Lacteos': 'Lacteos',
        'Categoria_Legumbres_y_frutos_secos': 'Legumbres_y_frutos_secos',
        'Categoria_Verduras_y_hortalizas': 'Verduras_y_hortalizas',
      };
      for (var category in recipeCategories) {
        // Solo aumentar o disminuir si el campo está presente en el documento del usuario
        String? userField = categoryMapping[category];
        if (userField != null && userData.containsKey(userField)) {
          if (vote == true) {
            // Si el valor de la categoría es mayor o igual a 0, aumentar
            if (userData[userField] != -1 && userData[userField] >= 0) {
              updates[userField] = userData[userField] + 1;
            }
          } else {
            // Si es un dislike, disminuir si es mayor que 0
            if (userData[userField] != -1 && userData[userField] > 0) {
              updates[userField] = userData[userField] - 1;
            }
          }
        }
      }
      // Si hay actualizaciones, aplicarlas al documento
      if (updates.isNotEmpty) {
        await userCategoryReference.update(updates);
      }
    }
  }

  Future<Map<String, dynamic>?> fetchRecipeData(String recetaId) async {
    try {
      DocumentSnapshot doc = await _db.collection('Recetas').doc(recetaId).get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      rethrow;
    }
  }

}

