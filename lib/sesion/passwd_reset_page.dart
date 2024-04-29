import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/sesion/login_page.dart';
import 'package:email_validator/email_validator.dart';

class PasswdReset extends StatefulWidget {
  const PasswdReset({super.key});

  @override
  State<PasswdReset> createState() => _PasswdResetState();
}

class _PasswdResetState extends State<PasswdReset> {
  final _controllerEmail = TextEditingController();
  String? errorMessage = '';
  static const String sendedMail =
      'Exitoso. Si el correo está registrado, se enviará un correo para restablecer la contraseña.';
  @override
  void dispose() {
    _controllerEmail.dispose();
    super.dispose();
  }

  Widget _title() {
    return const Text('Volver');
  }

  Widget _entryEmailField(
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.left,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (email) => email != null && !EmailValidator.validate(email)
          ? 'Ingresa un correo válido'
          : null,
      decoration: const InputDecoration(
        alignLabelWithHint: true,
        labelText: 'Correo',
        labelStyle: TextStyle(fontSize: 25, color: Colors.white),
      ),
      style: const TextStyle(fontSize: 25, color: Colors.white),
    );
  }

  Widget _linklogin(context) {
    return Center(
        child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
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

  Widget _submitButton() {
    return TextButton(
      onPressed: () {
        if (_controllerEmail.text.isEmpty) {
          setState(() {
            errorMessage = 'Por favor, completa todos los campos.';
          });
          return; // Detener la función si algún campo está vacío
        }
        resetPassword(context);
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
          'Enviar',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
    );
  }

  Future resetPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _controllerEmail.text.trim())
          .then((_) => showSimpleSnackBar(context, sendedMail))
          .then((_) => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SignInPage())));
    } on FirebaseAuthException catch (e) {
      setState(() {
        _mapFirebaseAuthErrorCode(context, e.code);
      });
    }
  }

  void showSimpleSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration:
            const Duration(seconds: 6), // Display the snack bar for 6 seconds
      ),
    );
  }

  void _mapFirebaseAuthErrorCode(BuildContext context, String code) {
    switch (code) {
      case 'network-request-failed':
        showSimpleSnackBar(context, 'Conexión falló');
      case 'too-many-requests':
        showSimpleSnackBar(context, 'Demasiadas peticiones');
      default:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const SignInPage()));
        showSimpleSnackBar(context, sendedMail);
    }
  }

  Widget background() {
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _title(),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 251, 251, 251),
          fontSize: 20.0,
        ),
        iconTheme: const IconThemeData(color: Colors.redAccent),
        actionsIconTheme: const IconThemeData(color: Colors.redAccent),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(children: [
        background(),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 130.0),
              Text(
                'Restablecer contraseña',
                style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 254, 250, 250)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _entryEmailField(_controllerEmail),
                  const SizedBox(height: 30),
                  _submitButton(),
                  const SizedBox(height: 20),
                  _linklogin(context),
                ]),
          ),
        )
      ]),
    );
  }
}
