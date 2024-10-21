import 'package:eatsily/screens/home/home_page.dart';
import 'package:eatsily/screens/home/dish_home/dish_home.dart';
import 'package:eatsily/main.dart';
import 'package:eatsily/screens/session/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eatsily/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  setUpAll(() async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Future.delayed(const Duration(seconds: 4)); // Optional setup delay
  });
  group('SingInPage labels', () {
    testWidgets('Check login labels', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('Recomendación a tu gusto'), findsNothing);
      expect(find.text('Perfil'), findsNothing);
      expect(find.text('Recetario'), findsNothing);
      expect(find.text('Correo electronico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Ingresar'), findsOneWidget);
      expect(find.text('Registrar'), findsOneWidget);
    });

    testWidgets('Check login submit', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(SignInPage), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('emailField')),
          'fluttermodular21@outlook.com');
      await tester.enterText(
          find.byKey(const ValueKey('passwordField')), '123456');
      await tester.tap(find.byKey(const Key('submit')));
      await Future.delayed(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(find.text('Correo o contraseña incorrecta'), findsNothing);
      expect(find.text('Por favor, completa todos los campos.'), findsNothing);
      expect(find.byType(SignInPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(DishHome), findsOneWidget);
    });
  });
}
