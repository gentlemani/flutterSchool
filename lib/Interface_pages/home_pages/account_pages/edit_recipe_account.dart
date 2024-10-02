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
  final String recipeId; // Recipe id that is going to be edited

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
  int counterDiners = 0;
  String? _recipeImageUrl;
  int originalDiners = 1;

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
        : "gramos"; // Default or existing unit
    List<String> units = [
      'gramos',
      'porciones',
      'tazas',
      'mililitros',
      'cucharadas',
      'paquetes',
      'unidades',
      'lonchas',
      'ramas',
      'cucharadtias',
      'pizcas',
      'cantidad al gusto',
      'rebanadas'
    ]; // List of units
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
                    // If the ingredient already existed, modify its values
                    existingIngredient['quantity'] = quantityController.text;
                    existingIngredient['unit'] = selectedUnit;
                  } else {
                    // If do not exist, add it to the list
                    selectedIngredients.add({
                      'name': ingredient,
                      'quantity': quantityController.text,
                      'originalQuantity': quantityController.text,
                      'unit': selectedUnit,
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
                  recipeSteps.add("Paso $step. ${stepController.text}");
                  step++;
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
                  recipeSteps[index] =
                      "Paso ${index + 1}. ${stepController.text}";
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteStep(int index) {
    setState(() {
      recipeSteps.removeAt(index); // Eliminate the step
      step--; // Decree the steps counter
      _renumberSteps(); //Renumerate all steps after elimination
    });
  }

  void _renumberSteps() {
    for (int i = 0; i < recipeSteps.length; i++) {
      // Renumerate every stepep
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

  void _incrementCounter() {
    setState(() {
      counterDiners++;
      _updateIngredientQuantities();
    });
  }

  void _decrementCounter() {
    setState(() {
      if (counterDiners > 1) {
        counterDiners--;
        _updateIngredientQuantities();
      }
    });
  }

  void _updateIngredientQuantities() {
    setState(() {
      for (var ingredient in selectedIngredients) {
        // Update the amount according to the proportion of diners
        double originalQuantity =
            _parseQuantity(ingredient['originalQuantity']);
        double newQuantity =
            (originalQuantity / originalDiners) * counterDiners;
        ingredient['quantity'] = _formatQuantity(newQuantity);
      }
    });
  }

  double _parseQuantity(String quantity) {
    // Handle fractions such as "1/2", "1/4", etc.
    if (quantity.contains('/')) {
      List<String> parts = quantity.split('/');
      return double.parse(parts[0]) / double.parse(parts[1]);
    }
    return double.tryParse(quantity) ?? 1.0; // Default to 1 if you can't stand
  }

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toStringAsFixed(0); // If it is a whole number
    } else {
      return quantity.toStringAsFixed(2); // Show two decimals for fractions
    }
  }

  Widget diners() {
    String textDiners = counterDiners == 1 ? "Comensal" : "Comensales";
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
            : (_recipeImageUrl != null
                ? Image.network(_recipeImageUrl!,
                    fit: BoxFit
                        .cover) // Shows the image stored in Firestore if there is
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

  Future<void> _fetchRecipeData() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Recetas').doc(widget.recipeId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Load the data in the controllers and lists
        _title.text = data['name'] ?? '';
        _recipeImageUrl = data['image'];
        String description = data['description'] as String;

        description.split('Paso').forEach((part) {
          if (part.trim().isNotEmpty) {
            recipeSteps
                .add('Paso ${part.trim()}\n'); // Add line jump and numbering
          }
        });
        step = recipeSteps.length + 1;
        _filteredIngredients = List<String>.from(data['ingredients']
            .map((ingredient) => ingredient.replaceAll('_', ' ')));
        originalDiners = data['diner'] ?? 1;
        counterDiners = originalDiners;
        selectedIngredients = List<Map<String, dynamic>>.generate(
          data['portions'].length,
          (index) {
            final portion = data['portions'][index];
            final parts = portion.split(' ');
            final quantity = parts[0];
            final unit = parts.sublist(1).join(' ');

            return {
              'name': _filteredIngredients[index],
              'quantity': quantity,
              'originalQuantity': quantity,
              'unit': unit,
            };
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al obtener los datos de la receta')),
        );
      }
    }
  }

  Future<void> _updateRecipeData() async {
    try {
      String updatedDescription = recipeSteps
          .map((step) =>
              step.replaceAll('\n', '').trim()) // Eliminate line and space jump
          .join(" ");

      List<String> updatedIngredients = selectedIngredients.map((ingredient) {
        return '${ingredient['name'].replaceAll(' ', '_')}';
      }).toList();

      List<String> updatedPortions = selectedIngredients.map((ingredientData) {
        return '${ingredientData['quantity']} ${ingredientData['unit']}';
      }).toList();

      await _firestore.collection('Recetas').doc(widget.recipeId).update({
        'name': _title.text,
        'image': _imageFile != null
            ? await uploadRecipeImage(_imageFile!, _title.text)
            : (await _firestore
                .collection('Recetas')
                .doc(widget.recipeId)
                .get())['image'], // Upload image if it changed
        'description': updatedDescription, // Unite steps with "."
        'ingredients': updatedIngredients, // Update ingredients
        'diner': counterDiners, // Update diners
        'portions': updatedPortions // Update amounts
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta actualizada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al obtener los datos de la receta')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    step = 1;
    _fetchIngredients();
    _fetchRecipeData();
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
          title: const Text("Edita tu receta"),
          elevation: 10,
          leading: IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus(); // Close the keyboard
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
                                  // Show the steps with the option of editing and deleting
                                  ...recipeSteps.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    String stepe = entry.value;

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              await _editStep(index, stepe);
                                            },
                                            child: Text(stepe),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () async {
                                            await _editStep(index,
                                                stepe); // Function to edit the step
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              _deleteStep(
                                                  index); // Eliminate step
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
                          _updateRecipeData();
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
