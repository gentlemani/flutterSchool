import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatsily/Interface_pages/home_pages/account_pages/edit_recipe_account.dart';
import 'package:eatsily/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecipesHome extends StatefulWidget {
  final String recetaId;
  const RecipesHome({super.key, required this.recetaId});

  @override
  State<RecipesHome> createState() => _RecipesHomeState();
}

class _RecipesHomeState extends State<RecipesHome> {
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

            final String name =
                recipeData['name'] as String? ?? 'Nombre no disponible';
            final String description = recipeData['description'] as String? ??
                'Descripción no disponible';
            final String imageUrl = recipeData['image'] as String? ?? '';
            final List<dynamic> ingredients = recipeData['ingredients'] ?? [];
            final List<dynamic> portions = recipeData['portions'] ?? [];
            final String createdBy = recipeData['created_by'] as String? ?? '';

            final List<String> formattedIngredients = ingredients
                .map((ingredient) => ingredient.toString().replaceAll('_', ' '))
                .toList();

            // Divide the description into steps
            List<String> steps = description.split('. ');

            // If the last part of the list is empty, we eliminate that element
            if (steps.isNotEmpty && steps.last.isEmpty) {
              steps.removeLast();
            }

            // Add step number to each part
            String formattedDescription = steps.asMap().entries.map((entry) {
              int index = entry.key;
              String step = entry.value.trim();
              return 'Paso ${index + 1}: $step.';
            }).join('\n\n');

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
                    background: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
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
                SliverList(
                    delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              name,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
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
                                                    recipeId:
                                                        widget.recetaId)));
                                  })
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'Ingredientes:',
                          style: bodyTextStyle,
                        ),
                        const SizedBox(height: 8.0),
                        for (int i = 0; i < formattedIngredients.length; i++)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  formattedIngredients[i].toString(),
                                  style: instrucctionTextStyle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                (i < portions.length ? portions[i] : ''),
                                style: instrucctionTextStyle,
                              ),
                            ],
                          ),
                        const SizedBox(height: 16.0),
                        Text(
                          "Descripción",
                          style: bodyTextStyle,
                        ),
                        Text(
                          formattedDescription,
                          style: instrucctionTextStyle,
                        ),
                      ],
                    ),
                  ),
                ]))
              ],
            );
          }
        },
      ),
    );
  }
}
