import 'package:eatsily/Interface_pages/home_pages/account_pages/ingredient.dart';
import 'package:flutter/material.dart';

class SearchIngredientDelegate extends SearchDelegate<Ingredient> {
  final List<Ingredient> ingredientes;

  List<Ingredient> filter = [];

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

  @override
  Widget buildResults(BuildContext context) {
    List<String> keywords = query.trim().toLowerCase().split(' ');
    filter = ingredientes.where((ingredient) {
      return keywords
          .any((keyword) => ingredient.name.toLowerCase().contains(keyword));
    }).toList();
    return ListView.builder(
        itemCount: filter.length,
        itemBuilder: (_, index) {
          return ListTile(
            title: Text(filter[index].name),
            onTap: () {
              close(context, filter[index]);
            },
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> keywords = query.trim().toLowerCase().split(' ');
    filter = ingredientes.where((ingredient) {
      return keywords
          .any((keyword) => ingredient.name.toLowerCase().contains(keyword));
    }).toList();
    List<Ingredient> limitedSuggestions = filter.take(50).toList();
    return ListView.builder(
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
        });
  }
}
