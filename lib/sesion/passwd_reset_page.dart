import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/sesion/sign_in_page.dart';
import 'package:email_validator/email_validator.dart';

class PasswdReset extends StatefulWidget {
  const PasswdReset({super.key});

  @override
  State<PasswdReset> createState() => _PasswdResetState();
}

class _PasswdResetState extends State<PasswdReset> {
/*     |-----------------|
       |    Variables    |
       |-----------------|
*/

  final _controllerEmail = TextEditingController();
  String? errorMessage = '';
  static const String sendedMail =
      'Exitoso. Si el correo está registrado, se enviará un correo para restablecer la contraseña.';

  @override
  void dispose() {
    _controllerEmail.dispose();
    super.dispose();
  }

/*     |-------------------|
       |    text fields    |
       |-------------------|
*/

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
        labelText: 'Correo',
        labelStyle: TextStyle(fontSize: 25, color: Colors.white),
      ),
      style: const TextStyle(fontSize: 25, color: Colors.white),
    );
  }

/*     |----------------------------|
       |          Link text         |
       |----------------------------|
*/

  Widget _linklogin(context) {
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

/*     |---------------|
       |    Buttons    |
       |---------------|
*/

  Widget _submitButton() {
    return TextButton(
      onPressed: () {
        if (_controllerEmail.text.isEmpty ||
            !EmailValidator.validate(_controllerEmail.text.trim())) {
          setState(() {
            errorMessage = 'Por favor escribe un correo';
          });
          return; // Detener la función si algún campo está vacío
        }
        resetPassword(context);
      },
      style: TextButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 217, 210, 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200.0)),
          side: const BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
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

/*     |----------------|
       |    Functions   |
       |----------------|
*/

  Future resetPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _controllerEmail.text.trim())
          .then((_) {
        if (!mounted) return; // Verificar si el widget sigue montado
        showSimpleSnackBar(context, sendedMail);
      }).then((_) {
        if (!mounted) return; // Verificar si el widget sigue montado
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      });
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
        showSimpleSnackBar(context, 'Exitoso :)');
        showSimpleSnackBar(context, sendedMail);
    }
  }

/*     |-----------------------------|
       |          background         |
       |-----------------------------|
*/

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

/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

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
                  const SizedBox(height: 20),
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
