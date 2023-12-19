import 'package:flutter/material.dart';

class Fondo extends StatelessWidget {
  const Fondo({super.key});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(0.0),
        child: Container(
          decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/Fondo4.jpg'),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: Colors.black,
                width: 5.0,
              )),
        ));
  }
}
