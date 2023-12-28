import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        child: Container(
            padding: const EdgeInsets.all(0),
            child: Scaffold(
                appBar: AppBar(
                  titleTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  title: const Text('Perfil'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      iconSize: 30,
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Acción al presionar el botón
                      },
                    ),
                    IconButton(
                      iconSize: 30,
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        // Otra acción
                      },
                    ),
                  ],
                ),
                body: const Column(),
                backgroundColor: const Color.fromARGB(255, 255, 255, 255))));
  }
}
