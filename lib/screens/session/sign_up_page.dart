import 'package:eatsily/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/widgets/common_widget.dart';
import 'package:eatsily/widgets/sign_up_buttons_widget.dart';
import 'package:eatsily/widgets/sign_up_fields_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _auth = AuthService();
  String? errorMessage = '';
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();

  Future<void> createUserWithEmailAndPassword() async {
    try {
      User? user = await _auth.createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
          name:_controllerName.text,
          onError: (String error) {
            setState(() {
              errorMessage = error; // Display the error message in the UI
            });
          });
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'User creation returned a null user object.',
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _mapFirebaseAuthErrorCode(e.code);
      });
    }
  }

  String? _mapFirebaseAuthErrorCode(String code) {
    return _auth.mapErrorCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        CommonWidgets.background(),
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.11,
              horizontal: screenWidth * 0.12,
            ),
            child: Column(
              children: <Widget>[
                const Text(
                  'Registrate',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                UserNameField(controller: _controllerName),
                EmailField(controller: _controllerEmail),
                PasswordField(
                    controller: _controllerPassword,
                    onChanged: (passwd) {
                      setState(() {
                        errorMessage = null;
                      });
                    }),
                const SizedBox(height: 30),
                if (errorMessage != null && errorMessage!.isNotEmpty)
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 10),
                RegisterButton(onPressed: createUserWithEmailAndPassword),
                const SizedBox(height: 5),
                const LinkLogin(),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
