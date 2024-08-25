import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/widget_tree.dart';
import 'package:eatsily/auth.dart';
import 'package:eatsily/sesion/verify_email_page.dart';
import 'package:eatsily/sesion/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Create a mock class for Auth
class MockAuth extends Mock implements Auth {}

void main() {
  testWidgets('Shows SignInPage when not authenticated',
      (WidgetTester tester) async {
    // Initialize MockAuth
    final mockAuth = MockAuth();

    // Stub authStateChanges to simulate not authenticated
    when(mockAuth.authStateChanges)
        .thenAnswer((_) => Stream<User?>.value(null));

    // Build the widget tree with the mock auth
    await tester.pumpWidget(
      MaterialApp(
        home: WidgetTree(auth: mockAuth),
      ),
    );

    // Verify SignInPage is shown
    expect(find.byType(SignInPage), findsOneWidget);
  });
}

// Create a mock class for User
class MockUser extends Mock implements User {}
