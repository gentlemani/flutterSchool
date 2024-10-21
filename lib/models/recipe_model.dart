class RecipeModel {
  final String id;
  final String name;
  final List<String> categories;
  final int likes;
  final int dislikes;

  RecipeModel({
    required this.id,
    required this.name,
    required this.categories,
    required this.likes,
    required this.dislikes,
  });

  factory RecipeModel.fromMap(String id, Map<String, dynamic> data) {
    return RecipeModel(
      id: id,
      name: data['name'] ?? '',
      categories: List<String>.from(data['category'] ?? []),
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categories': categories,
      'likes': likes,
      'dislikes': dislikes,
    };
  }
}
