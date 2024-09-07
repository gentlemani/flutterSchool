import 'package:eatsily/sesion/services/database.dart';
import 'package:eatsily/widget_tree.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
/*     |-----------------|
       |    Variables    |
       |-----------------|
*/
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? errorMessage = '';
  bool isLogin = true;
  // Password criteria
  // At least one lowercase letter, one uppercase letter, one number and one special symbol
  // Minimum length 6
  // RegExp regex =
  //     RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^A-Za-z0-9]).{6,}$');

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

/*     |----------------|
       |    Functions   |
       |----------------|
*/

  Future<void> createUserWithEmailAndPassword() async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      User? user = result.user;
      if (user != null) {
        await DatabaseService(uid: user.uid).inicializeUserFrequencyRecord();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WidgetTree()),
          );
        }
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
    switch (code) {
      case 'invalid-email':
        return 'Correo incorrecto';
      case 'email-already-in-use':
        return 'Usuario ya existente';
      case 'weak-password':
        return 'Contraseña debil, por favor utilice 6 o más caracteres';
      default:
        return 'Error';
    }
  }

/*     |-------------------|
       |    text fields    |
       |-------------------|
*/

  Widget userText() {
    return const TextField(
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: 'Usuario',
        contentPadding: EdgeInsets.only(top: 30),
        labelStyle: TextStyle(fontSize: 25, color: Colors.black),
      ),
      style: TextStyle(
        fontSize: 25,
      ),
    );
  }

  Widget _entryPasswordField(
    TextEditingController controller,
  ) {
    return TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (passwd) {
          if (passwd == null || passwd.isEmpty) {
            return 'Por favor, ingresa una contraseña';
          }
          return null;
        },
        onChanged: (passwd) {
          setState(() {
            errorMessage = null;
          });
        },
        decoration: const InputDecoration(
          alignLabelWithHint: true,
          errorMaxLines: 2,
          labelText: 'Contraseña',
          contentPadding: EdgeInsets.only(top: 30),
          labelStyle: TextStyle(fontSize: 25, color: Colors.black),
        ),
        style: const TextStyle(fontSize: 25),
        obscureText: true);
  }

  Widget _entryEmailField(
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (email) {
        if (email == null || email.isEmpty) {
          return 'Por favor, ingresa tu correo electrónico';
        }
        if (!EmailValidator.validate(email)) {
          return 'Ingresa un correo válido';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          errorMessage = null;
        });
      },
      decoration: const InputDecoration(
        alignLabelWithHint: true,
        labelText: 'Correo electronico',
        contentPadding: EdgeInsets.only(top: 30),
        labelStyle: TextStyle(fontSize: 25, color: Colors.black),
      ),
      style: const TextStyle(fontSize: 25),
    );
  }

/*     |---------------|
       |    Buttons    |
       |---------------|
*/

  Widget _submitButton() {
    return OutlinedButton(
        onPressed: createUserWithEmailAndPassword,
        style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 20),
            backgroundColor: const Color.fromARGB(255, 7, 82, 132)),
        child: const Text(
          'Registrar',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ));
  }

/*     |----------------------------|
       |          Link text         |
       |----------------------------|
*/

  Widget linklogin() {
    return Center(
        child: GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: const Text(
        '¿Ya tienes cuenta?',
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    ));
  }

/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(45.0),
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(
                        162, 26, 134, 222), // Color de las barras azules
                    const Color.fromARGB(255, 255, 255, 255),
                    const Color.fromARGB(
                        255, 255, 255, 255), // Color de las barras azules
                    const Color.fromARGB(162, 26, 134, 222)
                        .withOpacity(0.8), // Color de las barras azules
                  ],
                  stops: const [0.1, 0.25, 0.6, 1],
                ),
                border: Border.all(color: Colors.black, width: 10.0)),
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 100, horizontal: 50),
                        child: Column(
                          children: <Widget>[
                            const Text(
                              'Registrate',
                              style: TextStyle(fontSize: 30),
                            ),
                            userText(),
                            _entryPasswordField(_controllerPassword),
                            _entryEmailField(_controllerEmail),
                            const SizedBox(
                              height: 30,
                            ),
                            if (errorMessage != null &&
                                errorMessage!.isNotEmpty)
                              Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            const SizedBox(
                              height: 10,
                            ),
                            _submitButton(),
                            const SizedBox(height: 5),
                            linklogin(),
                          ],
                        ))))));
  }
}
