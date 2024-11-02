import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsily/models/recipe_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RecipeService {
  final FirebaseFirestore _db;
  late final CollectionReference recipeCollection;

  RecipeService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance {
    recipeCollection = _db.collection('Recetas'); // Initialize collection
  }

  // Obtener un stream para escuchar cambios en una receta específica
  Stream<DocumentSnapshot> getRecipeStream(String recetaId) {
    return recipeCollection.doc(recetaId).snapshots();
  }

  // Obtener recetas por lista de IDs
  Future<List<RecipeModel>> getRecipesByIds(List<String> ids) async {
    List<RecipeModel> recipes = [];
    for (String id in ids) {
      DocumentSnapshot doc = await recipeCollection.doc(id).get();
      if (doc.exists) {
        recipes.add(
            RecipeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>));
      }
    }
    return recipes;
  }

  // Obtener una lista de recetas con límite
  Future<List<RecipeModel>> getRecipes(int limit) async {
    QuerySnapshot snapshot = await recipeCollection.limit(limit).get();
    return snapshot.docs.map((doc) {
      return RecipeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Votar una receta (Like/Dislike)
  Future<void> voteRecipe(String recetaId, String userId, bool vote) async {
    DocumentReference userVoteRef =
        _db.collection('Users').doc(userId).collection('Vote').doc(recetaId);
    DocumentSnapshot userVoteSnapshot = await userVoteRef.get();
    DocumentReference recipeRef = recipeCollection.doc(recetaId);

    if (userVoteSnapshot.exists) {
      bool previousVote = userVoteSnapshot['vote'] as bool;
      if (previousVote != vote) {
        await userVoteRef.update({'vote': vote});
        // Update the recipe's like/dislike count
        if (vote) {
          await recipeRef.update({
            'likes': FieldValue.increment(1),
            'dislikes': FieldValue.increment(-1),
          });
        } else {
          await recipeRef.update({
            'likes': FieldValue.increment(-1),
            'dislikes': FieldValue.increment(1),
          });
        }
      }
    } else {
      await userVoteRef.set({
        'vote': vote,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (vote) {
        await recipeRef.update({
          'likes': FieldValue.increment(1),
        });
      } else {
        await recipeRef.update({
          'dislikes': FieldValue.increment(1),
        });
      }
    }
  }

  // Obtener la URL de una imagen desde Firestore Storage
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
}
