import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
                body: Container(
                  padding: const EdgeInsets.only(top: 40),
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
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
                ),
                backgroundColor: const Color.fromARGB(255, 255, 255, 255))));
  }
}
