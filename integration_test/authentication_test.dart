import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eatsily/auth.dart'; // Replace with the path to your Auth class

// Mock class for FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late Auth auth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    auth = Auth(firebaseAuth: mockFirebaseAuth);
  });
  test(
      'createUserWithEmailAndPassword calls FirebaseAuth.createUserWithEmailAndPassword',
      () async {
    // Arrange
    final email = 'newuser@example.com';
    final password = 'password';
    final mockUserCredential = MockUserCredential();

    // Set up the mock return values
    when(mockFirebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    )).thenAnswer((_) async => mockUserCredential);

    // Act
    await auth.createUserWithEmailAndPassword(email: email, password: password);

    // Assert
    verify(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password))
        .called(1);
  });
  test(
      'signInWithEmailAndPassword calls FirebaseAuth.signInWithEmailAndPassword',
      () async {
    // Arrange
    final email = 'test@example.com';
    final password = 'password';
    final mockUserCredential = MockUserCredential();

    // Set up the mock return values
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    )).thenAnswer((_) async => mockUserCredential);

    // Act
    await auth.signInWithEmailAndPassword(email: email, password: password);

    // Assert
    verify(mockFirebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .called(1);
  });

  test('signOut calls FirebaseAuth.signOut', () async {
    // Arrange
    when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

    // Act
    await auth.signOut();

    // Assert
    verify(mockFirebaseAuth.signOut()).called(1);
  });
}
