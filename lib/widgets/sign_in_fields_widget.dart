import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class EntryEmailField extends StatelessWidget {
  final TextEditingController controller;

  const EntryEmailField({super.key,required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (email) {
        if (email == null || email.isEmpty) return 'Por favor, ingresa tu correo';
        if (!EmailValidator.validate(email)) return 'Ingresa un correo válido';
        return null;
      },
      decoration: const InputDecoration(
        alignLabelWithHint: true,
        labelText: 'Correo electronico',
        contentPadding: EdgeInsets.only(top: 30),
        labelStyle: TextStyle(fontSize: 25, color: Colors.white),
      ),
      style: const TextStyle(
          fontSize: 25, color: Color.fromARGB(255, 255, 255, 255))
    );
  }
}

class EntryPasswordField extends StatelessWidget {
  final TextEditingController controller;

  const EntryPasswordField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: const InputDecoration(
        alignLabelWithHint: true,
        labelText: 'Contraseña',
        contentPadding: EdgeInsets.only(top: 30),
        labelStyle: TextStyle(fontSize: 25, color: Colors.white),
      ),
      style: const TextStyle(
            fontSize: 25, color: Color.fromARGB(255, 255, 255, 255))
    );
  }
}
