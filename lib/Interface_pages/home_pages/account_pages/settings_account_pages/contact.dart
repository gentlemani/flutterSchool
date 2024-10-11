import 'package:eatsily/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  ContactState createState() => ContactState();
}

class ContactState extends State<Contact> {
  Widget _buildContactInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText(
          'Para consultas, envía un correo a: fluttermodular21@outlook.com\n\n'
          'Asunto: Consulta desde la app\n\n'
          'Mensaje:\n'
          'Hola,\n'
          'Me gustaría hacer la siguiente consulta:\n'
          '_____________________________________\n'
          'Escribe aquí tu mensaje...',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contactar a los Desarrolladores'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para contactarnos, copia y pega la siguiente información en tu cliente de correo:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              _buildContactInfo(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                          text:
                              'Para consultas, envía un correo a: fluttermodular21@outlook.com\n\n'
                              'Asunto: Consulta desde la app\n\n'
                              'Mensaje:\n'
                              'Hola,\n'
                              'Me gustaría hacer la siguiente consulta:\n'
                              '_____________________________________\n'
                              'Escribe aquí tu mensaje...'),
                    ).then((_) {});
                  },
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: colorYellowOrange),
                  child: Text(
                    ' Copiar Información ',
                    style: buttomTextStyle,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
