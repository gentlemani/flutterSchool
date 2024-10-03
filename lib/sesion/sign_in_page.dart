import 'package:eatsily/services/auth_service.dart';
import 'package:eatsily/sesion/passwd_reset_page.dart';
import 'package:eatsily/sesion/register_page.dart';
import 'package:eatsily/widget_tree.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/common_widgets/common_widgets.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
/*     |-----------------|
       |    Variables    |
       |-----------------|
*/

  String? errorMessage = '';

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

/*     |----------------|
       |    Functions   |
       |----------------|
*/

  Future<bool> signInWithEmailAndPassword() async {
    // Variable to indicate if the authentication was successful
    bool isAuthenticated = false;
    // Verify that the fields are not empty
    if (_controllerEmail.text.isEmpty || _controllerPassword.text.isEmpty) {
      setState(() {
        errorMessage = 'Campos vacios';
      });
      return isAuthenticated; // Return false if any field is empty
    }
    try {
      await AuthService().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      // If an exception was not launched, the authentication was successful
      isAuthenticated = true;
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _mapFirebaseAuthErrorCode(e.code);
      });
    }
    return isAuthenticated; // Return false if any field is empty
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await AuthService().createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _mapFirebaseAuthErrorCode(e.code);
      });
    }
  }

// Change default error messages
  String _mapFirebaseAuthErrorCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Formato de correo incorrecto';
      case 'email-already-in-use':
        return 'Usuario ya existente';
      default:
        return 'Correo o contraseña incorrecta';
    }
  }

/*     |-------------------|
       |    Text fields    |
       |-------------------|
*/

  Widget _entryPasswordField(
    TextEditingController controller,
  ) {
    return TextFormField(
        key: const Key('passwordField'),
        controller: controller,
        textAlign: TextAlign.center,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (passwd) {
          if (passwd == null || passwd.isEmpty) {
            return 'Por favor, ingresa tu contraseña';
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
    return TextFormField(
      key: const Key('emailField'),
      controller: controller,
      textAlign: TextAlign.left,
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
        labelStyle:
            TextStyle(fontSize: 25, color: Color.fromARGB(255, 255, 255, 255)),
      ),
      style: const TextStyle(
          fontSize: 25, color: Color.fromARGB(255, 255, 255, 255)),
    );
  }

/*     |----------------------------|
       |          Link text         |
       |----------------------------|
*/

  Widget _passwdResetText(context) {
    return Center(
        child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PasswdReset()),
        );
      },
      child: const Text(
        '¿Contraseña olvidada?',
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255)),
      ),
    ));
  }

/*     |---------------|
       |    Buttons    |
       |---------------|
*/

  Widget _submitButton() {
    return TextButton(
      key: const Key('submit'),
      onPressed: () async {
        try {
          if (_controllerEmail.text.isEmpty ||
              _controllerPassword.text.isEmpty) {
            setState(() {
              errorMessage = 'Por favor, completa todos los campos.';
            });
            return; //Stop the function if any field is empty
          } else {
            bool isAuthenticated = await signInWithEmailAndPassword();
            if (mounted) {
              if (isAuthenticated) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const WidgetTree()),
                );
              }
            } else {
              const Text(
                  'Error al iniciar sesión:'); //Failed authentication: Show an error message to the user
            }
          }
        } catch (e) {
          setState(() {
            errorMessage = 'Error al iniciar sesión: $e';
          });
        }
      },
      style: TextButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 217, 210, 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200.0),
              side:
                  const BorderSide(color: Color.fromARGB(255, 255, 255, 255)))),
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
      key: const Key('register'),
      onPressed: () async {
        // Navigate to the login.dart screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpPage()),
        );
      },
      style: TextButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 217, 210, 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200.0),
              side:
                  const BorderSide(color: Color.fromARGB(255, 255, 255, 255)))),
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

/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(children: [
      CommonWidgets.background(),
      Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.03, horizontal: screenWidth * 0.12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              const Text(
                'Eatsily',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 254, 250, 250)),
              ),
              const Text(
                'Come seguro',
                style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255)),
              ),
              const SizedBox(height: 10),
              _entryEmailField(_controllerEmail),
              _entryPasswordField(_controllerPassword),
              const SizedBox(height: 10),
              if (errorMessage != null && errorMessage!.isNotEmpty)
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              _submitButton(),
              const SizedBox(
                height: 10,
              ),
              _registerButton(),
              const SizedBox(
                height: 10,
              ),
              _passwdResetText(context),
            ],
          ),
        ),
      ),
    ]));
  }
}
