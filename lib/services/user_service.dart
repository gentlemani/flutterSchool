import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../constants/constants.dart' as constants;

class UserService {
  final FirebaseFirestore _db;
  final User? user;
  late final CollectionReference userCollection;
  final FirebaseAuth _firebaseAuth;

  UserService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? db,
    User? user,
  })  : _db = db ?? FirebaseFirestore.instance,
        user = user ?? FirebaseAuth.instance.currentUser,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    userCollection = _db.collection('Users'); // Initialize here
  }

  // Método que faltaba: obtener las IDs de recetas marcadas como "dislike" por el usuario
  Future<List<String>> getDislikedRecipeIds() async {
    DocumentSnapshot userDoc = await userCollection.doc(user?.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      // Asegúrate de que el campo 'dislikedRecipes' esté en el documento del usuario
      List<String> dislikedRecipeIds =
          List<String>.from(userData['dislikedRecipes'] ?? []);
      return dislikedRecipeIds;
    }
    return [];
  }

  Future<void> updateUserData(Map<String, dynamic> frequencyValues) async {
    if (!validateFrequencyValues(frequencyValues)) return;

    await userCollection.doc(user?.uid).set(frequencyValues);
  }

  Future<bool> initializeUserFrequencyRecord(
      {required String name, String? uid}) async {
    uid = uid ?? user?.uid;
    if (uid == null) {
      return false;
    }
    final userFrequencyValuesNames = {
      for (var name in constants.userFrecuencyValuesNames) name: 0
    };

    await userCollection.doc(uid).set({
      ...userFrequencyValuesNames,
      'name': name,
    });
    return true;
  }

  bool validateFrequencyValues(Map<String, dynamic> frequencyValues) {
    for (var entry in frequencyValues.entries) {
      if (!constants.userFrecuencyValuesNames.contains(entry.key) ||
          entry.value is! int) {
        return false;
      }
    }
    return true;
  }

  Future<UserModel?> getUser() async {
    DocumentSnapshot userDoc = await userCollection.doc(user?.uid).get();
    if (user == null && user?.uid == null) {
      return null;
    }else if (userDoc.exists) {
      return UserModel.fromMap(
          user!.uid, userDoc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUserName(String newName) async {
    await userCollection.doc(user?.uid).update({'name': newName});
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> getUserToken() async {
    return await user?.getIdToken();
  }
}
