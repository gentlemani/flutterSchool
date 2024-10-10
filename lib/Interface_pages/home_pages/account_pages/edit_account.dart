import 'dart:async';
import 'package:eatsily/common_widgets/seasonal_background.dart';
import 'package:eatsily/sesion/services/database.dart';
import 'package:eatsily/utils/auth.helpers.dart';
import 'package:eatsily/widget_tree.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eatsily/constants/constants.dart';

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

  Widget _buttonUpdateAll() {
    return ElevatedButton(
      onPressed: () async {
        bool isValid = true;

        // Variables for fields to update
        String? newUsername;
        String? newEmail;
        String? newPassword;

        if (controlleruser.text.trim() !=
            (await _firestoreService.getUserName())) {
          final usernameError = validateFields(controlleruser.text, 'user');
          if (usernameError != null) {
            if (mounted) {
              showSimpleSnackBar(context, usernameError);
              isValid = false;
            }
          } else {
            newUsername = controlleruser.text;
          }
        }

        if (controllerPass.text.isNotEmpty ||
            controllerPassNew.text.isNotEmpty) {
          final currentPasswordError =
              validateFields(controllerPass.text, 'password');
          final newPasswordError =
              validateFields(controllerPassNew.text, 'passwordNew');
          if (currentPasswordError != null) {
            if (mounted) {
              showSimpleSnackBar(context, currentPasswordError);
              isValid = false;
            }
          }
          if (newPasswordError != null) {
            if (mounted) {
              showSimpleSnackBar(context, newPasswordError);
              isValid = false;
            }
          }
          if (isValid) {
            newPassword = controllerPassNew.text;
          }
        }

        if (controllerEmail.text.trim() != user?.email) {
          final emailError = validateFields(controllerEmail.text, 'email');
          if (emailError != null) {
            if (mounted) {
              showSimpleSnackBar(context, emailError);
              isValid = false;
            }
          } else {
            newEmail = controllerEmail.text;
          }
        }

        if (isValid) {
          // Update only the fields that must be updated
          await updateAllFields(newUsername, newEmail, newPassword);
        }
      },
      style: ElevatedButton.styleFrom(
          minimumSize: const Size(250, 50),
          backgroundColor: colorYellowOrange,
          side: const BorderSide(
              width: 1, color: colorBlack, style: BorderStyle.solid)),
      child: Text(
        "Actualizar cuenta",
        style: buttomTextStyle,
      ),
    );
  }

  Future<void> updateAllFields(
      String? newUsername, String? newEmail, String? newPassword) async {
    if (newUsername != null &&
        newUsername != (await _firestoreService.getUserName())) {
      await _firestoreService.updateUserName(newUsername);
      if (mounted) {
        showSimpleSnackBar(context, 'Nombre de usuario actualizado');
      }
    }
    if (newPassword != null) {
      await updatePassword();
    }
    if (newEmail != null && newEmail != user?.email) {
      try {
        await user?.verifyBeforeUpdateEmail(newEmail);
        if (mounted) {
          showSimpleSnackBar(
              context, 'Correo de verificación enviado a $newEmail');
          showVerificationDialog();
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          _mapFirebaseAuthErrorCode(context, e.code);
        }
      }
    }
  }

  String? validateFields(String? value, String fieldType) {
    if (fieldType == 'user') {
      if (value == null || value.isEmpty) {
        return 'Por favor ingresa un nombre de usuario';
      } else if (value.length < 3) {
        return 'Nombre de usuario demasiado corto';
      } else if (value.length > 12) {
        return 'Nombre de usuario demasiado largo';
      }
    } else if (fieldType == 'passwordNew') {
      if (value == null || value.isEmpty) {
        return 'Por favor ingresa una contraseña';
      }
      if (value.length < 6) {
        return 'Se requieren al menos 6 caracteres';
      }
      if (!value.contains(RegExp(r'[A-Za-z]'))) {
        return 'La contraseña debe contener al menos una letra';
      }
      if (!value.contains(RegExp(r'\d'))) {
        return 'La contraseña debe contener al menos un número';
      }
      const specialCharacters = '!@#\$%^&*(),.?":{}|<>+-';
      bool hasSpecialCharacter =
          value.split('').any((char) => specialCharacters.contains(char));
      if (!hasSpecialCharacter) {
        return 'La contraseña debe contener al menos un carácter especial';
      }
    } else if (fieldType == 'email') {
      if (value == null || value.isEmpty) {
        return 'Por favor ingresa un correo electrónico';
      } else if (!EmailValidator.validate(value)) {
        return 'Correo electrónico inválido';
      }
    } else if (fieldType == 'password') {
      if (value == null || value.isEmpty) {
        return 'Por favor ingresa tu contraseña';
      }
    }
    return null;
  }

  void showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // It does not allow closing the dialog without verifying
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Verificación de Correo',
          style: headingTextStyle,
        ),
        content: Text(
          'Hemos enviado un correo de verificación a tu nueva dirección de correo. Por favor, verifica tu correo se le redireccionara al inicio de sesión.',
          style: bodyTextStyle,
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); //Close the dialog box and close session
                handleLogout(context, redirectTo: const WidgetTree());
              },
              child: Text(
                "OK",
                style: bodyTextStyle,
              ))
        ],
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
        if (mounted) {
          successMessage = 'Contraseña actualizada con extito';
          showSimpleSnackBar(context, successMessage!);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _mapFirebaseAuthErrorCode(context, e.code);
      }
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
            const Duration(seconds: 3), // Display the snack bar for 3 seconds
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool isPassword = false,
    String? errorText,
    String? fieldType,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) => validateFields(value, fieldType ?? ''),
      obscureText: isPassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelStyle: instrucctionTextStyle,
        labelText: labelText,
        errorText: errorText,
      ),
      style: bodyTextStyle,
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
        title: Text("Editar Cuenta", style: headingTextStyle),
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
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        SeasonalBackground(),
        Padding(
            padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02, horizontal: screenWidth * 0.06),
            child: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          widget.gestureImage,
                          SizedBox(height: screenHeight * 0.02),
                          buildTextField(
                            controller: controlleruser,
                            labelText: "Usuario",
                            fieldType: "user",
                          ),
                          buildTextField(
                            controller: controllerEmail,
                            labelText: "Correo electrónico",
                            fieldType: "email",
                          ),
                          buildTextField(
                              controller: controllerPass,
                              labelText: "Contraseña actual",
                              isPassword: true,
                              fieldType: "password"),
                          buildTextField(
                              controller: controllerPassNew,
                              labelText: "Contraseña nueva",
                              isPassword: true,
                              fieldType: "passwordNew"),
                          SizedBox(height: screenHeight * 0.02),
                          _buttonUpdateAll(),
                        ]),
                  )),
            ))
      ]),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }
}
