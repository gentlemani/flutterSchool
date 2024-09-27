import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eatsily/constants/constants.dart';

class PreferencesAccount extends StatefulWidget {
  const PreferencesAccount({super.key});

  @override
  State<PreferencesAccount> createState() => PreferencesAccountState();
}

class PreferencesAccountState extends State<PreferencesAccount> {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> preferences = [
    'Omnívoro',
    'Vegano',
    'Vegetariano',
    'Flexitariana',
    'Pescetariana',
    'Ovo-lacto Vegetariana',
    'Carnívora'
  ];

  // Información de cada preferencia
  Map<String, String> preferenceInfo = {
    'Omnívoro':
        'La dieta omnívora incluye tanto alimentos de origen vegetal como de origen animal. Es la más amplia y variada de todas, ya que permite el consumo de todos los grupos de alimentos.',
    'Vegano':
        'La dieta vegana excluye completamente cualquier producto de origen animal, enfocándose solo en alimentos de origen vegetal.',
    'Vegetariano':
        'La dieta vegetariana excluye carnes y pescados, pero permite algunos productos animales, como los lácteos y los huevos.',
    'Flexitariana':
        'Es una dieta vegetariana flexible que permite el consumo ocasional de carne o pescado. Se enfoca mayormente en alimentos vegetales, pero sin excluir completamente los productos animales.',
    'Pescetariana':
        'Esta dieta es similar a la vegetariana, pero incluye pescado y mariscos.',
    'Ovo-lacto Vegetariana':
        'Es una variante del vegetarianismo que incluye productos lácteos y huevos, pero excluye la carne y el pescado.',
    'Carnívora':
        'La dieta carnívora se enfoca exclusivamente en alimentos de origen animal, excluyendo completamente los vegetales.'
  };

  String? selectedPreference;

  void showPreferenceInfo(String preference) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(preference),
          content:
              Text(preferenceInfo[preference] ?? 'Información no disponible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUserPreferences(String userId) async {
    // Estructura para almacenar los cambios a realizar en Firestore
    List<String> allCategories = [
      'Azúcares_y_dulces',
      'Carnes_pescado_y_huevos',
      'Cereales_y_tuberculos',
      'Condimentos_y_salsas',
      'Frutas',
      'Grasas_y_aceites',
      'Lacteos',
      'Legumbres_y_frutos_secos',
      'Verduras_y_hortalizas'
    ];

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      Map<String, dynamic> resetValues = {};
      for (String category in allCategories) {
        if (userData[category] == -1) {
          resetValues[category] = 0;
        }
      }

      if (resetValues.isNotEmpty) {
        // Actualizar categorías que estaban en -1 a 0
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .update(resetValues);
      }
    }

    Map<String, dynamic> updatedValues = {
      'foodPreferences':
          selectedPreference, // Guardar la preferencia en el campo 'foodPreferences'
    };

    switch (selectedPreference) {
      case 'Omnívoro':
        break;
      case 'Vegano':
        updatedValues
            .addAll({'Azúcares_y_dulces': -1, 'Carnes_pescado_y_huevos': -1});
        break;
      case 'Vegetariano':
        updatedValues
            .addAll({'Azúcares_y_dulces': -1, 'Carnes_pescado_y_huevos': -1});
        break;
      case 'Flexitariana':
        break;
      case 'Pescetariana':
        updatedValues.addAll({'Azúcares_y_dulces': -1});
        break;
      case 'Ovo-lacto Vegetariana':
        updatedValues.addAll({'Azúcares_y_dulces': -11});
        break;
      case 'Carnívora':
        updatedValues.addAll({
          'Azúcares_y_dulces': -1,
          'Cereales_y_tuberculos': -1,
          'Condimentos_y_salsas': -1,
          'Frutas': -1,
          'Grasas_y_aceites': -1,
          'Lacteos': -1,
          'Legumbres_y_frutos_secos': -1,
          'Verduras_y_hortalizas': -1
        });
        break;
    }

    // Actualizar Firestore con los valores modificados
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update(updatedValues);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferencias guardadas correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar las preferencias')),
        );
      }
    }
  }

  Future<void> loadUserPreferences(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String userPreference =
          userData['foodPreferences'] ?? 'Omnívoro'; // Default value

      setState(() {
        selectedPreference = userPreference;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserPreferences(user!.uid); // Cargar preferencias guardadas al iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preferencias Alimentarias',
          style: headingTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: preferences.map((preference) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 152, 102, 102)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RadioListTile<String>(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(preference),
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              showPreferenceInfo(preference);
                            },
                          ),
                        ],
                      ),
                      value: preference,
                      groupValue: selectedPreference,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPreference = newValue;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedPreference != null) {
                    updateUserPreferences(user!.uid);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selecciona una preferencia'),
                      ),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
