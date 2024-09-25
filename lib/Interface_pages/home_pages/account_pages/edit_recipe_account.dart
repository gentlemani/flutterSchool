import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsily/common_widgets/seasonal_background.dart';
import 'package:eatsily/constants/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditRecipeAccount extends StatefulWidget {
  final String recipeId; // ID de la receta que se va a editar

  const EditRecipeAccount({required this.recipeId, super.key});

  @override
  State<EditRecipeAccount> createState() => _EditRecipeAccountState();
}

class _EditRecipeAccountState extends State<EditRecipeAccount> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _title = TextEditingController();
  final FocusNode _focusNodeTitle = FocusNode();
  File? _imageFile;
  final picker = ImagePicker();
  List<String> _filteredIngredients = [];
  List<Map<String, dynamic>> selectedIngredients = [];
  List<String> recipeSteps = [];
  int step = 1;
  String? imageUrl;

  Future<void> _fetchIngredients() async {
    List<String> ingredientsList = [];
    try {
      final snapshot = await _firestore.collection('Ingredients').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['Ingredientes'] != null && data['Ingredientes'] is List) {
          for (var ingredient in data['Ingredientes']) {
            if (ingredient is String) {
              ingredientsList.add(ingredient.replaceAll('_', ' '));
            }
          }
        }
      }

      setState(() {
        _filteredIngredients = ingredientsList;
      });
    } catch (e) {
      print('Error al obtener los ingredientes: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRecipeData();
    _fetchIngredients();
    _focusNodeTitle.addListener(() {
      if (!_focusNodeTitle.hasFocus && _title.text.isEmpty) {
        setState(() {
          _title.text = 'Ingresa un nombre para tu receta';
        });
      }
    });
  }

  Future<void> _fetchRecipeData() async {
    try {
      DocumentSnapshot recipeSnapshot =
          await _firestore.collection('Recetas').doc(widget.recipeId).get();

      if (recipeSnapshot.exists) {
        Map<String, dynamic> data =
            recipeSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _title.text = data['name'] ?? '';
          recipeSteps = List<String>.from(data['description'] ?? []);
          // Se obtiene la lista de ingredientes
          selectedIngredients =
              List<Map<String, dynamic>>.from(data['ingredients'] ?? []);
          imageUrl = data['image'];
        });
      }
    } catch (e) {
      print('Error al cargar la receta: $e');
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadRecipeImage(File imageFile, String recipeName) async {
    try {
      Reference ref =
          FirebaseStorage.instance.ref().child('Img recetas/$recipeName');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveChanges() async {
    try {
      String? newImageUrl = imageUrl;
      if (_imageFile != null) {
        newImageUrl = await uploadRecipeImage(_imageFile!, _title.text);
      }

      // Actualizar la receta en Firestore
      await _firestore.collection('Recetas').doc(widget.recipeId).update({
        'name': _title.text,
        'ingredients': selectedIngredients,
        'description': recipeSteps,
        'image': newImageUrl ?? imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receta actualizada exitosamente')),
      );
    } catch (e) {
      print('Error al guardar los cambios: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los cambios')),
      );
    }
  }

  Widget _gestureImage() {
    return GestureDetector(
      onTap: () {
        getImage();
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                ),
              )
            : (imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.add,
                      size: 40,
                      color: Colors.grey,
                    ),
                  )),
      ),
    );
  }

  Future<void> _addStep() async {
    TextEditingController stepController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Agregar Paso"),
          content: SizedBox(
              width: double.maxFinite,
              child: TextField(
                controller: stepController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(hintText: "Escribe el paso"),
              )),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Agregar"),
              onPressed: () {
                setState(() {
                  recipeSteps.add("Paso $step - ${stepController.text}");
                  step++;
                });
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editStep(int index, String currentStep) async {
    TextEditingController stepController =
        TextEditingController(text: currentStep);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar Paso"),
          content: TextField(
            controller: stepController,
            maxLines: null, // Permitir múltiples líneas
            decoration: const InputDecoration(hintText: "Escribe el paso"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Guardar"),
              onPressed: () {
                setState(() {
                  recipeSteps[index] =
                      "Paso ${index + 1} - ${stepController.text}";
                });
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showQuantityDialog(String ingredient) async {
    Map<String, dynamic>? existingIngredient = selectedIngredients.firstWhere(
      (ingredientData) => ingredientData['name'] == ingredient,
      orElse: () => <String, dynamic>{},
    );
    TextEditingController quantityController = TextEditingController(
      text: existingIngredient.isNotEmpty ? existingIngredient['quantity'] : '',
    );
    String? selectedUnit = existingIngredient.isNotEmpty
        ? existingIngredient['unit']
        : "gramos"; // Unidad por defecto o la existente
    List<String> units = [
      'gramos',
      'porciones',
      'tazas',
      'ml',
      'cucharadas'
    ]; // Lista de unidades
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cantidad de $ingredient"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Cantidad",
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedUnit,
                decoration: const InputDecoration(
                  labelText: "unidad",
                  border: OutlineInputBorder(),
                ),
                items: units.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnit = newValue;
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  Text(existingIngredient.isNotEmpty ? "Modificar" : "Aceptar"),
              onPressed: () {
                setState(() {
                  if (quantityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, ingrese una cantidad'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (existingIngredient.isNotEmpty) {
                    existingIngredient['quantity'] = quantityController.text;
                    existingIngredient['unit'] = selectedUnit;
                  } else {
                    selectedIngredients.add({
                      'name': ingredient,
                      'quantity': quantityController.text,
                      'unit': selectedUnit,
                    });
                  }
                });
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedIngredients() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: selectedIngredients.map((ingredientData) {
        return GestureDetector(
            onTap: () {
              _showQuantityDialog(ingredientData['name']);
            },
            child: Chip(
              label: Text(
                  style: instrucctionTextStyle,
                  "${ingredientData['name']} - ${ingredientData['quantity']} ${ingredientData['unit']}"),
              onDeleted: () {
                setState(() {
                  selectedIngredients.remove(ingredientData);
                });
              },
            ));
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: headingTextStyle,
        title: const Text("Editar Receta"),
        elevation: 10,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SeasonalBackground(),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 18, right: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nombre", style: bodyTextStyle),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _title,
                          focusNode: _focusNodeTitle,
                          style: instrucctionTextStyle,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 18),
                        Text("Imagen", style: bodyTextStyle),
                        const SizedBox(height: 18),
                        _gestureImage(),
                        const SizedBox(height: 18),
                        Text("Pasos", style: bodyTextStyle),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: _addStep,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Agregar paso",
                                    style: instrucctionTextStyle),
                                ...recipeSteps.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  String step = entry.value;
                                  return ListTile(
                                    title: Text(step),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _editStep(index, step),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text("Ingredientes", style: bodyTextStyle),
                        const SizedBox(height: 18),
                        _buildSelectedIngredients(),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: _saveChanges,
                          child: const Text("Guardar Cambios"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
