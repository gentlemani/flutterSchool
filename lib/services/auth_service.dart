import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eatsily/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
    required Function(String) onError,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      onError(mapErrorCode(e.code));
      return false;
    }
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required Function(String) onError,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final UserService userService =
          UserService(user: userCredential.user, firebaseAuth: _auth, db: _db);
      userService.initializeUserFrequencyRecord(name: name);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      onError(mapErrorCode(e.code));
      return null;
    }
  }

  String mapErrorCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Formato de correo incorrecto';
      case 'email-already-in-use':
        return 'Usuario ya existente';
      default:
        return 'Correo o contraseña incorrecta';
    }
  }
    Future<void> signOut() async {
    await _auth.signOut();
  }
  Future<String?> getUserToken() async {
      return await _auth.currentUser?.getIdToken();
  }
}
