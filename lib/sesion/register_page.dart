import 'package:eatsily/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _entryEmailField(
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        alignLabelWithHint: true,
        labelText: 'Correo electronico',
        contentPadding: EdgeInsets.only(top: 30),
        labelStyle: TextStyle(fontSize: 25, color: Colors.black),
      ),
      style: const TextStyle(fontSize: 25),
    );
  }

  Widget _entryPasswordField(
    TextEditingController controller,
  ) {
    return TextField(
        controller: controller,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          alignLabelWithHint: true,
          labelText: 'Contraseña',
          contentPadding: EdgeInsets.only(top: 30),
          labelStyle: TextStyle(fontSize: 25, color: Colors.black),
        ),
        style: const TextStyle(fontSize: 25),
        obscureText: true);
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
        onPressed: signInWithEmailAndPassword,
        child: Text(isLogin ? 'Login' : 'Register'));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(45.0),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 10.0)),
            child: Scaffold(
                backgroundColor: Color.fromARGB(224, 246, 246, 246),
                body: SingleChildScrollView(
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 100, horizontal: 50),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Registrate',
                              style: TextStyle(fontSize: 30),
                            ),
                            TextField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                labelText: 'Usuario',
                                contentPadding: EdgeInsets.only(top: 30),
                                labelStyle: TextStyle(
                                    fontSize: 25, color: Colors.black),
                              ),
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                            _entryPasswordField(_controllerPassword),
                            _entryEmailField(_controllerEmail),
                            SizedBox(
                              height: 70,
                            ),
                            OutlinedButton(
                                onPressed: null,
                                style: ButtonStyle(
                                    textStyle: MaterialStatePropertyAll(
                                        TextStyle(fontSize: 20)),
                                    backgroundColor: MaterialStatePropertyAll(
                                        Color.fromARGB(255, 7, 82, 132))),
                                child: Text(
                                  'Registrar',
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                )),
                          ],
                        ))))));
  }
}
