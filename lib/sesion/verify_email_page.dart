import 'dart:async';
import 'package:eatsily/Interface_pages/home_page.dart';
import 'package:eatsily/auth.dart';
import 'package:eatsily/widget_tree.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
/*     |-----------------|
       |    Variables    |
       |-----------------|
*/
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  Timer? timer;
  void _handleLogout(BuildContext context) {
    signOutFunction();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const WidgetTree(),
      ),
    );
  }

  Future<void> signOutFunction() async {
    await Auth().signOut();
  }

/// Will return false if there is not current user
  bool _checkCurrentUser() {
    return _auth.currentUser == null ? false : true;
  }

  Future checkEmailVerified() async {
    if (_checkCurrentUser()) {
      await _auth.currentUser!.reload();
    } else {
      _handleLogout(context);
    }
    setState(() {
      isEmailVerified = _auth.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {
      return Text(e.toString());
    }
  }

/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _handleLogout(context);
    }
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
          const Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const HomePage()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Verificar correo'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Se ha enviado un enlace de verificación a tu correo. Por favor, revisa tu bandeja de entrada.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _auth.currentUser!.sendEmailVerification();
                      },
                      child: const Text('Reenviar enlace de verificación'))
                ],
              ),
            ),
          );
  }
}
