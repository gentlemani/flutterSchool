import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/constants.dart' as constants;

// Collection reference
class DatabaseService {
  final String uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  DatabaseService({required this.uid});

  final CollectionReference userFrecuencyCollection =
      FirebaseFirestore.instance.collection('Users');

  Future inicializeUserFrequencyRecord({required String name}) async {
    Map<String, int> userFrecuencyValuesNames = {
      for (var name in constants.userFrecuencyValuesNames) name: 0
    };
    return await userFrecuencyCollection
        .doc(uid)
        .set({...userFrecuencyValuesNames, 'name': name});
  }

  Future updateUserData(Map<String, dynamic> frecuencyValues) async {
    for (var dataFrecuency in frecuencyValues.entries) {
      if (!constants.userFrecuencyValuesNames.contains(dataFrecuency.key) ||
          !dataFrecuency.value is int) {
        return null;
      }
    }
    return await userFrecuencyCollection.doc(uid).set(frecuencyValues);
  }

  Future<QuerySnapshot> getAllRecipes() async {
    return await _db.collection('Recetas').get();
  }

  Stream<DocumentSnapshot> getUserVoteStream(String recetaId, String userId) {
    return _db
        .collection('Users')
        .doc(userId)
        .collection('Vote')
        .doc(recetaId)
        .snapshots();
  }

  Stream<DocumentSnapshot> getRecipeStream(String recetaId) {
    return _db.collection('Recetas').doc(recetaId).snapshots();
  }

  Future<List<Map<String, dynamic>>> getRecipesByIds(List<String> ids) async {
    List<Map<String, dynamic>> recipes = [];

    final snapshots = await FirebaseFirestore.instance
        .collection('Recetas')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    for (var snapshot in snapshots.docs) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        data['id'] = snapshot.id;
        recipes.add(data);
      }
    }

    return recipes;
  }

  Future<List<Map<String, dynamic>>> getRecipes(int limit) async {
    QuerySnapshot snapshot = await _db.collection('Recetas').limit(limit).get();

    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['recetaId'] = doc.id; // Add the document ID to the data
      return data;
    }).toList();
  }

  Future<QuerySnapshot> getRecipes2(int limit) async {
    return await _db.collection('Recetas').limit(limit).get();
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

  Future<List<String>> getDislikedRecipeIds(String userId) async {
    QuerySnapshot snapshot = await _db
        .collection('Users')
        .doc(userId)
        .collection('Vote')
        .where('vote', isEqualTo: false)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<DocumentSnapshot> getUserVote(String recetaId, String userId) async {
    return await _db
        .collection('Users')
        .doc(userId)
        .collection('Vote')
        .doc(recetaId)
        .get();
  }

  Future<String> getImageUrl(String imagePath) async {
    try {
      if (imagePath.isEmpty) {
        throw 'La ruta de la imagen es vacía';
      }

      // If the image already has the complete url (that is, the public URL), you do not need to use storage
      if (imagePath.startsWith('http')) {
        return imagePath;
      }

      //If the image is just the path, get the URL from Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(imagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return '';
    }
  }

  Future<String?> getUserName() async {
    // Get the current user
    if (user == null) {
      return null; // If the user is not authenticated, Null returns
    }

    // Get the user's document in the "Users" collection
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user?.uid)
        .get();
    if (userDoc.exists) {
      // Returns the "name" field of the document if it exists
      return userDoc.get('name');
    } else {
      return null;
    } // Null returns if the user is not authenticated or does not have a registered name
  }

  Future<void> updateUserName(String newName) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(uid).update({
        'name': newName,
      });
    } catch (e) {
      return;
    }
  }
}
