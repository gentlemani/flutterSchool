import 'package:flutter/material.dart';
class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: const Key('register'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 217, 210, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(200.0),
          side: const BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
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
}
