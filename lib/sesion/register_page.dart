import 'package:eatsily/sesion/services/database.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/common_widgets/common_widgets.dart';

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
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();

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
        await DatabaseService(uid: user.uid).inicializeUserFrequencyRecord(
          name: _controllerName.text,
        );
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
    return TextFormField(
      controller: _controllerName,
      textAlign: TextAlign.center,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (name) {
        if (name == null || name.isEmpty) {
          return 'Por favor, ingresa tu nombre de usuario';
        }
        return null;
      },
      decoration: const InputDecoration(
        alignLabelWithHint: true,
        labelText: 'Usuario',
        contentPadding: EdgeInsets.only(top: 30),
        labelStyle:
            TextStyle(fontSize: 25, color: Color.fromARGB(255, 255, 255, 255)),
      ),
      style: const TextStyle(fontSize: 25, color: Colors.white),
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
          labelStyle: TextStyle(
              fontSize: 25, color: Color.fromARGB(255, 255, 255, 255)),
        ),
        style: const TextStyle(fontSize: 25, color: Colors.white),
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
        labelStyle:
            TextStyle(fontSize: 25, color: Color.fromARGB(255, 255, 255, 255)),
      ),
      style: const TextStyle(fontSize: 25, color: Colors.white),
    );
  }

/*     |---------------|
       |    Buttons    |
       |---------------|
*/

  Widget _submitButton() {
    return OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Procesando registro...Verifique su correo'),
              backgroundColor: Colors.blue,
            ),
          );
          createUserWithEmailAndPassword();
        },
        style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 20),
            backgroundColor: const Color.fromARGB(255, 217, 210, 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(200.0),
                side: const BorderSide(
                    color: Color.fromARGB(255, 255, 255, 255)))),
        child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              'Registrar',
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0)),
            )));
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255)),
      ),
    ));
  }

/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

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
                      horizontal: screenWidth * 0.12),
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Registrate',
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                      userText(),
                      _entryEmailField(_controllerEmail),
                      _entryPasswordField(_controllerPassword),
                      const SizedBox(
                        height: 30,
                      ),
                      if (errorMessage != null && errorMessage!.isNotEmpty)
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
                  )))
        ]));
  }
}
