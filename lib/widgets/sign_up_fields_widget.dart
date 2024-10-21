// text_fields.dart
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class UserNameField extends StatelessWidget {
  final TextEditingController controller;

  const UserNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
        labelStyle: TextStyle(fontSize: 25, color: Colors.white),
      ),
      style: const TextStyle(fontSize: 25, color: Colors.white),
    );
  }
}

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String?)? onChanged;

  const EmailField({Key? key, required this.controller, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      onChanged: onChanged,
      decoration: const InputDecoration(
        alignLabelWithHint: true,
        labelText: 'Correo electronico',
        contentPadding: EdgeInsets.only(top: 30),
        labelStyle: TextStyle(fontSize: 25, color: Colors.white),
      ),
      style: const TextStyle(fontSize: 25, color: Colors.white),
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String?)? onChanged;

  const PasswordField({Key? key, required this.controller, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (passwd) {
        if (passwd == null || passwd.isEmpty) {
          return 'Por favor, ingresa una contraseña';
        }
        if (passwd.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        if (!passwd.contains(RegExp(r'[A-Z]'))) {
          return 'La contraseña debe contener al menos una letra mayúscula';
        }
        if (!passwd.contains(RegExp(r'[0-9]'))) {
          return 'La contraseña debe contener al menos un número';
        }
        if (!passwd.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>+-]'))) {
          return 'La contraseña debe contener al menos un carácter especial';
        }
        return null;
      },
      onChanged: onChanged,
      decoration: const InputDecoration(
        alignLabelWithHint: true,
        labelText: 'Contraseña',
        contentPadding: EdgeInsets.only(top: 30),
        labelStyle: TextStyle(fontSize: 25, color: Colors.white),
      ),
      style: const TextStyle(fontSize: 25, color: Colors.white),
      obscureText: true,
    );
  }
}
