import 'package:eatsily/Interface_pages/home_pages/account_pages/ingredient.dart';
import 'package:flutter/material.dart';

class SearchIngredientDelegate extends SearchDelegate<Ingredient> {
  final List<Ingredient> ingredientes;
  List<Ingredient> filter = [];
  bool _exactSearch = false;

  SearchIngredientDelegate(this.ingredientes);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.arrow_back));
  }

  // Function to filter the ingredients with exact search option or not
  void _filterIngredients() {
    List<String> keywords = query.trim().toLowerCase().split(' ');
    if (_exactSearch) {
      filter = ingredientes.where((ingredient) {
        return keywords
            .any((keyword) => ingredient.name.toLowerCase() == keyword);
      }).toList();
    } else {
      filter = ingredientes.where((ingredient) {
        return keywords
            .any((keyword) => ingredient.name.toLowerCase().contains(keyword));
      }).toList();
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    _filterIngredients();

    return ListView.builder(
      itemCount: filter.length,
      itemBuilder: (_, index) {
        return ListTile(
          title: Text(filter[index].name),
          onTap: () {
            close(context, filter[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _filterIngredients();
    List<Ingredient> limitedSuggestions = filter.take(50).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              StatefulBuilder(builder: (context, setState) {
                return Checkbox(
                  value: _exactSearch,
                  onChanged: (bool? value) {
                    setState(() {
                      _exactSearch = value ?? false;
                      _filterIngredients();
                    });
                  },
                );
              }),
              const Text("Búsqueda exacta"),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: limitedSuggestions.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) {
                return ListTile(
                  title: Text('Buscar "$query"'),
                  leading: const Icon(Icons.search),
                  onTap: () {
                    showResults(context);
                  },
                );
              }
              return ListTile(
                title: Text(limitedSuggestions[index - 1].name),
                onTap: () {
                  close(context, limitedSuggestions[index - 1]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
