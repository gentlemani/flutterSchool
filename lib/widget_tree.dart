import 'package:eatsily/auth.dart';
import 'package:eatsily/sesion/sign_in_page.dart';
import 'package:eatsily/sesion/verify_email_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final FirebaseAuth firebaseInstance = FirebaseAuth.instance;

  Future<bool> isUserStillValid() async {
    Completer<bool> completer = Completer<bool>();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is signed out, or the user was deleted.
        completer.complete(false);
      } else {
        // User is still signed in.
        completer.complete(true);
      }
    });

    // Wait for the completer to finish
    return completer.future;
  }

  void _handleLogout(BuildContext context) {
    signOutFunction();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const SignInPage(),
      ),
    );
  }

  Future<void> signOutFunction() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const VerifyEmailPage();
        } else {
          return const SignInPage();
        }
      },
    );
  }
}
