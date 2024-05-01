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
        Auth auth = Auth();
        auth.signOut(); // Cerrar sesión si el usuario confirma
        Navigator.pop(context);
      }
    });
  }

/*     |---------------|
       |    Buttons    |
       |---------------|
*/

  Widget _buttom(BuildContext context) {
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Perfil',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                iconSize: 30,
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Handle edit button press
                },
              ),
              IconButton(
                iconSize: 30,
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Handle settings button press
                },
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.only(top: 40),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                GestureDetector(
                  onTap: getImage,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : const AssetImage('assets/iconoP.png')
                            as ImageProvider<Object>?,
                  ),
                ),
                const SizedBox(height: 450), // Adjust spacing as needed
                _buttom(context), // Assuming this is a custom function/widget
              ],
            ),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
