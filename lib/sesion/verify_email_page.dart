import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/sesion/login_page.dart';

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

/*     |----------------|
       |    Functions   |
       |----------------|
*/

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
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
  Widget build(BuildContext context) => isEmailVerified
      ? const SignInPage()
      : Scaffold(
          appBar: AppBar(
            title: const Text('Verify Email'),
          ),
        );
}
