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
  String? errorMessage;

  Widget userData(TextEditingController controller) {
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
          if (value.isEmpty) {
            errorMessage = 'El campo no puede estar vacío';
          } else {
            errorMessage = null;
          }
        });
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelStyle: const TextStyle(fontSize: 25),
        labelText: "Usuario",
        errorText: errorMessage,
      ),
      style: const TextStyle(fontSize: 25),
    );
  }

  Widget userEmail(TextEditingController controller, String? userEmail) {
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
          if (value.isEmpty) {
            errorMessage = 'El campo no puede estar vacío';
          } else {
            errorMessage = null; // Elimina el mensaje de error si está correcto
          }
        });
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelStyle: const TextStyle(fontSize: 25),
        labelText: '$userEmail',
        errorText: errorMessage,
      ),
      style: const TextStyle(fontSize: 25),
    );
  }

  Widget userPassword(TextEditingController controller) {
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
          if (value.isEmpty) {
            errorMessage = 'El campo no puede estar vacío';
          } else {
            errorMessage = null;
          }
        });
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelStyle: const TextStyle(fontSize: 25),
        labelText: 'Contraseña',
        errorText: errorMessage,
      ),
      style: const TextStyle(fontSize: 25),
    );
  }

  Widget _buttomCambiar() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(minimumSize: const Size(250, 50)),
      child: const Text(
        "Actualizar datos",
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
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
          widget.gestureImage,
          SizedBox(height: screenHeight * 0.02),
          Flexible(flex: 1, child: userData(controlleruser)),
          SizedBox(height: screenHeight * 0.02),
          Flexible(flex: 1, child: userEmail(controllerEmail, user?.email)),
          SizedBox(height: screenHeight * 0.02),
          Flexible(flex: 1, child: userPassword(controllerPass)),
          SizedBox(height: screenHeight * 0.02),
          Flexible(flex: 1, child: _buttomCambiar())
        ]),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }
}
