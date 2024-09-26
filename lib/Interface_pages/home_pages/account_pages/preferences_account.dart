import 'package:eatsily/constants/constants.dart';
import 'package:flutter/material.dart';

class PreferencesAccount extends StatefulWidget {
  const PreferencesAccount({super.key});

  @override
  @override
  State<PreferencesAccount> createState() => PreferencesAccountState();
}

class PreferencesAccountState extends State<PreferencesAccount> {
  List<String> preferences = [
    'Opción 1',
    'Opción 2',
    'Opción 3',
    'Opción 4',
    'Opción 5',
  ];

  String searchQuery = '';

  Map<String, bool> selectedPreferences = {};

  @override
  void initState() {
    super.initState();
    for (var preference in preferences) {
      selectedPreferences[preference] = false;
    }
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  List<String> filteredPreferences() {
    if (searchQuery.isEmpty) {
      return preferences;
    } else {
      return preferences
          .where(
              (pref) => pref.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
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
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: updateSearchQuery,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: filteredPreferences().map((preference) {
                  return CheckboxListTile(
                    title: Text(preference),
                    value: selectedPreferences[preference],
                    onChanged: (bool? newValue) {
                      setState(() {
                        selectedPreferences[preference] = newValue!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Text(
                      'Preferencias seleccionadas: ${selectedPreferences.toString()}');
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
