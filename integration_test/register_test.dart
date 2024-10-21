import 'package:eatsily/screens/session/sign_up_page.dart';
import 'package:eatsily/screens/session/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eatsily/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eatsily/main.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  testWidgets('Check register labels', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(SignInPage), findsOneWidget);
      await tester.tap(find.byKey(const Key('register')));
      await tester.pumpAndSettle();
      
      expect(find.text('Usurio'), findsOneWidget);
      expect(find.text('Correo electronico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Registrar'), findsOneWidget);
      expect(find.text('¿Ya tienes cuenta?'), findsOneWidget);
    });
    testWidgets('Check login submit', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(SignInPage), findsOneWidget);
      await tester.tap(find.byKey(const Key('register')));
      await tester.pumpAndSettle();


      // await tester.enterText(find.byKey(const ValueKey('emailField')),
      //     'fluttermodular21@outlook.com');
      // await tester.enterText(
      //     find.byKey(const ValueKey('passwordField')), '123456');
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(find.text('Error'), findsNothing);
      expect(find.text('Ingresa un correo válido'), findsNothing);
      expect(find.byType(SignInPage), findsNothing);
    });
}