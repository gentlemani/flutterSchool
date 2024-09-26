import 'package:flutter/material.dart';
import 'package:eatsily/constants/constants.dart';

class PreferencesAccount extends StatefulWidget {
  const PreferencesAccount({super.key});

  @override
  State<PreferencesAccount> createState() => PreferencesAccountState();
}

class PreferencesAccountState extends State<PreferencesAccount> {
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

  Map<String, bool> selectedPreferences = {};

  @override
  void initState() {
    super.initState();
    for (var preference in preferences) {
      selectedPreferences[preference] = false;
    }
  }

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
                    child: CheckboxListTile(
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
                      value: selectedPreferences[preference],
                      onChanged: (bool? newValue) {
                        setState(() {
                          selectedPreferences[preference] = newValue!;
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
                  String selectedPrefs = selectedPreferences.entries
                      .where((entry) => entry.value)
                      .map((entry) => entry.key)
                      .join(', ');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Preferencias seleccionadas: $selectedPrefs'),
                    ),
                  );
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
