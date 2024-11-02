import 'package:flutter/material.dart';

class PasswordResetText extends StatelessWidget {
  final VoidCallback onPressed;

  const PasswordResetText({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: const Text(
        '¿Contraseña olvidada?',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }
}
