import 'package:cloud_firestore/cloud_firestore.dart';
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

            return CustomScrollView(
              slivers: [
                SliverAppBar(
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
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Ingredientes:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        for (int i = 0; i < ingredients.length; i++)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ingredients[i].toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                (i < portions.length ? portions[i] : ''),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16.0),
                        const Text(
                          "Descripción",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formattedDescription,
                          style: const TextStyle(fontSize: 17),
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
