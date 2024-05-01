import 'dart:io';
import 'package:eatsily/sesion/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eatsily/auth.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
/*     |-----------------|
       |    Variables    |
       |-----------------|
*/

  File? _imageFile;
  final picker = ImagePicker();

/*     |----------------|
       |    Functions   |
       |----------------|
*/

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(
                    false); // Cerrar el cuadro de diálogo sin cerrar sesión
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Cerrar el cuadro de diálogo y cerrar sesión
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        signOut(); // Cerrar sesión si el usuario confirma
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const SignInPage()));
      }
    });
  }

/*     |---------------|
       |    Buttons    |
       |---------------|
*/

  Widget _button(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        _showLogoutDialog(context);
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

/*     |----------------------------------------------|
       |          Main interface construction         |
       |----------------------------------------------|
*/

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
              const Expanded(
                child: SizedBox(), // Use Expanded to occupy remaining space
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 100), // Adjust bottom padding
                child: _button(context), // Place the button at the bottom
              ),
            ])),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
    ));
  }
}
