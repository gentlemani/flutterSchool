import 'dart:async';
import 'package:eatsily/Interface_pages/home_page.dart';
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

  bool isEmailVerified = false;
  Timer? timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

/*     |----------------|
       |    Functions   |
       |----------------|
*/

  @override
  void initState() {
    super.initState();
    isEmailVerified = _auth.currentUser!.emailVerified;
    if (!isEmailVerified) {
      _auth.currentUser!.sendEmailVerification();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
