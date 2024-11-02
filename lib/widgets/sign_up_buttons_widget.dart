// buttons.dart
import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20),
        backgroundColor: const Color.fromARGB(255, 217, 210, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(200.0),
          side: const BorderSide(color: Colors.white),
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
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class LinkLogin extends StatelessWidget {
  const LinkLogin({super.key});

  @override
  Widget build(BuildContext context) {
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
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
