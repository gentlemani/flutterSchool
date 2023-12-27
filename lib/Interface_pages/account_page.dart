import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        child: Container(
            padding: const EdgeInsets.all(2),
            child: Scaffold(
              appBar: AppBar(
                title: const Center(child: Text('Bienvenido a la')),
              ),
              body: const Center(child: Text('d')),
              backgroundColor: const Color.fromARGB(255, 54, 114, 244),
            )));
  }
}
