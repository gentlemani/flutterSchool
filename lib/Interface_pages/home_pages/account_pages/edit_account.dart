import 'dart:async';

import 'package:eatsily/sesion/services/database.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditAccount extends StatefulWidget {
  final Widget gestureImage;
  const EditAccount({super.key, required this.gestureImage});

  @override
  State<EditAccount> createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  late final DatabaseService _firestoreService;
  final TextEditingController controlleruser = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPass = TextEditingController();
  final TextEditingController controllerPassNew = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  String? successMessage = '';
  final _formKey = GlobalKey<FormState>();

  Future<void> fetchUserName() async {
    String? name = await _firestoreService.getUserName();
    setState(() {
      controlleruser.text = name ?? '';
      controllerEmail.text = user?.email ?? '';
    });
  }

  Widget _buttomUpdate() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          updatePassword();
        }
      },
      style: ElevatedButton.styleFrom(minimumSize: const Size(250, 50)),
      child: const Text(
        "Actualizar contraseña",
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
    );
  }

  Future<void> updatePassword() async {
    try {
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
            email: user!.email ?? '', password: controllerPass.text.trim());
        await user!.reauthenticateWithCredential(credential);
        await user!.updatePassword(controllerPassNew.text.trim());
        setState(() {
          successMessage = 'Contraseña actualizada con extito';
          showSimpleSnackBar(context, successMessage!);
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _mapFirebaseAuthErrorCode(context, e.code);
      });
    }
  }

  void _mapFirebaseAuthErrorCode(BuildContext context, String code) {
    switch (code) {
      case 'network-request-failed':
        showSimpleSnackBar(context, 'Conexión falló');
      case 'too-many-requests':
        showSimpleSnackBar(context, 'Demasiadas peticiones');
      case 'wrong-password':
        showSimpleSnackBar(context, 'Contraseña actual incorrecta');
      case 'invalid-credential':
        showSimpleSnackBar(context, 'Contraseña actual incorrecta');
      default:
        showSimpleSnackBar(context, 'Error inesperado');
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

  Widget buildTextField(
      {required TextEditingController controller,
      required String labelText,
      bool isPassword = false,
      String? errorText,
      String? fieldType,
      bool read = false}) {
    return TextFormField(
      controller: controller,
      readOnly: read,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingresa un valor';
        }
        switch (fieldType) {
          case 'user':
            {
              if (value.length < 3) {
                return 'nombre de usuario demasiado corto';
              } else if (value.length > 12) {
                return 'nombre de usuario demasiado largo';
              }
            }
            break;
          case 'email':
            {
              if (!EmailValidator.validate(value)) {
                return 'correo electrónico invalido';
              }
            }
            break;
          case 'password':
            {
              if (value.length < 6) {
                return '6 caracteres requeridos';
              }
            }
            break;
          default:
            break;
        }
        return null;
      },
      onChanged: (value) {
        setState(() {});
      },
      obscureText: isPassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelStyle: const TextStyle(fontSize: 20),
        labelText: labelText,
        errorText: errorText,
      ),
      style: const TextStyle(fontSize: 20),
    );
  }

  @override
  void initState() {
    super.initState();
    _firestoreService = DatabaseService(uid: user!.uid);
    fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Cuenta"),
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.grey,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        leading: IconButton(
          icon: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2)),
              child: const Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 0, 0, 0),
              )),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02, horizontal: screenWidth * 0.03),
          child: Form(
            key: _formKey,
            child: Column(children: [
              Flexible(
                flex: 2,
                child: widget.gestureImage,
              ),
              Flexible(
                  flex: 1,
                  child: buildTextField(
                      controller: controlleruser,
                      labelText: "Usuario",
                      fieldType: "user",
                      read: true)),
              Flexible(
                  flex: 1,
                  child: buildTextField(
                      controller: controllerEmail,
                      labelText: "Correo electrónico",
                      fieldType: "email",
                      read: true)),
              Flexible(
                  flex: 1,
                  child: buildTextField(
                      controller: controllerPass,
                      labelText: "Contraseña actual",
                      isPassword: true,
                      fieldType: "password")),
              Flexible(
                  flex: 1,
                  child: buildTextField(
                      controller: controllerPassNew,
                      labelText: "Contraseña nueva",
                      isPassword: true,
                      fieldType: "password")),
              SizedBox(height: screenHeight * 0.02),
              Flexible(flex: 1, child: _buttomUpdate()),
            ]),
          )),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }
}
