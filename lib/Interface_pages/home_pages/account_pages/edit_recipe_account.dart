import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsily/Interface_pages/home_pages/account_pages/ingredient.dart';
import 'package:eatsily/Interface_pages/home_pages/account_pages/search_ingredient_delegate.dart';
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
  final TextEditingController _title =
      TextEditingController(text: "Ingresa un nombre para tu receta");
  final FocusNode _focusNodeTitle = FocusNode();
  File? _imageFile;
  final picker = ImagePicker();
  List<String> _filteredIngredients = [];
  List<Map<String, dynamic>> selectedIngredients = [];
  List<String> recipeSteps = [];
  int step = 1;

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
                    // Mostrar un mensaje de error si la cantidad está vacía
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, ingrese una cantidad'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (existingIngredient.isNotEmpty) {
                    // Si el ingrediente ya existía, modificar sus valores
                    existingIngredient['quantity'] = quantityController.text;
                    existingIngredient['unit'] = selectedUnit;
                  } else {
                    // Si no existe, añadirlo a la lista
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

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _fetchIngredients() async {
    List<String> ingredientsList = [];
    final snapshot =
        await FirebaseFirestore.instance.collection('Ingredients').get();

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

  Future<void> uploadRecipe(String imageUrl) async {
    // Crear un nuevo documento en la colección "Recetas"
    try {
      await _firestore.collection('Prueba').add({
        'name': _title.text,
        //'ingredients': _ingredientsController.text
        //.split(','), // Separar ingredientes por coma
        //'description': _body.text,
        'image': imageUrl,
        'likes': 0, // Valor inicial para likes
        'dislikes': 0, // Valor inicial para dislikes
      });
      // Limpiar los campos después de subir
      _title.clear();
      //_ingredientsController.clear();
      //_body.clear();
      _imageFile = null;
    } catch (e) {
      rethrow;
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
            : const Center(
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    step = 1;
    _fetchIngredients();
    _focusNodeTitle.addListener(() {
      if (!_focusNodeTitle.hasFocus && _title.text.isEmpty) {
        setState(() {
          _title.text = 'Ingresa un nombre para tu receta';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleTextStyle: headingTextStyle,
          title: const Text("Crea tu receta"),
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
                          Text(
                            "Nombre",
                            style: bodyTextStyle,
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _title,
                            focusNode: _focusNodeTitle,
                            style: instrucctionTextStyle,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder()),
                            onTap: () {
                              if (_title.text ==
                                  "Ingresa un nombre para tu receta") {
                                _title.clear();
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          Text(
                            "Imagen",
                            style: bodyTextStyle,
                          ),
                          const SizedBox(height: 18),
                          _gestureImage(),
                          const SizedBox(height: 18),
                          Text(
                            "Pasos",
                            style: bodyTextStyle,
                          ),
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
                                  Text(
                                    "Agregar paso",
                                    style: instrucctionTextStyle,
                                  ),
                                  // Mostrar los pasos con opción de editar y eliminar
                                  ...recipeSteps.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    String step = entry.value;

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              await _editStep(index, step);
                                            },
                                            child: Text(step),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () async {
                                            await _editStep(index,
                                                step); // Función para editar el paso
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              recipeSteps.removeAt(
                                                  index); // Eliminar paso
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  })
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            "Ingredientes",
                            style: bodyTextStyle,
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            style: instrucctionTextStyle,
                            readOnly: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Agregar ingredientes',
                            ),
                            onTap: () async {
                              List<Ingredient> ingredientsObjects =
                                  _filteredIngredients
                                      .map((name) => Ingredient(name))
                                      .toList();
                              Ingredient? selectedIngredient = await showSearch(
                                  context: context,
                                  delegate: SearchIngredientDelegate(
                                      ingredientsObjects));

                              if (selectedIngredient != null) {
                                await _showQuantityDialog(
                                    selectedIngredient.name);
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildSelectedIngredients(),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(18),
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (_imageFile != null) {
                            String imageUrl = await uploadRecipeImage(
                                _imageFile!, _title.text);
                            await uploadRecipe(imageUrl);
                          } else {
                            Text(
                              'Por favor selecciona una imagen.',
                              style: instrucctionTextStyle,
                            );
                          }
                        },
                        child: Text(
                          "Subir receta",
                          style: buttomTextStyle,
                        )))
              ],
            ),
          ],
        ),
        backgroundColor: colorWhite);
  }
}
