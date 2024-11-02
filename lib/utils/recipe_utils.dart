
List<String> parseRecipeSteps(String description) {
  return description.split('Paso').where((part) => part.trim().isNotEmpty).map((part) => 'Paso ${part.trim()}\n').toList();
}

List<Map<String, dynamic>> formatIngredients(List<dynamic> ingredients, List<dynamic> portions) {
  return List<Map<String, dynamic>>.generate(portions.length, (index) {
    final parts = portions[index].split(' ');
    final quantity = parts[0];
    final unit = parts.sublist(1).join(' ');

    return {
      'name': ingredients[index].replaceAll('_', ' '),
      'quantity': quantity,
      'originalQuantity': quantity,
      'unit': unit,
    };
  });
}