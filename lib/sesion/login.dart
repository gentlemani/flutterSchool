import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(45.0),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 10.0)),
            child: const Scaffold(
                backgroundColor: Color.fromARGB(224, 246, 246, 246),
                body: SingleChildScrollView(
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 100, horizontal: 50),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Registrate',
                              style: TextStyle(fontSize: 30),
                            ),
                            TextField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                labelText: 'Usuario',
                                contentPadding: EdgeInsets.only(top: 30),
                                labelStyle: TextStyle(
                                    fontSize: 25, color: Colors.black),
                              ),
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                            TextField(
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  labelText: 'Contraseña',
                                  contentPadding: EdgeInsets.only(top: 30),
                                  labelStyle: TextStyle(
                                      fontSize: 25, color: Colors.black),
                                ),
                                style: TextStyle(fontSize: 25),
                                obscureText: true),
                            TextField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                labelText: 'Correo electronico',
                                contentPadding: EdgeInsets.only(top: 30),
                                labelStyle: TextStyle(
                                    fontSize: 25, color: Colors.black),
                              ),
                              style: TextStyle(fontSize: 25),
                            ),
                            SizedBox(
                              height: 70,
                            ),
                            OutlinedButton(
                                onPressed: null,
                                style: ButtonStyle(
                                    textStyle: MaterialStatePropertyAll(
                                        TextStyle(fontSize: 20)),
                                    backgroundColor: MaterialStatePropertyAll(
                                        Color.fromARGB(255, 7, 82, 132))),
                                child: Text(
                                  'Registrar',
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                )),
                          ],
                        ))))));
  }
}
