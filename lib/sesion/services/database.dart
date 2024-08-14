import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/constants.dart' as constants;

// Collection reference
class DatabaseService {
  final String uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DatabaseService({required this.uid});

  final CollectionReference userFrecuencyCollection =
      FirebaseFirestore.instance.collection('userFrecuency');

  Future inicializeUserFrequencyRecord() async {
    Map<String, int> userFrecuencyValuesNames = {
      for (var name in constants.userFrecuencyValuesNames) name: 0
    };
    return await userFrecuencyCollection.doc(uid).set(userFrecuencyValuesNames);
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

  Future<List<Map<String, dynamic>>> getRecipes(int limit) async {
    QuerySnapshot snapshot = await _db.collection('Recetas').limit(limit).get();

    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['recetaId'] = doc.id; // Agregar el ID del documento a los datos
      return data;
    }).toList();
  }

  Future<void> voteRecipe(String recetaId, String userId, bool vote) async {
    DocumentReference userVoteRef =
        _db.collection('Users').doc(userId).collection('Vote').doc(recetaId);

    DocumentSnapshot userVoteSnapshot = await userVoteRef.get();

    if (userVoteSnapshot.exists) {
      // El usuario ya ha votado, puedes mostrar un mensaje o simplemente no hacer nada
      return;
    } else {
      // Permitir el voto y registrar el voto del usuario
      await userVoteRef.set({
        'vote': vote,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Luego, actualiza el conteo de votos en la receta
      DocumentReference recipeRef = _db.collection('Recetas').doc(recetaId);

      if (vote == true) {
        await recipeRef.update({
          'likes': FieldValue.increment(1),
        });
      } else if (vote == false) {
        await recipeRef.update({
          'dislikes': FieldValue.increment(1),
        });
      }
    }
  }
}
