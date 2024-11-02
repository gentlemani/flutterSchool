import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SubmitButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: const Key('submit'),
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
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text(
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
}

