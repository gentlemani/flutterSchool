import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/constants.dart' as constants;

// Collection reference
class DatabaseService {
  final String uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
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
        } else {
          await recipeRef.update({
            'likes': FieldValue.increment(-1),
            'dislikes': FieldValue.increment(1),
          });
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
      } else {
        await recipeRef.update({
          'dislikes': FieldValue.increment(1),
        });
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

      // Si la imagen ya tiene la URL completa (es decir, la URL pública), no necesitas usar Storage
      if (imagePath.startsWith('http')) {
        return imagePath;
      }

      // Si la imagen es solo el path, obtén la URL desde Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(imagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return '';
    }
  }
}
