import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => FirstPageState();
}

class FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('c'),
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.star_border_sharp), label: 'Mejores\nplatillos'),
        BottomNavigationBarItem(
            icon: Icon(Icons.soup_kitchen_sharp), label: 'Cocina'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), label: 'Perfil'),
      ]),
    );
  }
}

void main() {}
