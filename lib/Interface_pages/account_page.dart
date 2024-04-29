import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eatsily/auth.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _imageFile;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Widget _buttom() {
    return FloatingActionButton.extended(
      onPressed: () async {
        Auth auth = Auth();
        await auth.signOut();
        Navigator.pop(context);
      },
      backgroundColor: const Color.fromARGB(255, 200, 4, 34),
      icon: const Icon(
        Icons.logout,
        color: Colors.white,
      ),
      label: const Text('Cerrar sesión',
          style: TextStyle(fontSize: 20, color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        child: Container(
      padding: const EdgeInsets.all(0),
      child: Scaffold(
        appBar: AppBar(
          titleTextStyle: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
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
            const SizedBox(
              height: 50,
            ),
          ],
        ),
        body: Container(
            padding: const EdgeInsets.only(top: 40),
            alignment: Alignment.topCenter,
            child: Column(children: [
              GestureDetector(
                onTap: () {
                  getImage();
                },
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : const AssetImage('assets/iconoP.png') as ImageProvider<
                          Object>?, // Imagen predeterminada si no hay ninguna seleccionada
                ),
              ),
              const SizedBox(
                height: 450,
              ),
              _buttom()
            ])),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
    ));
  }
}
