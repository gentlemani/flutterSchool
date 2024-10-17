import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsily/Interface_pages/home_pages/account_pages/ingredient.dart';
import 'package:eatsily/Interface_pages/home_pages/account_pages/search_ingredient_delegate.dart';
import 'package:eatsily/common_widgets/seasonal_background.dart';
import 'package:eatsily/constants/constants.dart';
import 'package:eatsily/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eatsily/services/api_service.dart';

class CreateRecipeAccount extends StatefulWidget {
  const CreateRecipeAccount({super.key});

  @override
  State<CreateRecipeAccount> createState() => _CreateRecipeAccountState();
}

class _CreateRecipeAccountState extends State<CreateRecipeAccount> {
  final TextEditingController _title =
      TextEditingController(text: "Ingresa un nombre para tu receta");
  final FocusNode _focusNodeTitle = FocusNode();
  File? _imageFile;
  final picker = ImagePicker();
  List<String> _filteredIngredients = [];
  List<Map<String, dynamic>> selectedIngredients = [];
  List<String> recipeSteps = [];
  int step = 1;
  int counterDiners = 0;
  final ApiService _apiService = ApiService();

  Future<void> _showQuantityDialog(String ingredient) async {
    Map<String, dynamic>? existingIngredient = selectedIngredients.firstWhere(
      (ingredientData) => ingredientData['name'] == ingredient,
      orElse: () => <String, dynamic>{},
    );
    TextEditingController quantityController = TextEditingController(
      text: existingIngredient.isNotEmpty ? existingIngredient['quantity'] : '',
    );

    final Map<String, String> unitMap = {
      'gramo': 'gramos',
      'porción': 'porciones',
      'taza': 'tazas',
      'mililitro': 'mililitros',
      'cucharada': 'cucharadas',
      'paquete': 'paquetes',
      'unidad': 'unidades',
      'loncha': 'lonchas',
      'rama': 'ramas',
      'cucharadita': 'cucharaditas',
      'pizca': 'pizcas',
      'rebanada': 'rebanadas',
    };

    String? getSingularUnit(String unit) {
      // Look for the (singular) key whose (plural) value coincides with `unit`
      String? singular = unitMap.keys.firstWhere(
        (key) =>
            unitMap[key] ==
            unit, // If the value coincides with `Unit`, returns the key
        orElse: () => unit, //If it is not found, it returns `unit` as it is
      );
      return singular;
    }

    String? selectedUnit = existingIngredient.isNotEmpty
        ? getSingularUnit(existingIngredient['unit'])
        : "gramo";

    String pluralizeUnit(String unit, int quantity) {
      return quantity == 1 ? unit : unitMap[unit] ?? unit;
    }

    // List of units
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
                items: unitMap.keys.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unitMap[unit]!),
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
                    // Show an error message if the amount is empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, ingrese una cantidad'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  int quantity = int.parse(quantityController.text);
                  String finalUnit = pluralizeUnit(selectedUnit!, quantity);
                  if (existingIngredient.isNotEmpty) {
                    // If the ingredient already existed, modify its values
                    existingIngredient['quantity'] = quantityController.text;
                    existingIngredient['unit'] = finalUnit;
                  } else {
                    // If it does not exist, add it to the list
                    selectedIngredients.add({
                      'name': ingredient,
                      'quantity': quantityController.text,
                      'unit': finalUnit,
                    });
                  }
                });
                Navigator.of(context).pop();
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
                  String inputText = stepController.text;
                  String cleanedText = inputText.replaceAll(
                      RegExp(r'(Paso\s*\d+\.?\s*)', caseSensitive: false), '');
                  recipeSteps.add("Paso $step. $cleanedText");
                  _renumberSteps();
                });
                Navigator.of(context).pop();
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
            maxLines: null, // Allow multiple lines
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
                  String inputText = stepController.text;
                  String cleanedText = inputText.replaceAll(
                      RegExp(r'(Paso\s*\d+\.?\s*)', caseSensitive: false), '');
                  recipeSteps[index] = "Paso ${index + 1}. $cleanedText";
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createRecipe(File image) async {
    try {
      String? token = await AuthService().getUserToken();
      if (token != null) {
        String recipeDescription = recipeSteps
            .map((step) => step.replaceAll('\n', '').trim())
            .join(" ");

        List<String> newIngredients = selectedIngredients.map((ingredient) {
          return '${ingredient['name'].replaceAll(' ', '_')}';
        }).toList();

        List<String> portions = selectedIngredients.map((ingredientData) {
          return '${ingredientData['quantity']} ${ingredientData['unit']}';
        }).toList();
        _apiService.createRecipe(_title.text, recipeDescription, newIngredients,
            portions, counterDiners.toString(), image, token);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta subida exitosamente')),
        );
      }
      setState(() {
        _title.clear();
        selectedIngredients.clear();
        recipeSteps.clear();
        _imageFile = null;
        counterDiners = 0;
        step = 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la receta: $e')),
        );
      }
    }
  }

  void _deleteStep(int index) {
    setState(() {
      recipeSteps.removeAt(index); // Eliminate the step
      step--; // Decree the steps counter
      _renumberSteps(); // Renumerate all steps after elimination
    });
  }

  //Function to reume all the steps on the list
  void _renumberSteps() {
    for (int i = 0; i < recipeSteps.length; i++) {
      // Renumerate every step
      recipeSteps[i] = "Paso ${i + 1}. ${recipeSteps[i].split('. ')[1]}";
    }
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

  void _incrementCounter() {
    setState(() {
      counterDiners++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (counterDiners > 0) counterDiners--;
    });
  }

  Widget diners() {
    String textDiners;
    if (counterDiners == 1) {
      textDiners = "Comensal";
    } else {
      textDiners = "Comensales";
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: _decrementCounter,
            icon: const Icon(
              Icons.remove_circle_outlined,
              color: Colors.red,
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "$counterDiners $textDiners",
            style: bodyTextStyle,
          ),
        ),
        IconButton(
          onPressed: _incrementCounter,
          icon: const Icon(Icons.add_circle),
          color: colorGreen,
        )
      ],
    );
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
          leading: IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
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
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: colorWhite),
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
                                color: colorWhite,
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
                                  // Show the steps with the option of editing and deleting
                                  ...recipeSteps.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    String steep = entry.value;

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              await _editStep(index, steep);
                                            },
                                            child: Text(steep),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () async {
                                            await _editStep(index,
                                                steep); // Function to edit the step
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              _deleteStep(index);
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
                          diners(),
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
                              filled: true,
                              fillColor: colorWhite,
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
                            // String imageUrl = await uploadRecipeImage(
                            //     _imageFile!, _title.text);
                            createRecipe(_imageFile!);
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Porfavor inserte una imagen')),
                              );
                            }
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
