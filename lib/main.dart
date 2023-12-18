import 'package:eatsily/Fondos/loginFondo.dart';
import 'package:eatsily/firebase_options.dart';
import 'package:eatsily/sesion/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [Fondo(), SignInPage()],
          ),
        ),
        debugShowCheckedModeBanner: false);
  }
}
