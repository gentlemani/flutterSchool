import 'package:eatsily/auth.dart';
import 'package:eatsily/sesion/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
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

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
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
          labelStyle: TextStyle(
              fontSize: 25, color: Color.fromARGB(255, 255, 255, 255)),
        ),
        style: const TextStyle(
            fontSize: 25, color: Color.fromARGB(255, 255, 255, 255)),
        obscureText: true);
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
        labelStyle:
            TextStyle(fontSize: 25, color: Color.fromARGB(255, 255, 255, 255)),
      ),
      style: const TextStyle(
          fontSize: 25, color: Color.fromARGB(255, 255, 255, 255)),
    );
  }

  // Widget _errorMessage() {
  //   return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  // }

  Widget _submitButton() {
    return TextButton(
      onPressed: signInWithEmailAndPassword,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            const Color.fromARGB(255, 217, 210, 20),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(200.0),
                  side: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255))))),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: const Text(
          'Ingresar',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return TextButton(
      onPressed: () {
        // Navegar a la pantalla de login.dart
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpPage()),
        );
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            const Color.fromARGB(255, 217, 210, 20),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(200.0),
                  side: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255))))),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: const Text(
          'Registrar',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
    );
  }

  Widget fondo() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 5.0,
        ),
        image: const DecorationImage(
          image: AssetImage('assets/Fondo4.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      fondo(),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 30),
              const Text(
                'Eatsily',
                style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 254, 250, 250)),
              ),
              const Text(
                'Come seguro',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255)),
              ),
              const SizedBox(height: 20),
              _entryEmailField(_controllerEmail),
              _entryPasswordField(_controllerPassword),
              const SizedBox(height: 20),
              _submitButton(),
              const SizedBox(
                height: 20,
              ),
              _registerButton(),
            ],
          ),
        ),
      ),
    ]));
  }
}
