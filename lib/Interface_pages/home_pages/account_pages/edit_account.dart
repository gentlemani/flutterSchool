import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditAccount extends StatefulWidget {
  final Widget gestureImage;
  const EditAccount({super.key, required this.gestureImage});

  @override
  State<EditAccount> createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  final TextEditingController controlleruser = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPass = TextEditingController();
  final TextEditingController controllerPassNew = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  Future<String?> getUserName() async {
    // Obtén el usuario actual
    if (user == null) {
      return null; // Si el usuario no está autenticado, retorna null
    }

    // Obtiene el documento del usuario en la colección "Users"
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user?.uid)
        .get();
    if (userDoc.exists) {
      // Retorna el campo "name" del documento si existe
      return userDoc.get('name');
    } else {
      return null; // Retorna null si el documento no existe
    } // Retorna null si el usuario no está autenticado o no tiene un nombre registrado
  }

  Future<void> fetchUserName() async {
    String? name = await getUserName();
    setState(() {
      controlleruser.text = name ?? '';
      controllerEmail.text = user?.email ?? '';
    });
  }

  Widget _buttomUpdate() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(minimumSize: const Size(250, 50)),
      child: const Text(
        "Actualizar datos",
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget buildTextField(
      {required TextEditingController controller,
      required String labelText,
      bool isPassword = false,
      String? errorText}) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingresa un valor';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          // Maneja la lógica de error específico aquí
        });
      },
      obscureText: isPassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelStyle: const TextStyle(fontSize: 20),
        labelText: labelText,
        errorText: errorText,
      ),
      style: const TextStyle(fontSize: 20),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Cuenta"),
        backgroundColor: Colors.white,
        elevation: 10,
        shadowColor: Colors.grey,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        leading: IconButton(
          icon: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2)),
              child: const Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 0, 0, 0),
              )),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02, horizontal: screenWidth * 0.03),
        child: Column(children: [
          Flexible(
            flex: 2,
            child: widget.gestureImage,
          ),
          Flexible(
              flex: 1,
              child: buildTextField(
                  controller: controlleruser, labelText: "Usuario")),
          Flexible(
              flex: 1,
              child: buildTextField(
                  controller: controllerEmail,
                  labelText: "Correo electrónico")),
          Flexible(
              flex: 1,
              child: buildTextField(
                  controller: controllerPass,
                  labelText: "Contraseña actual",
                  isPassword: true)),
          Flexible(
              flex: 1,
              child: buildTextField(
                  controller: controllerPassNew,
                  labelText: "Contraseña nueva",
                  isPassword: true)),
          SizedBox(height: screenHeight * 0.02),
          Flexible(flex: 1, child: _buttomUpdate())
        ]),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }
}
