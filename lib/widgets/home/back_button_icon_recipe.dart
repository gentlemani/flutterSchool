import 'package:flutter/material.dart';

class BackButtonIconRecipe extends StatelessWidget {
  final VoidCallback onPressed;

  const BackButtonIconRecipe({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        decoration: _backButtonDecoration(),
        child: const Icon(
          Icons.arrow_back,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      onPressed: onPressed,
    );
  }

  BoxDecoration _backButtonDecoration() {
    return BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black, width: 2),
    );
  }
}
