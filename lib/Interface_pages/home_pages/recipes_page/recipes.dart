import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsily/Interface_pages/home_pages/account_pages/edit_recipe_account.dart';
import 'package:eatsily/constants/constants.dart';
import 'package:eatsily/sesion/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecipesHome extends StatefulWidget {
  final String recetaId;
  const RecipesHome({super.key, required this.recetaId});

  @override
  State<RecipesHome> createState() => _RecipesHomeState();
}

class _RecipesHomeState extends State<RecipesHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _filteredIngredients = [];
  List<Map<String, dynamic>> selectedIngredients = [];
  List<String> recipeSteps = [];
  int step = 1;
  int counterDiners = 0;
  String? _recipeImageUrl;
  int originalDiners = 1;
  String name = "";
  String selectedCategory = "Ingredientes";
  late final DatabaseService _firestoreService;
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _fetchRecipeData() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Recetas').doc(widget.recetaId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        name = data['name'] ?? '';
        _recipeImageUrl = data['image'];
        String description = data['description'] as String;
        description.split('Paso').forEach((part) {
          if (part.trim().isNotEmpty) {
            recipeSteps
                .add('Paso ${part.trim()}\n'); // Add line jump and numbering
          }
        });
        step = recipeSteps.length;
        _filteredIngredients = List<String>.from(data['ingredients']
            .map((ingredient) => ingredient.replaceAll('_', ' ')));
        originalDiners = data['diner'] ?? 1;
        counterDiners = originalDiners;
        selectedIngredients = List<Map<String, dynamic>>.generate(
          data['portions'].length,
          (index) {
            // Separate the chain into quantity and unit
            final portion = data['portions'][index];
            final parts = portion.split(' '); // Divide the chain into partss
            final quantity = parts[0]; //First element is the amount
            final unit =
                parts.sublist(1).join(' '); //Rest of the elements are the unit

            return {
              'name': _filteredIngredients[
                  index], //Assign the name of the corresponding ingredient
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

  Widget buildVoteSection(
      String recetaId, String userId, int currentVotes, bool isLike) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestoreService.getUserVoteStream(recetaId, userId),
      builder: (context, voteSnapshot) {
        if (voteSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (voteSnapshot.hasError) {
          return Center(child: Text('Error: ${voteSnapshot.error}'));
        } else {
          bool? userVote;
          var voteData = voteSnapshot.data!.data() as Map<String, dynamic>?;
          userVote = voteData?['vote'] as bool?;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$currentVotes', style: const TextStyle(fontSize: 17)),
                  IconButton(
                    iconSize: 25,
                    icon: Icon(
                      isLike
                          ? (userVote == true
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined)
                          : (userVote == false
                              ? Icons.thumb_down_alt
                              : Icons.thumb_down_alt_outlined),
                      color: isLike
                          ? (userVote == true ? Colors.blue : null)
                          : (userVote == false ? Colors.red : null),
                    ),
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await _firestoreService.voteRecipe(
                            recetaId, userId, isLike);
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
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
    //Handle fractions as "1/2", "1/4", etc..
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

  Widget selectionlike(
      String recetaId, String userId, int likesCount, int dislikesCount) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "!Valora esta receta¡",
          style: headingTextStyle,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildVoteSection(recetaId, userId, likesCount, true),
            buildVoteSection(recetaId, userId, dislikesCount, false),
          ],
        )
      ],
    );
  }

  Widget buildIngredientsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Avoid independent scroll
      itemCount: selectedIngredients.length,
      itemBuilder: (context, index) {
        final ingredient = selectedIngredients[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ingredient['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  "${ingredient['quantity']} ${ingredient['unit']}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredients() {
    return Column(
      children: [diners(), buildIngredientsList()],
    );
  }

  Widget _buildSteps() {
    return Column(
      children: [buildRecipeSteps()],
    );
  }

  Widget list() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = "Ingredientes";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCategory == "Ingredientes"
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  child: Text("Ingredientes", style: buttomTextStyle),
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = "Pasos";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedCategory == "Pasos" ? Colors.blue : Colors.grey,
                  ),
                  child: Text("Pasos", style: buttomTextStyle),
                ),
              ),
            ],
          ),
        ),
        // Show data according to the selected category
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: selectedCategory == "Ingredientes"
                ? _buildIngredients()
                : _buildSteps(),
          ),
        ),
      ],
    );
  }

  Widget buildRecipeSteps() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipeSteps.length,
      itemBuilder: (context, index) {
        final step = recipeSteps[index]
            .replaceFirst(RegExp(r'Paso \d+\.?\s*'), ''); // remover "pasoX."
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _firestoreService = DatabaseService(uid: user!.uid);
    }
    step = 1;
    _fetchRecipeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Recetas')
            .doc(widget.recetaId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Receta no encontrada'));
          } else {
            final recipeData = snapshot.data!.data() as Map<String, dynamic>?;
            if (recipeData == null) {
              return const Center(
                  child: Text('Datos de la receta no disponibles'));
            }
            'Descripción no disponible';
            final String createdBy = recipeData['created_by'] as String? ?? '';
            final int likesCount = recipeData['likes'] as int? ?? 0;
            final int dislikesCount = recipeData['dislikes'] as int? ?? 0;

            String uid = FirebaseAuth.instance.currentUser!.uid;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
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
                  expandedHeight: 250,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _recipeImageUrl!.isNotEmpty
                        ? Image.network(
                            _recipeImageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey,
                            child: const Center(
                              child: Text(
                                'Sin imagen',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                    centerTitle: true,
                  ),
                  floating: false,
                  pinned: true,
                  snap: false,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                              child: Text(
                            name,
                            style: headingTextStyle,
                          )),
                          if (createdBy == uid)
                            IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 30,
                                  color: Color.fromARGB(255, 243, 17, 17),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditRecipeAccount(
                                                  recipeId: widget.recetaId)));
                                }),
                        ],
                      )),
                ),
                SliverToBoxAdapter(child: list()),
                SliverToBoxAdapter(
                    child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: selectionlike(
                        widget.recetaId, uid, likesCount, dislikesCount),
                  ),
                ))
              ],
            );
          }
        },
      ),
    );
  }
}
